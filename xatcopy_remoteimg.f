#!/usr/bin/expect -f
#upload one files remotly.
#author: xlp
#usage: xautocopy_remoteimg.f  file1 ip term_dir
set copy_file1 [lindex $argv 0]
set ip [lindex $argv 1]
set term_dir [lindex $argv 2]
set password 123456
set username gwac
spawn scp -r  $copy_file1 $username@$ip:$term_dir
set timeout 300
expect {
"*yes/no*" {send "yes\r";exp_continue}
"*@$ip's password:" {send "$password\r";exp_continue}
}

