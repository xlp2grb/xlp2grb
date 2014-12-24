//liping Xin 2012.7.24
//调试完毕 20120806


#include  <stdio.h>
#include  <math.h>
#include  <stdlib.h>
#include <sys/io.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
//#include <syslib.h>


main()
{
        int     i,j,k,m;
	float	xc1,yc2,mag3;
        float   x1[200000],x2[200000],x3[200000];
	int     a[10];
	float	sum,averagemag,diff,diff_sum,sigma,rationum,diffave;
	float	star_number,star_number_begin;
	float   nstar;
		

	char	tables[50];
	char 	*chlist;
        FILE    *fp1; 
	FILE	*fave;

	memset(x3,0,sizeof(float));
	
	chlist="newimg_maglimit.cat";
	fp1=fopen(chlist,"r");
	fave=fopen("newimg_maglimit_result.cat","a+");
			
			i=0;
			
//			fp1=fopen(chtable1,"r");

			
			sum=0;
 			nstar=0;    			
			if(fp1)
         		{
        	        	printf("%s is openning\n", chlist);

	        	        while((fscanf(fp1,"%f %f %f\n",&xc1,&yc2,&mag3))!=EOF)
	        	        {
        	                x1[i]=xc1;
        	                x2[i]=yc2;
        	                x3[i]=mag3;
				sum = sum+x3[i];
			//	printf("fwhm_read=%.3f, i=%d, fwhm_res=%f,sum=%.3f\n",fwhm3, i, x3[i],sum);
				nstar=nstar+1;
				i++;
				}
				
//				star_number=x6[i-1];
				star_number=nstar;
				averagemag=sum/star_number;
				printf("magnitude limit is  %.3f\n",averagemag);
				fprintf(fave,"%.3f \n",averagemag);
			}
			else
              		  	printf("Could not open file\n");
				
	        fclose(fp1);
	        fclose(fave);
//        	fclose(fplist);

}
