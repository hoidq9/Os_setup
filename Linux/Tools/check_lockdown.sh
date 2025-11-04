grep -q "\[confidentiality\]" /sys/kernel/security/lockdown && \
echo " ✅ Lockdown: CONFIDENTIALITY " || echo " ❌ Không ở mức cao nhất "
