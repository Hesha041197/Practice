#!/bin/sh
# Name: mvdir
# Desc: Move directories across file systems
# Args: $1 -> src dir
# $2 -> dest dir

PATH=/bin:/usr/bin ; export PATH

# function to print errors and exit

printERROR() { echo "ERROR: $@." >&2 ; exit 1; }

# function to print usage message and exit

printUSAGE() { echo "USAGE: ´/bin/basename $0´ $@." >&2 ; exit 1; }

# check whether sufficient args are given

if [ $# -lt 2 ] ; then
	printUSAGE "[src] [dest]"
fi

# check whether the source directory exists

if [ ! -d "$1" ] ; then
	printERROR "The source $1 is not a directory, or does not exist"
fi

# split up the source dir into its name and its parent's
# name for easier processing later on

SRCDIR_PARENT="´/usr/bin/dirname $1´"
SRCDIR_CHILD="´/bin/basename $1´"

# if dirname returns a relative dir we will be confused
# after cd'ing later on. So reset it to the full path.

SRCDIR_PARENT="´(cd $SRCDIR_PARENT ; pwd ; )´"

# check whether the destination exits

if [ -d "$2" ] ; then

	DESTDIR=´( cd "$2" ; pwd ; )´

else

# if the destination doesn't exist then assume the
# destination is the new name for the directory

	DESTDIR="´/usr/bin/dirname $2´"
	NEWNAME="´/bin/basename $2´"

# if dirname returns a relative dir we will be confused
# after cd'ing later on. So reset it to the full path.

	DESTDIR=´(cd $DESTDIR ; pwd ; )´

# if the parent of the destination doesn't exist,
# we're in trouble. Tell the user and exit.

	if [ ! -d "$DESTDIR" ] ; then
		printERROR "A parent of the destination directory $2 does not exist"
	fi

fi

# try and cd to the parent src directory

cd "$SRCDIR_PARENT" > /dev/null 2>&1
if [ $? -ne 0 ] ; then
	printERROR "Could not cd to $SRCDIR_PARENT"
fi

# use tar to copy the source dir to the destination

/bin/tar -cpf - "$SRCDIR_CHILD" | ( cd "$DESTDIR" ; /bin/tar -xpf - )

if [ $? -ne 0 ] ; then
	printERROR "Unable to successfully move $1 to $2"
fi

# if a rename of the copy is requested

if [ -n "$NEWNAME" ] ; then

# try and change to the destination directory

	cd "$DESTDIR" > /dev/null 2>&1
	if [ $? -ne 0 ] ; then
		printERROR "Could not cd to $DESTDIR"
	fi

# try and rename the copy

	/bin/mv "$SRCDIR_CHILD" "$NEWNAME" > /dev/null 2>&1
	if [ $? -ne 0 ] ; then
		printERROR "Could not rename $1 to $2"
	fi

# return to the original directory

	cd "$SRCDIR_PARENT" > /dev/null 2>&1
	if [ $? -ne 0 ] ; then
		printERROR "Could not cd to $SRCDIR_PARENT"
	fi
fi

# try and remove the original

if [ -d "$SRCDIR_CHILD" ] ; then
	/bin/rm -r "$SRCDIR_CHILD" > /dev/null 2>&1
	if [ $? -ne 0 ] ; then
		printERROR "Could not remove $1"
	fi
fi

exit 0
