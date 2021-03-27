#!/bin/bash
# 
# If not passed in as an argument, will use the file ip_list.txt
# in the parent directory (../) for the ips to check, if found
# 
# This script assumes the existence of a file 'master_ips.txt' in the same directory as it, and also assumes that 'master_ips.txt' has one public IP address per line, no blank lines, and no commas
# 
# This script returns with status 0 if able to connect to all the Theias on port 3000, and with status 1 otherwise
# 
# Note: this script won't run on some versions of RHEL / CentOS, unfortunately (see https://stackoverflow.com/questions/4922943/test-if-remote-tcp-port-is-open-from-a-shell-script/14701003#14701003)

using_immediate_stop_mode=0
if echo $* | grep -e "--stop-immediately-when-inaccessible-node-found" -q 
then
  echo ">>>> running with immediate_stop_mode enabled...."
  using_immediate_stop_mode=1
else
  echo ">>>> running with immediate_stop_mode disabled...."
fi 

theia_ide_port=3000
TIMEOUT_SECONDS=20
num_attempted_connections=0
num_successful_connections=0

input="master_ips.txt"

if [[ ! -f $input ]];
then
  echo "ERROR: this script requires that there be a file 'master_ips.txt' in the same directory. It will test if it can reach port 3000 for every ip address in this file. Please ensure the presence of this file in this directory and try again."
  return 1
fi

while IFS= read -r line
do
  num_attempted_connections=$(($num_attempted_connections+1))
  ip_address=$line
  nc -z -w $TIMEOUT_SECONDS -v $ip_address $theia_ide_port </dev/null &>/dev/null
  RETURN_STATUS=$?
  if [[ RETURN_STATUS == 0 ]]; 
  then 
    echo "Successfully connected to ${ip_address} port $theia_ide_port!"; 
    num_successful_connections=$(($num_successful_connections+1))
  else
    echo "Failed to connect to ${ip_address} on port $theia_ide_port"
    if [[ using-immediate-stop-mode == 1 ]];
    then 
      return 1
    fi
  fi    
done < "$input"

num_inaccessible_hosts=$(($num_attempted_connections - $num_successful_connections))

if [[ num_successful_connections -geq 0 ]];
then
  return 1
else 
  return 0
fi