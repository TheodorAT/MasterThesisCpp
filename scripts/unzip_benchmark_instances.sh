# Just a quick script for filtering and unzipping the relevant instances. 
# Get a list of all instances:
declare -a instances=() 
while IFS= read -r line; do
  if [[ $line != \#* ]]; then # Ignore commented lines starting with #.
    instances+=("${line//[$'\t\r\n ']}") # Here we remove the newlines and blank characters from the variable
  fi
done < "${HOME}/MasterThesisCpp/scripts/netlib_benchmark_instance_list"

for instance in "${instances[@]}" 
do
  file="${HOME}/netlib_benchmark/${instance}.mps.gz"
  if [ -f $file ]; then
    echo "Found ${instance}, unzipping it..."
    gunzip $file
    echo "Done"
  fi 
done