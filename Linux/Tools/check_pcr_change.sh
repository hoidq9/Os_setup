#!/bin/bash

if [ -d $HOME/pcr_result_luks_tpm ]; then
	systemd-analyze pcrs >$HOME/pcr_result_luks_tpm/result_new.txt

	awk '$1==4 || $1==7 || $1==11 {print $1,$3}' $HOME/pcr_result_luks_tpm/result.txt >$HOME/pcr_result_luks_tpm/old_hash.txt
	awk '$1==4 || $1==7 || $1==11 {print $1,$3}' $HOME/pcr_result_luks_tpm/result_new.txt >$HOME/pcr_result_luks_tpm/new_hash.txt

	declare -A pcr_status
	for pcr in 4 7 11; do
		old=$(awk -v p=$pcr '$1==p {print $2}' $HOME/pcr_result_luks_tpm/old_hash.txt)
		new=$(awk -v p=$pcr '$1==p {print $2}' $HOME/pcr_result_luks_tpm/new_hash.txt)
		if [[ "$old" == "$new" && -n "$old" ]]; then
			pcr_status[$pcr]="✅"
		else
			pcr_status[$pcr]="❌"
		fi
	done

	echo " PCR4: ${pcr_status[4]} || PCR7: ${pcr_status[7]} || PCR11: ${pcr_status[11]} "
fi
