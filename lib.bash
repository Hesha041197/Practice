#!/bin/sh

################################################
# Name: printERROR
# Desc: prints an message to STDERR
# Args: $@ -> message to print
################################################

printERROR() {
	echo "ERROR:" $@ >&2
}

################################################
# Name: printWARNING
# Desc: prints an message to STDERR
# Args: $@ -> message to print
################################################

printWARNING() {
	echo "WARNING:" $@ >&2
}

################################################
# Name: printUSAGE
# Desc: prints a USAGE message and then exits
# Args: $@ -> message to print
################################################

printUSAGE() {
	echo "USAGE:" $@
exit
}

################################################
# Name: promptYESNO
# Desc: ask a yes/no question
# Args: $1 -> The prompt
# $2 -> The default answer (optional)
# Vars: YESNO -> set to the users response
# y for yes, n for no
################################################

promptYESNO() {

	if [ $# -lt 1 ] ; then
		printERROR "Insufficient Arguments."
	return 1
	fi

	DEF_ARG=""
	YESNO=""

	case "$2" in
		[yY]|[yY][eE][sS])
			DEF_ARG=y ;;
		[nN]|[nN][oO])
			DEF_ARG=n ;;
	esac

	while :
	do

		printf "$1 (y/n)? "

		if [ -n "$DEF_ARG" ] ; then
			printf "[$DEF_ARG] "
		fi

		read YESNO

		if [ -z "$YESNO" ] ; then
			YESNO="$DEF_ARG"
		fi

		case "$YESNO" in
			[yY]|[yY][eE][sS])
				YESNO=y ; break ;;
			[nN]|[nN][oO])
				YESNO=n ; break ;;
			*)
				YESNO="" ;;
		esac

	done

	export YESNO
	unset DEF_ARG
	return 0
}

################################################
# Name: promptRESPONSE
# Desc: ask a question
# Args: $1 -> The prompt
# $2 -> The default answer (optional)
# Vars: RESPONSE -> set to the users response
################################################

promptRESPONSE() {

	if [ $# -lt 1 ] ; then
		printERROR "Insufficient Arguments."
	return 1
	fi

	RESPONSE=""
	DEF_ARG="$2"

	while :
	do
		printf "$1 ? "
		if [ -n "$DEF_ARG" ] ; then
			printf "[$DEF_ARG] "
		fi

		read RESPONSE

		if [ -n "$RESPONSE" ] ; then
			break
		elif [ -z "$RESPONSE" -a -n "$DEF_ARG" ] ; then
			RESPONSE="$DEF_ARG"
		break
		fi
	done

	export RESPONSE
	unset DEF_ARG
	return 0
}

################################################
# Name: getSpaceFree
# Desc: output the space avail for a directory
# Args: $1 -> The directory to check
################################################

getSpaceFree() {

	if [ $# -lt 1 ] ; then
		printERROR "Insufficient Arguments."
	return 1
	fi

	df -k "$1" | awk 'NR != 1 { print $4 ; }'
}

################################################
# Name: getSpaceUsed
# Desc: output the space used for a directory
# Args: $1 -> The directory to check
################################################

getSpaceUsed() {

	if [ $# -lt 1 ] ; then
		printERROR "Insufficient Arguments."
	return 1
	fi

	if [ ! -d "$1" ] ; then
		printERROR "$1 is not a directory."
	return 1
	fi

	du -sk "$1" | awk '{ print $1 ; }'
}

################################################
# Name: getPID
# Desc: outputs a list of process id matching $1
# Args: $1 -> the command name to look for
################################################

getPID() {

	if [ $# -lt 1 ] ; then
		printERROR "Insufficient Arguments."
	return 1
	fi

	PSOPTS="-ef"

	/bin/ps $PSOPTS | grep "$1" | grep -v grep | awk '{ print $2;
	}'
}

################################################
# Name: getUID
# Desc: outputs a numeric user id
# Args: $1 -> a user name (optional)
################################################

getUID() {
	id $1 | sed -e 's/(.*$//' -e 's/^uid=//'
}



