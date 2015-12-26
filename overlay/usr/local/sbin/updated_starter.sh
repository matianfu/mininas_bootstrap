#!/bin/bash
#by mark 2015-11-10
#updated-starter 
#version 3.0.0
updated_starter_version=3.0.0
LOGFILE=/tmp/updated/updated_starter.log
TMPDIR=/tmp/updated/down 
TMP_URL_ONE=http://www.winsuntech.cn/NasUpdate/index.aspx
TMP_URL_TWO=http://update.winsuntech.cn/NasUpdate/index.aspx

#########################################################################################
set_enviroment(){

	if [ ! -e  $TMPDIR ] ; then 
		mkdir -p  $TMPDIR
	fi

	if [ ! -e  $LOGFILE ] ; then 
	
		touch $LOGFILE
	
	fi

}
##########################################################################################
#clean log file when file is biger than 5000
clean_log(){
	if [ -e $LOGFILE ] ; then 
		filelength=`ls  -l /tmp/updated | grep  updated_starter.log  | awk '{print $5}'`
		if [ $filelength -ge  5000 ] ; then		
			rm  $LOGFILE
			touch $LOGFILE
		else
			return 0
		fi
	fi

}
start_logwrite()
{
	updatestate="$1"
	logtime=`date "+%G-%m-%d %H:%M:%S"`  
	logstr="[$logtime] $updatestate"
	echo $logstr>>$LOGFILE
}
##########################################################################################
#read system version 
#system version  FORMAT:MiniNAS 3 0 0
read_soft_version()
{
	if [ -f /etc/mininas/version ]  ; then 
		majorversion=`cat /etc/mininas/version | awk '{print $2}'`
		minorversion=`cat /etc/mininas/version | awk '{print $3}'`
		samllversion=`cat /etc/mininas/version | awk '{print $4}'`
		softversion=$majorversion.$minorversion.$samllversion
		echo "$softversion"
	else 
		softversion=0.0.0
		start_logwrite "read_soft_version---not find  the /etc/mininas/version" 
	fi
	return 0


}


#读取硬件版本
#hardversion format :WS215i
read_hardversion()
{
	if [ -f /etc/mininas/hardversion ] ; then 
		hardversion=`cat /etc/mininas/hardversion`
		echo "$hardversion"
	
	else 
		hardversion=noversion
		start_logwrite "read_hardversion---not find  the /etc/mininas/hardversion"
	fi
	return 0

}


#读取升级服务版本
#updatedversion  file format :3 0 0
read_updated_version()
{
	if [ -f /etc/mininas/updatedversion ] ; then 
		majorversion=`cat /etc/mininas/updatedversion |  awk 'BEGIN{FS="."}{print $1}'`
		minorversion=`cat /etc/mininas/updatedversion | awk 'BEGIN{FS="."}{print $2}'`
		samllversion=`cat /etc/mininas/updatedversion | awk 'BEGIN{FS="."}{print $3}'`
		updatedversion=$majorversion.$minorversion.$samllversion
		echo "$updatedversion"
	else 
		updatedversion=0.0.0
		start_logwrite "read_updated_version---not find  the /etc/mininas/updatedversion"  
	fi
	return 0

}

#campare version
campare_version()
{
	down_version_file=$1
	
	if [ -f /etc/mininas/updatedversion ] ; then 
		majorversion=`cat /etc/mininas/updatedversion | awk 'BEGIN{FS="."}{print $1}'`
		minorversion=`cat /etc/mininas/updatedversion | awk 'BEGIN{FS="."}{print $2}'`
		samllversion=`cat /etc/mininas/updatedversion | awk 'BEGIN{FS="."}{print $3}'`
		updatedversion=$majorversion.$minorversion.$smallversion
		echo "currentupdatedversion:$updatedversion"
	else 
		updatedversion=0.0.0
		start_logwrite "campare_version---not find  the /etc/mininas/updatedversion"  
	fi
	
	if [ -f version ] ; then 
		down_majorversion=`cat version | awk 'BEGIN{FS="."}{print $1}'`
		down_minorversion=`cat version | awk 'BEGIN{FS="."}{print $2}'`
		down_smallversion=`cat version | awk 'BEGIN{FS="."}{print $3}'`
		down_updatedversion=$down_majorversion.$down_minorversion.$down_smallversion
		echo downloadupdatedversion:$down_updatedversion
	else 
		down_updatedversion=0.0.0
		start_logwrite "campare_version--- eer not find  the version" 
		return 1
	fi
	
	let currentversion=10000*$majorversion+100*$minorversion+$smallversion
	let updateversion=10000*$down_majorversion+100*$down_minorversion+$down_smallversion
	
	if [ $currentversion -ge  $updateversion ] ; then	
		start_logwrite "campare_version--- eer the version have question"
		return 1
	else
		return 0
	fi
	




}

