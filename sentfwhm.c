/* sentfwhm.c*/
#include <string.h>
#include  <math.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h> /*for struct sockaddr_in*/
#include <sys/io.h>
#include <unistd.h>
#include <stdbool.h>
#include  <stdio.h>

#define DEST_IP   "190.168.1.32"
#define DEST_PORT 18851

int main()
{
  int res;
  int sockfd;
  struct sockaddr_in dest_addr;
  int len, bytes_sent;
  
  int  i;
  float frame_num,sum,star_num,fwhm,sigma;
  char *imagename;
  char image[20],mountccdid[20];	
//  char *msg = "Hello world\n";
  //char    x2[0];
  float    x[5];
  char     im[2];    
  //float    *msg;
  //char 	   *msg;
  char	   msg[30];
  FILE     *fp1; 
  char  *lastfwhmlist;


     lastfwhmlist="fwhm_lastdata";
//     printf("chlist = %s\n",lastfwhmlist);
//      printf("##\n");
  
     //fp1=fopen(lastfwhmlist,"r");
     fp1=fopen("fwhm_lastdata","r");
  
	if(fp1)
       	{
	     i=0;
  //           printf("%s is openning\n",lastfwhmlist);
            // while((fscanf(fp1,"%f %s %f %f %f %f\n",&frame_num,imagename,&sum,&star_num,&fwhm,&sigma)))
             if((fscanf(fp1,"%f %s %f %f %f %f %s",&frame_num,image,&sum,&star_num,&fwhm,&sigma,mountccdid))!=EOF)
             {  
             printf("%s is reading\n",lastfwhmlist);
             x[0]=frame_num;
             x[1]=sum;
             x[2]=star_num;
             x[3]=fwhm;
             x[4]=sigma;
	     strcpy(im,mountccdid);	
	     printf("%f %f %f %f %f %s\n",x[0],x[1],x[2],x[3],x[4],im);
//		printf("i,imagename and sum are %d and %s and %f\n",i,image,sum);
		i++;
      	     }	
	
		//*msg=x5[i];
		//*msg=x[4];
		x[3]=x[3]*100;
		if(x[3]<1000)
		     {
			sprintf(msg,"d#fwhm%s0%3.0f%%",im,x[3]);
		     }
		if(x[3]>1000 || x[3]==1000)
		     {
			sprintf(msg,"d#fwhm%s%4.0f%%",im,x[3]);
		     }	

        //  	sprintf(msg,"%4.0f",x[3]);
		printf("msg=%s\n\n",msg);
	//	i++;

//     	 len = strlen(msg);
// bytes_sent = send(sockfd, /* 连接描述符*/
//                   msg,    /* 发送内容*/
//                   len,    /* 发关内容长度*/
//                   0);     /* 发送标记, 一般置 0*/
//
       	 }

	else
	   printf("Could not open file\n");
           fclose(fp1);	

  /* 取得一个套接字*/
  sockfd = socket(AF_INET, SOCK_STREAM, 0);
  if (sockfd == -1) {
    perror("socket()");
    exit(1);
  }

  /* 设置远程连接的信息*/
  dest_addr.sin_family = AF_INET;                 /* 注意主机字节顺序*/
  dest_addr.sin_port = htons(DEST_PORT);          /* 远程连接端口, 注意网络字节顺序*/
  dest_addr.sin_addr.s_addr = inet_addr(DEST_IP); /* 远程 IP 地址, inet_addr() 会返回网络字节顺序*/
  bzero(&(dest_addr.sin_zero), 8);                /* 其余结构须置 0*/

  /* 连接远程主机，出错返回 -1*/
  res = connect(sockfd, (struct sockaddr *)&dest_addr, sizeof(struct sockaddr_in));
  if (res == -1) {
    perror("connect()");
    exit(1);
  }

  len = strlen(msg);

  bytes_sent = send(sockfd, /* 连接描述符*/
                    msg,    /* 发送内容*/
                    len,    /* 发关内容长度*/
                    0);     /* 发送标记, 一般置 0*/

  /* 关闭连接*/
  close(sockfd);
}

