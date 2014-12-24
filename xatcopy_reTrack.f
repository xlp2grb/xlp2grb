#!/usr/bin/expect -f
#upload two files remotly.
# this code is for the copy image to the temp making computer which is not matched by tempfile.
#author: xlp
#usage: xautocopy_reTrack.f refcom.fit
set copy_file1 [lindex $argv 0]
set password 123456
set ip 190.168.1.40
set term_dir /home/gwac/newfile/reTrack/
set username gwac
spawn scp -r  $copy_file1  $username@$ip:$term_dir
set timeout 300
expect {
"*yes/no*" {send "yes\r";exp_continue}
"*@$ip's password:" {send "$password\r";exp_continue}
}

