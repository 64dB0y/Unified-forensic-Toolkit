#!/bin/bash

echo "자동실행항목 정보 수집"
for script in /etc/init.d/*; do
	name=$( basename $script )
	status=$( chkconfig --list $name | grep on )
	echo "$name: $status"
done
exec > startup.txt
