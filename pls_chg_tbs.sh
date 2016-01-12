#!/bin/bash

usage() {
	echo "Usage: $0 tablespace"
	echo "eg.  : $0 BILL01"
	exit 1
}

replace() {
	SQL_FILE=$1
	TBS_NM=$2
	if [ -f $SQL_FILE ]; then
		SZ_CKSUM_OLD=`cksum $SQL_FILE|awk '{printf("%s,%s\n", $2, $1)}'`
		cat $SQL_FILE | sed -e "s/PLS_CHG_TBS/$TBS_NM/" > $SQL_FILE.$$.tmp
		mv $SQL_FILE $SQL_FILE.$$.orig
		mv $SQL_FILE.$$.tmp $SQL_FILE
		SZ_CKSUM_NEW=`cksum $SQL_FILE|awk '{printf("%s,%s\n", $2, $1)}'`
		echo "$SQL_FILE replaced, old:new $SZ_CKSUM_OLD:$SZ_CKSUM_NEW"
	else
		echo "Error: $SQL_FILE not exists"
	fi
}

if [ $# -ne 1 ]; then
	usage
fi

replace run_log.sql $1
replace run_log_cfg.sql $1

