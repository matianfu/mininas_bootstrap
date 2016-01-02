#!/bin/bash
#
# 2015-12-07  BY MARK FOR WS215i
#

#PWR ON                    //PWR_BUTTON is pushed for now
#Copy ON                    //UCOPY_BUTTON is pushed for now
#RST2DF ON               //RESET_BUTTON is pushed for now
#NOBTN ON                //All BUTTON is released

powerflg=0
powerflgcnt=0

poweroncnt=0
rebootcnt=0
echo "power key beign"
while true 
do

	PWR_BUTTON_STATUS=`cat  /proc/BOARD_event`
	case $PWR_BUTTON_STATUS in 
		"PWR ON")
			echo "PWR ON"
			let poweroncnt+=1
			if [ $poweroncnt -ge 3 ] ; then
				echo PWR_LED 3 > /proc/BOARD_io 
				powerflg=1
				shutdown -h -P now
			fi
		;;
		"Copy ON")
			echo "Copy ON"
		;;
		"RST2DF ON")
			echo "RST2DF ON"
			let rebootcnt+=1
			if [ $rebootcnt -ge 3 ] ; then 
				echo "test"
				#powerflg=1
				#echo PWR_LED 3 > /proc/BOARD_io
				#shutdown -h -r now
				#not chk do what
			fi
		;;
		"NOBTN ON")
			echo "NOBTN ON"
			poweroncnt=0
			rebootcnt=0
		;;
	esac
	if [ $powerflg -eq 1 ] ; then
	
		let powerflgcnt+=1
#shutdown failed
		if [ $powerflgcnt -ge 600 ] ; then 
			echo PWR_LED 2 > /proc/BOARD_io
		fi
	
	fi
	sleep 1
done

echo "power key end"
