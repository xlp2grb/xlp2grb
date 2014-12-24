#!/usr/bin/expect -f
#download
#usage: xautocopy.f iplist /home/gwac/software /home/gwac
#the lot6c2.py code is set at the computer with an ip of 192.168.28.136

set iplist [lindex $argv 0]
set fitsfile [lindex $argv 1]
set term_dir [lindex $argv 2]
set password 123456
set computername gwac@190.168.1.40
spawn scp -r  $iplist $fitsfile  $computername:$term_dir
set timeout 300
expect {
"*yes/no*" {send "yes\r";exp_continue}
"$computername.$ip's password:" {send "$password\r";exp_continue}
}

