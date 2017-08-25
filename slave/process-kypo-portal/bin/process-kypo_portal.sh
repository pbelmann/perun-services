#!/bin/bash

# This script checks if json files generated by perun-service kypo-portal have changed
# and if they did, it runs python script, which import data of users and groups into 
# KYPO AAI database.
#
#author:  Frantisek Hrdina
#date:	  2016-05-02
#
#

PROTOCOL_VERSION='1.1.0'

function process {
	DST_FILE_USERS="/tmp/users.scim"
	DST_FILE_GROUPS="/tmp/groups.scim"

	DST_KYPO_IMPORT="${LIB_DIR}/${SERVICE}/process-kypo_portal.py"

	### Status codes
	I_CHANGED=(0 "${DST_FILE_USERS} or ${DST_FILE_GROUPS} updated")
	I_NOT_CHANGED=(0 "${DST_FILE_USERS} and ${DST_FILE_GROUPS} has not changed")
	
	FROM_PERUN_USERS="${WORK_DIR}/users.scim"
	FROM_PERUN_GROUPS="${WORK_DIR}/groups.scim"

	create_lock

	diff_mv "${FROM_PERUN_USERS}" "${DST_FILE_USERS}"
	user_diff=$?
	diff_mv "${FROM_PERUN_GROUPS}" "${DST_FILE_GROUPS}"
	group_diff=$?
	
	if [ $user_diff -ne 0 ] && [ $group_diff -ne 0 ]; then
		log_msg I_NOT_CHANGED
	else
		log_msg I_CHANGED
		python3 $DST_KYPO_IMPORT
	fi

	if [ $? -eq 1 ]; then
		rm $DST_FILE_USERS $DST_FILE_GROUPS
	fi

	exit $?
}
