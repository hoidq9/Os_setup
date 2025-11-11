#!/usr/bin/env bash
set -euo pipefail

SEAL=seal.tpm
WORK=$(pwd)
mkdir -p "$WORK"
echo "workdir=$WORK" >&2

# 1) parse asn1 lines for OCTET STRING -> get offset, hl, len
openssl asn1parse -inform DER -in "$SEAL" |
	sed -n "s/^[[:space:]]*\([0-9]\+\):[^h]*hl=\([0-9]\+\)[^l]*l=[[:space:]]*\([0-9]\+\).*OCTET STRING.*/\1 \2 \3/p" \
		>"$WORK"/oct_list.txt

if [ ! -s "$WORK"/oct_list.txt ]; then
	echo "No OCTET STRING entries found in $SEAL" >&2
	openssl asn1parse -inform DER -in "$SEAL"
	exit 1
fi

# 2) extract each OCTET STRING's raw content using dd (skip = offset + hl, count = len)
while read off hl len; do
	start=$((off + hl))
	outf="$WORK/oct_${off}.bin"
	echo "extracting offset=$off hl=$hl len=$len -> $outf" >&2
	dd if="$SEAL" of="$outf" bs=1 skip=$start count=$len status=none || {
		echo "dd failed for offset $off" >&2
		exit 2
	}
done <"$WORK"/oct_list.txt

# 3) show sizes and pick two largest (likely pub, priv)
echo "extracted files:" >&2
stat -c '%s %n' "$WORK"/oct_*.bin | sort -nr | tee "$WORK"/sizes.txt

# select two largest as candidates
files=($(stat -c '%s %n' "$WORK"/oct_*.bin | sort -nr | awk '{print $2}' | head -n2))
if [ ${#files[@]} -lt 2 ]; then
	echo "Less than 2 OCTET STRING contents extracted." >&2
	exit 3
fi
# convention: larger -> private, smaller -> public (but might be reversed)
priv_candidate="${files[0]}"
pub_candidate="${files[1]}"
echo "priv_candidate=$priv_candidate" >&2
echo "pub_candidate=$pub_candidate" >&2

# 4) try load/unseal with common parents
CTX="$WORK/seal.ctx"
OUT="$WORK/unsealed.key"
for parent in 0x81000011; do # o 0x81000001 0x81000009 0x81000010
	echo "trying parent=$parent" >&2
	tpm2_load -C "$parent" -u "$pub_candidate" -r "$priv_candidate" -c "$CTX" 2>"$WORK/tpm_load.err" || {
		echo "tpm2_load failed for parent=$parent; see $WORK/tpm_load.err" >&2
		continue
	}
	tpm2_readpublic -c "$CTX"
	tpm2_startauthsession --policy-session -S session.ctx
	tpm2_policypcr --session session.ctx --pcr-list sha256:18 -L policy.pcr
	echo "tpm2_load succeeded with parent=$parent" >&2

	tpm2_unseal -c "$CTX" -p session:session.ctx -o "$OUT" \
		2>"$WORK"/tpm_unseal.err && echo "unsealed -> $OUT" || echo "unseal failed; see $WORK/tpm_unseal.err"

	# if tpm2_unseal -c "$CTX" -p session:session.ctx -o "$OUT" 2>"$WORK/tpm_unseal.err"; then
	# 	echo "UNSEAL OK -> $OUT" >&2
	# 	hexdump -C "$OUT"
	# 	exit 0
	# else
	# 	echo "tpm2_unseal failed (parent=$parent). See $WORK/tpm_unseal.err" >&2
	# fi
done

echo "All tested parents failed to load/unseal. See $WORK for logs." >&2
echo "Useful debug commands:" >&2
echo "  cat $WORK/sizes.txt" >&2
echo "  hexdump -C $pub_candidate | sed -n '1,8p'" >&2
echo "  hexdump -C $priv_candidate | sed -n '1,8p'" >&2
echo "  sudo tpm2_getcap handles-persistent" >&2
echo "  sudo tpm2_pcrread sha256:18" >&2

# exit 10
