#!/bin/bash
#the model packge guide shell chose the dir to unzip packge and call the update.sh
newsourcepathname=/usr
newsourcemodeltempdir=mininasupdatetemp
logdir=logdir
stafile=$newsourcepathname/$newsourcemodeltempdir/upreturn.sta
percentfile=$newsourcepathname/$newsourcemodeltempdir/uppercent.sta


fupdate_sta_writel()
{
echo "write status"
sta=$1
cat << EOF > ${stafile}
$sta
EOF
sync
return 0
}

fupdate_percent_writel()
{

percent=$1
echo "write percent:$percent"
cat << EOF > ${percentfile}
$percent
EOF
sync
return 0

}

#make temp dir for tar the update package
cd $newsourcepathname 
if [ ! -d  $newsourcemodeltempdir ] ; then 
mkdir  $newsourcemodeltempdir
fi

chmod 777 $newsourcemodeltempdir
cd $newsourcemodeltempdir

if [ ! -d $logdir ] ; then
mkdir $logdir
fi
chmod 777  $logdir

touch $percentfile
chmod 777  $percentfile

touch $stafile
chmod 777  $stafile


#check the path is or not empty
if [ "$1" = "" ]; then
fupdate_sta_writel "1"
exit 1
fi

#get the path informations
lintemp="$1"
minimodelsourcepath=${lintemp%\.*\.*}
minimodelsourcename=${lintemp##*\/}
minimodelsourcedir=${minimodelsourcename%\.*\.*}


#get package name fix
packagefullname=${lintemp##*\/}       
packname=${packagefullname%\.*\.*}
minimodelsourecefix=${packagefullname##$packname}
echo $minimodelsourecefix

#check the file is or not tar.gz
if [ $minimodelsourecefix != ".tar.gz" ]; then 	
	fupdate_sta_writel "2"
	exit 2	
fi


fupdate_percent_writel "0"

#delete the the tar.gz package in tmpdir
rm -rf $minimodelsourcename

#cp 
cp $1  $minimodelsourcename
if [ $? -ne 0 ] ; then
	fupdate_sta_writel "3"
	exit 3
fi

tar -xzvf  $packagefullname
tarstatus=$?
#check  tar return
if [ $tarstatus -ne 0 ]; then
	fupdate_sta_writel "4"
	exit 4
fi
	
chmod 777 $minimodelsourcedir
cd $minimodelsourcedir

#check md5 
md5sum -c  mininas.md5
checkresult=$? 
echo checkresult:$checkresult
if [ $checkresult -ne 0 ]; then
	fupdate_sta_writel "5"
	exit 5
fi


cd mininas
chmod  777  update.sh
fupdate_percent_writel "5"
sync
source $newsourcepathname/$newsourcemodeltempdir/$minimodelsourcedir/mininas/update.sh "clibcall"
updatetotalstatus=$?
fupdate_sta_writel $updatetotalstatus
echo  "updatetotalstatus$updatetotalstatus"
exit  $updatetotalstatus


