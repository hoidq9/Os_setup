grep -q "\[confidentiality\]" /sys/kernel/security/lockdown &&
	echo " Lockdown: ✅ " || echo " Lockdown: ❌ "
