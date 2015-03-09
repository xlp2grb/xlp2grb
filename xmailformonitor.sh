# !/bin/sh  

Dir_monitor=$1
from='lhl@nao.cas.cn'  
to='gwac_cn@163.com'  
  
email_date=''  
email_subject='new_light_cuve_at'  
email_content="new light curves observed by 60cm"
email_attach_png="/home/burn/Mail/*_lc.png"  
email_attach_cat="/home/burn/Mail/output*"
  
  
function send_email(){  
  
    email_date=$(date "+%Y-%m-%d_%H:%M:%S")  
    email_subject=$email_subject"_"$email_date  
  
    echo $email_content | mutt -s $email_subject -a $email_attach_png -a $email_attach_cat -e 'set content_type="text/html"' -e 'my_hdr from:'$from -- $to  
  
}  
 
send_email  
