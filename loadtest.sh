#!/bin/bash
#Usage 
#Used for loadtesting against different load intensity
#Results are logged into current directory with file name benchmark-log
#Send alert if max connection time is greater than 30 sec

if ! [ -x "$(type -P ab)" ]; then
	echo "pre-requisite apache benchmark and mail utils package"
	echo "ERROR: script requires apache bench"
	echo "For DEB systems install it with 'sudo apt-get install apache2-utils' and 'sudo apt-get install mailutils'"
	exit 1
fi        

SUBJECT="Api Timeout Exceed"
EMAILID="monitoring@mad-me.com"
URL="https://my.website/users"
limits="10 100 200 400 800 1600 2000"
totals="1000 2000 5000 10000 30000"

for limit in $limits
do
	for total in $totals
	do
		[[ $total == "1000" ]] && { request=10; }
		[[ $total == "2000" ]] && { request=10; }
		[[ $total == "5000" ]] && { request=20; }
		[[ $total == "10000" ]] && { request=20; }
		[[ $total == "30000" ]] && { request=30; }
		connect_time=$(ab -n $total -c $request $URL?$limit   | tee -a benchark-log | grep "Connect:" | awk '{print $NF}')
		if [ $connect_time -lt 30000 ]; then
			echo "Api Connection time within limit"
		else
			echo "Api connection Timeout more 30sec"
			echo "Api taking time more than 30 sec $(date). Time taken by Api=$connect_time" | mail -s "$SUBJECT" "$EMAILID" 
		fi
	done
done
