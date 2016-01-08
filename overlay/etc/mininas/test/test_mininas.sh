#!/bin/bash

#
#for test
#
TESTTMPPATH=/etc/mininas/test
#TESTTMPPATH=.
source ${TESTTMPPATH}/__test_mininas.sh
>$TESTFILE
echo $TESTFILE

test_mininas_example
basic_files_test
samba_test
ssh_test
ssdp_test
key_led_test
update_starter_test
netatalk_test

mysql_test
proftpd_test
deb_packages_test
python_packages_test
mininas_app_test
thunder_test
dlna_test
qqiot_test

