DirSizeRenamer
==============

This console utility lets you rename subdirectories within a specified directory, so that subdirectories' names contain their sizes.

DirSizeRenamer goes through all files within each subfolder recursively, calculating their sizes.

What it does
------------

Directory structure before using DirSizeRenamer:

*   backups
  *   G 2012-04-17 12;40;29 (Full)
  *   G 2012-04-18 09;45;04 (Differential)
  *   G 2012-04-18 19;15;24 (Differential)
  *   G 2012-04-19 19;11;22 (Differential)
  *   G 2012-04-20 19;12;22 (Full)
  *   G 2012-04-23 19;12;14 (Differential)
  *   G 2012-04-24 19;12;15 (Differential)
  *   H 2012-04-17 22;08;23 (Full)
  *   H 2012-04-18 10;03;33 (Differential)
  *   H 2012-04-18 19;35;54 (Differential)
  *   H 2012-04-19 19;30;49 (Differential)
  *   H 2012-04-21 04;04;29 (Full)
  *   H 2012-04-23 19;30;24 (Differential)
  *   H 2012-04-24 19;31;37 (Differential)

Directory structure after applying DirSizeRenamer to the `backups` folder:

*   backups
  *   G 2012-04-17 12;40;29 (Full) [466.965GB]
  *   G 2012-04-18 09;45;04 (Differential) [965.34MB]
  *   G 2012-04-18 19;15;24 (Differential) [1.279GB]
  *   G 2012-04-19 19;11;22 (Differential) [1.954GB]
  *   G 2012-04-20 19;12;22 (Full) [469.197GB]
  *   G 2012-04-23 19;12;14 (Differential) [1001.337MB]
  *   G 2012-04-24 19;12;15 (Differential) [2.13GB]
  *   H 2012-04-17 22;08;23 (Full) [886.031GB]
  *   H 2012-04-18 10;03;33 (Differential) [485.532MB]
  *   H 2012-04-18 19;35;54 (Differential) [5.975GB]
  *   H 2012-04-19 19;30;49 (Differential) [7.922GB]
  *   H 2012-04-21 04;04;29 (Full) [892.858GB]
  *   H 2012-04-23 19;30;24 (Differential) [5.343GB]
  *   H 2012-04-24 19;31;37 (Differential) [6.822GB]

File Access Warning
-------------------

Please note that it will skip files if it has no access to their sizes. Thus, subfolder sizes may appear inaccurate. To resolve this issue, either make sure that the user running the program has access to all target files, or run DirSizeRenamer with `rvmsudo`.

If you use `rvmsudo` and you escape characters or wrap directory name into quotes, then you should escape the quotes and backslashes. This is not a feature of DirSizeRenamer, it's how POSIX works.

Usage
-----

dir_size_renamer -d <directory> [options]

    -d, --directory      Target directory. dir_size_renamer will process subdirectories within it. Mandatory!
    -f, --force          Process and re-rename already renamed subdirectories.
    -v, --verbose        Report results to console.
    -u, --undo           Derename mode. No calculation is done, sizes are removed from directory names.
    -h, --help           Display this help message.

### Examples

Rename the subdirectories that don't contain sizes in their names:
  dir_size_renamer -d /mnt/backups

Rename the subdirectories that don't contain sizes in their names, and display the results in console:
  dir_size_renamer -d /mnt/backups -v

The above command is the recommended usage for renaming backups.

Rename all the subdirectories, recalculate sizes for those subdirectories that already had sizes in their names:
  dir_size_renamer -d /mnt/backups -f

Remove sizes from all subdirectories:
  dir_size_renamer -d /mnt/backups -u

Disclaimer
----------

I hope this script will not ruin your filesystem! I does not ruin mine at least. If it ruins yours, i don't take responsibility!

Authors and license
-------------------

Coded by Andrey 'lolmaus' Mikhaylov. lolmaus@gmail.com

DirSizeRenamer is released under the Ruby license.