#################################################################################################
#定时检测是否有新的安装包如果有需要下载的脚本则下载 下载完继续运行安装
check_down_updated()
{

	neturl=$1
	version1=`read_soft_version`
	echo chk$version1
	version2=`read_hardversion`
	echo chk$version2
	version3=`read_updated_version`
	echo chk$version3
	
	installflg=0
	#check the download version 
	if [ -d $TMPDIR ] ; then 
		cd 	$TMPDIR
		flg=null
		ls  | grep ".tar.gz"
		if [ $? -eq 0 ]  ; then
			packagenameall=`ls  | grep ".tar.gz"`
			packagename=${packagenameall%\.*\.*}
			flg=tar.gz;
			find ./ -type d | rm -rf `xargs`
			tar -xzvf  updated*.tar.gz
			cd $packagename
			md5sum -c  updated.md5
			checkresult=$? 
			echo checkresult:$checkresult
			if [ $checkresult -ne 0 ]; then
				rm -rf ../*
				start_logwrite "check_down_updated--- err  md5sum -c  updated.md5" 
				return 1
			
			else 
			#version campare
				cd updated 
				campare_version
				if [ $? -eq 0 ] ; then 
					installflg=1
				else
					rm -rf ../../*
					start_logwrite "check_down_updated---  campare_version  return not 0"  
					return 1
				fi		
						
			
			fi
			
		fi
	fi
	
	
	if [ $installflg -eq 0 ] ; then 
	
	
		#rm old dir
		if [ -d $TMPDIR ] ; then 
			rm -rf $TMPDIR/*
			mkdir  -p $TMPDIR
		else 
			mkdir  -p $TMPDIR
		fi
		cd $TMPDIR
		#Query the server 
		# for download  
		echo "download from  url "
		 curl -d  name=updated  -d sv=$version1 -d hv=$version2 -d uv=$version3 $neturl > tmpreturn
		if [ $? -ne 0 ] ; then
			echo "no get updated package url "
			start_logwrite "check_down_updated--- err curl -d  name=updated  -d sv=$version1 -d hv=$version2 -d uv=$version3 $neturl > tmpreturn" 
			return 1

		else 
			echo "get updated package may be url  "
		fi
		#read firt line 
		read line < tmpreturn
		if [ $line = ""  ] ; then 
			start_logwrite "check_down_updated--- waring tmpreturn is empty file "  
			return 1
		fi
		
	
		echo $line | grep ".tar.gz"
		
		if [ $? -eq 0 ]  ; then
			flg=tar.gz;
		else
			start_logwrite "check_down_updated---waring tmpreturn is not have tar.gz  " 
			return 1 
		fi
		 
		tr -d '\015' <tmpreturn >tmpreturnlinux

		read packurl < tmpreturnlinux
		echo $packurl
		#download the  tar  package
		curl -O   $packurl
		
		find $TMPDIR  -name  *.$flg
		if [ $? -ne 0 ] ; then 
			start_logwrite "check_down_updated---waring dowload  $packurl faile "  
			return 1 
			
		fi 
		
		#check if download success
		flg=null
		ls  | grep ".tar.gz"
		if [ $? -eq 0 ]  ; then
			flg=tar.gz;
			if [ $? -eq 0 ]  ; then
			packagenameall=`ls  | grep ".tar.gz"`
			packagename=${packagenameall%\.*\.*}
			flg=tar.gz;
			find ./ -type d | rm -rf `xargs`
			tar -xzvf  updated*.tar.gz
			cd $packagename
			md5sum -c  updated.md5
			checkresult=$? 
			echo checkresult:$checkresult
			if [ $checkresult -ne 0 ]; then
				rm -rf ../*
				start_logwrite "check_down_updated--- err  md5sum -c  updated.md5" 
				return 1
			else 
			#version campare
				cd updated 
				campare_version
				if [ $? -eq 0 ] ; then 
					installflg=1
				else
					rm -rf ../../*
					start_logwrite "check_down_updated---  campare_version  return not 0"  
					return 1
				fi		
			
			fi
			
		fi
			
		else 
			start_logwrite "check_down_updated--- waring  down load  not find tar.gz"  
			return 1 
		fi
		
		
	
	
	fi
	
	
	
	
	#install the updated
	
	if [  $installflg -eq 1 ]  ; then 
		chmod 755  install.sh
		# install updated 
		source install.sh
		installreturn=$?
		if [ $installreturn -eq 0 ] ; then
			rm -rf ../../*
			start_logwrite "check_down_updated---  install.sh return  0"  
			return 0
		else 
			start_logwrite "check_down_updated---  install.sh return  $installreturn"  
			return $installreturn
		fi

	else 
		start_logwrite "check_down_updated--- installflg:$installflg"  
		return  1
	fi
	
	
	
	
	
}




################################################################################################

set_enviroment
while true ; do
	clean_log
	check_down_updated  $TMP_URL_ONE
	returnstatus=$?
	echo $returnstatus
	if [ $returnstatus -ne  0 ] ; then 
		start_logwrite "no install new update_guid"
	else 	
		start_logwrite "install new update_guide"
		
	fi 
	if [ $returnstatus -eq  1 ] ; then 
		check_down_updated  $TMP_URL_TWO
		returnstatus=$?
		echo $returnstatus
		if [ $returnstatus -ne  0 ] ; then 
			start_logwrite "no install new update_guid"
		else 	
			start_logwrite "install new update_guide"
			
		fi 
	
	fi
	
	#four hour
	sleep 14400
done 












