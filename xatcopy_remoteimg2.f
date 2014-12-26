#!/usr/bin/expect -f
#upload two files remotly.
#author: xlp
#usage: xautocopy_remoteimg2.f  file1 file2 ip term_dir
set copy_file1 [lindex $argv 0]
set copy_file2 [lindex $argv 1]
set ip [lindex $argv 2]
set term_dir [lindex $argv 3]
set password 123456
set username gwac
spawn scp -r  $copy_file1  $copy_file2 $username@$ip:$term_dir
set timeout 300
expect {
"*yes/no*" {send "yes\r";exp_continue}
"*@$ip's password:" {send "$password\r";exp_continue}
}

