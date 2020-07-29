reverse-hexdump
===============

`reverse-hexdump.sh` is a small shell/awk tool to reverse `hexdump -C`
output back to the original data.


Example
-------

Write a previous `hexdump -C` of an MSDOS partition table back to the
drive.

```
# cat msdos_table.txt 
00000000  fa b8 00 10 8e d0 bc 00  b0 b8 00 00 8e d8 8e c0  |................|
00000010  fb be 00 7c bf 00 06 b9  00 02 f3 a4 ea 21 06 00  |...|.........!..|
00000020  00 be be 07 38 04 75 0b  83 c6 10 81 fe fe 07 75  |....8.u........u|
00000030  f3 eb 16 b4 02 b0 01 bb  00 7c b2 80 8a 74 01 8b  |.........|...t..|
00000040  4c 02 cd 13 ea 00 7c 00  00 eb fe 00 00 00 00 00  |L.....|.........|
00000050  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
000001b0  00 00 00 00 00 00 00 00  f3 6b 05 00 00 00 00 20  |.........k..... |
000001c0  21 00 83 24 23 41 00 08  00 00 00 f0 0f 00 00 00  |!..$#A..........|
000001d0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
000001f0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 55 aa  |..............U.|
00000200

# reverse-hexdump.sh msdos_table.txt > /dev/sdb

# fdisk -l /dev/sdb

Disk /dev/md2: 536 MB, 536330240 bytes, 1047520 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x00056bf3

    Device Boot      Start         End      Blocks   Id  System
/dev/md2p1            2048     1046527      522240   83  Linux
```
