#!/usr/bin/expect -f
#upload four files remotly.
#author: xlp
#usage: xautocopy_remoteimg5.f  file1 file2  file3 file4 file5 ip term_dir
set copy_file1 [lindex $argv 0]
set copy_file2 [lindex $argv 1]
set copy_file3 [lindex $argv 2]
set copy_file4 [lindex $argv 3]
set copy_file5 [lindex $argv 4]
set ip [lindex $argv 5]
set term_dir [lindex $argv 6]
set password 123456
set username gwac
spawn scp -r  $copy_file1  $copy_file2 $copy_file3  $copy_file4 $copy_file5 $username@$ip:$term_dir
set timeout 300
expect {
"*yes/no*" {send "yes\r";exp_continue}
"*@$ip's password:" {send "$password\r";exp_continue}
}

