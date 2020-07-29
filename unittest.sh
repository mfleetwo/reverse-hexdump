#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2013 Mike Fleetwood
# FILE: unittest.sh
#
# SYNOPSIS: Generic test case runner.
#           1) Sources TESTDIR/setup.sh if it exists.
#           2) Runs all the test cases TESTDIR/t???.sh with its exist
#              status determining success or failure.
#           3) Sources TESTDIR/teardown.sh if it exists.
#           Writes progress to stdout.  Writes all test case output to
#           to the log file TESTDIR/TESTEXE-unittest.log.
#
#           Each test case must prepare, run, check outcome and
#           optionally tidyup its own test.  It should routinly write
#           to stdout or stderr, so that any failures can be diagnosed.
#           The name of the executable being tested is passed as the
#           first parameter.
#           (See common.sh which can be sourced by the tests to do this
#           and more).
#
#           Use the optional setup script to prepare for the test
#           cases, such as setting required environment variables, etc.
#
# USAGE: unittest.sh TESTEXE TESTDIR


if [ $# -ne 2 ]; then
	echo "Usage: unittest.sh TESTEXE TESTDIR" 1>&2
	exit 1
fi
TESTEXE="$1"
basename=`basename "$TESTEXE"`
rootname="${basename%%.*}"
TESTDIR="$2"

LOG="$TESTDIR/$rootname-unittest.log"
exec 9> "$LOG"
echo "unittest.sh $*"						1>&9
echo "TESTEXE=\"$TESTEXE\""					1>&9
echo "TESTDIR=\"$TESTDIR\""					1>&9
echo "STDOUT> Unit testing $TESTEXE"				1>&9
echo "Unit testing $TESTEXE"
echo "STDOUT> Logging to $LOG"					1>&9
echo "Logging to $LOG"
echo 								1>&9

if [ "`echo "$TESTEXE" | cut -c1`" != '/' ]; then
	TESTEXE="`pwd`/$TESTEXE"
	echo "TESTEXE=\"$TESTEXE\""				1>&9
fi
echo "cd $TESTDIR"						1>&9
cd "$TESTDIR"
echo 								1>&9

errorexit()
{
	echo "STDOUT> ERROR: $*"				1>&9
	echo "ERROR: $*"
	exit 1
}

echon()
{
	echo "$*" | awk '{printf "%s", $0}'
}

if [ -x './setup.sh' ]; then
	echo "Sourcing ./setup.sh ..."				1>&9
	echo "----8<---- Output from \". ./setup.sh\" ----8<----"	1>&9
	. ./setup.sh 1>&9 2>&9
	status=$?
	set +x
	echo "----8<----"					1>&9
	echo "Exit status: $status"				1>&9
	if [ $status -ne 0 ]; then
		errorexit "Sourcing ./setup.sh failed with status: $status"
	fi
else
	echo "Executable ./setup.sh not found"			1>&9
	echo "Not sourcing ./setup.sh"				1>&9
fi
echo 								1>&9

TESTCASES="`ls t???.sh 2> /dev/null`"
if [ "X$TESTCASES" = 'X' ]; then
	total=0
else
	total="`echo "$TESTCASES" | wc -l`"
fi
i=1
passed=0
failed=0
for t in $TESTCASES
do
	name=`awk '
		BEGIN {maxlen = 50}
		{
			match($0, "^# ?TEST ?: *")
			if (RSTART == 1 && RLENGTH > 0)
			{
				name = substr($0, RLENGTH+1)
				if (length(name) > maxlen)
					name = substr(name, 1, maxlen-3) "..."
				padding = maxlen - length(name)
				printf " (%s)%*s", name, padding, ""
				exit
			}
		}' "$t"`
	echo "STDOUT> [$i/$total] ${t}${name} " 		1>&9
	echon "[$i/$total] ${t}${name} "
	echo "Executing test \"./$t\" \"$TESTEXE\" ..."		1>&9
	echo "----8<---- Output from \"./$t $TESTEXE\" ----8<----"	1>&9
	"./$t" "$TESTEXE" 1>&9 2>&9
	status=$?
	echo "----8<----"					1>&9
	echo "Exit status: $status"				1>&9
	case "$status" in
	'0')	outcome='[PASSED]'
		passed=`expr $passed + 1`
		;;
	*)	outcome='[FAILED]'
		failed=`expr $failed + 1`
		;;
	esac
	echo "STDOUT> [$i/$total] ${t}${name} $outcome"		1>&9
	echo "$outcome"
	i=`expr $i + 1`
	echo 							1>&9
done

if [ -x './teardown.sh' ]; then
	echo "Sourcing ./teardown.sh ..."			1>&9
	echo "----8<---- Output from \". ./teardown.sh\" ----8<----"	1>&9
	. ./teardown.sh 1>&9 2>&9
	status=$?
	set +x
	echo "----8<----"					1>&9
	echo "Exit status: $status"				1>&9
	if [ $status -ne 0 ]; then
		errorexit "Sourcing ./teardown.sh failed with status: $status"
	fi
else
	echo "Executable ./teardown.sh not found"		1>&9
	echo "Not sourcing ./teardown.sh"			1>&9
fi
echo 								1>&9

echo "STDOOUT> $passed/$total tests passed"			1>&9
echo "$passed/$total tests passed"
[ $passed -eq $total ]
status=$?
echo "Unit test exit status: $status"				1>&9
exit $status
