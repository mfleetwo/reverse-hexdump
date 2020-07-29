#!/bin/sh
# FILE: common.sh

# _testsetup()
#
# Generate the input file name from the test script name by replacing
# the .sh suffix with .in.
_testsetup()
{
	_basename=`basename "$0"`
	_rootname="${_basename%%.*}"
	_infile="${_rootname}.in"
}

# _test "$1"
#
# Run named test program to generate raw data, convert back to hexdump's
# canonical representation and check it matches the original input.
_test()
{
	if [ "${_infile}X" = 'X' ]; then
		_testsetup
	fi
	"$1" "$_infile" | hexdump -C | diff -u "$_infile" -
}
