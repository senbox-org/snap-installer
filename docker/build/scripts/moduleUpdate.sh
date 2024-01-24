#!bin/bash

home/snap/esa-snap/bin/snap --nosplash --nogui --modules --refresh --update-all 2>&1 | tee /tmp/update.log &
export MODULE_UPDATE_PID=`echo $!`
export IDX=0
while [ -d "/proc/${MODULE_UPDATE_PID}" ]
do
    # Here we fix how much time we wait n*10 seconds
    if [ ${IDX} -lt 12 ]
    then
        echo "Waiting for module update to end"
        # tail -1 /tmp/update.log
	# We wait 10 more seconds 
	sleep 10
    else
        echo "Killing module update process"
        kill -9 ${MODULE_UPDATE_PID}
    fi
    export IDX=$((IDX+1))
done
