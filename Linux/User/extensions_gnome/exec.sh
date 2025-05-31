cd /Os_H
IFS=' ' read -r -a nums <<< "$(cat cpu_power.txt cpu_voltage.txt | tr '\n' ' ')"

suffixes=(W V)

total=${#nums[@]}; 
for idx in "${!nums[@]}"; do 
  printf "%s %s" "${nums[$idx]}" "${suffixes[$idx]}"; 
  (( idx < total - 1 )) && printf " || "; 
done; printf "\n"
