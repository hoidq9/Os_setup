#!/bin/bash
user_current=$(logname)
yes=✅
no=❌

cd /home/$user_current/repos || return
if [ -d pcr-oracle/.git ]; then
	cd pcr-oracle || return
	BRANCH=$(git rev-parse --abbrev-ref HEAD)
	git fetch origin "$BRANCH" >/dev/null 2>&1
	if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/"$BRANCH")" ]; then
		pcr_oracle_uptodate=$no
	else
		pcr_oracle_uptodate=$yes
	fi
fi

cd /home/$user_current/repos || return
if [ -d grub2/.git ]; then
	cd grub2 || return
	BRANCH=$(git rev-parse --abbrev-ref HEAD)
	git fetch origin "$BRANCH" >/dev/null 2>&1
	if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/"$BRANCH")" ] || [ ! -d gnulib ]; then
		grub2_uptodate=$no
	else
		grub2_uptodate=$yes
	fi
fi

echo " pcr-oracle: $pcr_oracle_uptodate || grub2: $grub2_uptodate "
