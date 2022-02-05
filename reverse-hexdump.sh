#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2020 Mike Fleetwood
# FILE: reverse-hexdump.sh
# Reverse 'hexdump -C' output back to the original data.
# USAGE: reverse-hexdump.sh [FILE]... > DEST

LANG=C awk '
function outputbinary(text)
{
	num_elements = split(text, hex_strs)
	for (i = 1; i <= num_elements; i++)
		# WARNING: Run in "C" locale to prevent GAWK using
		# multibyte character encoding rather than printing
		# the desired byte.
		#   The GNU Awk Users Guide,
		#   5.5.2 Format-Control Letters, %c
		#   https://www.gnu.org/software/gawk/manual/html_node/Control-Letters.html
		printf "%c", strtonum("0x" hex_strs[i])
	return num_elements
}

BEGIN {
	curr_offset = 0
	next_offset = 0
	repeat = 0
}

/^[[:xdigit:]]/ {
	next_offset = strtonum("0x" $1)
}

/^[[:xdigit:]]/ && repeat == 1 {
	while (curr_offset < next_offset)
		curr_offset += outputbinary(hex_representation)
	repeat = 0
}

/^[[:xdigit:]]/ && repeat == 0 {
	curr_offset = strtonum("0x" $1)
	hex_representation = substr($0,11,48)
	curr_offset += outputbinary(hex_representation)
}

/^\*/ {
	repeat = 1
}' "${@}"
