#include  <stdio.h>
#include  <math.h>
#include  <stdlib.h>
#include <sys/io.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
#define Radius_bp 1 
main()
{
        int     i,j,N0,N1,m;
	float	ra, dec,xcim,ycim,xcref,ycref,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10;
	char	time[30];
	char	image[50];
        float   x1[5000],x2[5000],x3[5000],x4[5000],x5[5000],x6[5000],x9[5000],x10[5000],x11[5000],x12[5000],x13[5000],x14[5000],x15[5000],x16[5000];
        float   y1[5000],y2[5000];
	char    x8[5000][50],x7[5000][50];
        FILE    *fp1; 
//	FILE	*fp1,fp1;
	FILE	*fave;
	char    *first, *second;

	first="newoutput";
	second="badpixelFile.db";

//	printf("first = %s\n",first);
//	printf("second = %s\n",second);
	i=0;
	j=0;
	fave=fopen("newoutputEjected","w+");
	
	fp1=fopen(first,"r");	
	if(fp1)
	{
	//	while((fscanf(fp1,"%f %f %f \n",&rxc1,&ryc2,&rflux3))!=EOF)
	while((fscanf(fp1,"%f %f %f %f %f %f %s %s %f %f %f %f %f %f %f %f \n",&ra, &dec,&xcim,&ycim,&xcref,&ycref,time,image,&c1,&c2,&c3,&c4,&c5,&c6,&c7,&c8))!=EOF)
	        {
                x1[i]=ra;
                x2[i]=dec;
                x3[i]=xcim;
		x4[i]=ycim;
		x5[i]=xcref;
		x6[i]=ycref;
		sprintf(x7[i],"%s",time);
		//x7[i]=time;
		 sprintf(x8[i],"%s",image);
		//x8[i]=image;
		x9[i]=c1;
		x10[i]=c2;
		x11[i]=c3;
		x12[i]=c4;
		x13[i]=c5;
		x14[i]=c6;
		x15[i]=c7;
		x16[i]=c8;
//		printf("%f %s %s\n",x1[i],x7[i],x8[i]);
		i++;
		}
		N0=i;
	}
	fclose(fp1);
	
	fp1=fopen(second,"r");	
	if(fp1)
	{
	while((fscanf(fp1,"%f %f %f %f %f %f %f %f %f %f\n",&xcim,&ycim,&c3,&c4,&c5,&c6,&c7,&c8,&c9,&c10))!=EOF)
          {
          y1[j]=xcim;
          y2[j]=ycim;
          j++;
          }
	  N1=j;
	
//	 printf("++++++++++++++++++++\n");
	
		for(i=0;i<N0;i++)
		{
			m=0;
			for(j=0;j<N1;j++)
			{	
				if(abs(y1[j]-x3[i])>Radius_bp || abs(y2[j]-x4[i])>Radius_bp )
				       m++;
			}
			//printf("m=%d\n",m);
			if(m==N1)		
			 fprintf(fave,"%f %f %f %f %f %f %s %s %f %f %f %f %f %f %f %f \n",x1[i],x2[i],x3[i],x4[i],x5[i],x6[i],x7[i],x8[i],x9[i],x10[i],x11[i],x12[i],x13[i],x14[i],x15[i],x16[i]);
		}	
		fclose(fave);
	}
       fclose(fp1);
}
