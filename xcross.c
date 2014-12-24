#include  <stdio.h>
#include  <math.h>
#include  <stdlib.h>
#include <sys/io.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
//#include <syslib.h>
#define Radius 0.5
main()
{
        int     i,j,k,m,N0,N1,N2;
	float	ra, dec,xcim,ycim,xcref,ycref,c1,c2,c3,c4,c5,c6,c7,c8;
	char	time[20];
	char	image[50];
        float   x1[5000],x2[5000],x3[5000],x4[5000],x5[5000],x6[5000],x9[5000],x10[5000],x11[5000],x12[5000],x13[5000],x14[5000],x15[5000],x16[5000];
        float   y1[5000],y2[5000],y3[5000],y4[5000],y5[5000],y6[5000],y9[5000],y10[5000],y11[5000],y12[5000],y13[5000],y14[5000],y15[5000],y16[5000];
        float   k1[5000],k2[5000],k3[5000],k4[5000],k5[5000],k6[5000],k9[5000],k10[5000],k11[5000],k12[5000],k13[5000],k14[5000],k15[5000],k16[5000];
	char    x8[5000][50],k8[5000][50],y8[5000][50],x7[5000][50],k7[5000][50],y7[5000][50];
        FILE    *fp1; 
//	FILE	*fp1,fp1;
	FILE	*fave;
	char    *first, *third,*second;

	first="first.db";
	second="second.db";
	third="third.db";

//	printf("first = %s\n",first);
//	printf("third = %s\n",third);
//	printf("second = %s\n",second);
	i=0;
	j=0;
	m=0;
	fave=fopen("3Frame_match.cat","w+");
	
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
	printf("####\n");
	fclose(fp1);
	
	fp1=fopen(second,"r");	
	if(fp1)
	{
	while((fscanf(fp1,"%f %f %f %f %f %f %s %s %f %f %f %f %f %f %f %f\n",&ra, &dec,&xcim,&ycim,&xcref,&ycref,time,image,&c1,&c2,&c3,&c4,&c5,&c6,&c7,&c8))!=EOF)
          {
          y1[j]=ra;
          y2[j]=dec;
          y3[j]=xcim;
          y4[j]=ycim;
          y5[j]=xcref;
          y6[j]=ycref;
	sprintf(y7[j],"%s",time);
	//x7[i]=time;
	 sprintf(y8[j],"%s",image);
	//x8[i]=image;
          y9[j]=c1;
          y10[j]=c2;
          y11[j]=c3;
          y12[j]=c4;
          y13[j]=c5;
          y14[j]=c6;
	  y15[j]=c7;
	  y16[j]=c8;
          j++;
          }
	  N1=j;
	}
	fclose(fp1);
	
	fp1=fopen(third,"r");
        if(fp1)
        {
	 while((fscanf(fp1,"%f %f %f %f %f %f %s %s %f %f %f %f %f %f %f %f \n",&ra, &dec,&xcim,&ycim,&xcref,&ycref,time,image,&c1,&c2,&c3,&c4,&c5,&c6,&c7,&c8))!=EOF)
          {
          k1[m]=ra;
          k2[m]=dec;
          k3[m]=xcim;
          k4[m]=ycim;
          k5[m]=xcref;
          k6[m]=ycref;
	  sprintf(k7[m],"%s",time);
	//x7[i]=time;
	  sprintf(k8[m],"%s",image);
	//x8[i]=image;
          k9[m]=c1;
          k10[m]=c2;
          k11[m]=c3;
          k12[m]=c4;
          k13[m]=c5;
          k14[m]=c6;
	  k15[m]=c7;
	  k16[m]=c8;
          m++;
          }
          N2=m;
        }
        fclose(fp1);

	
	for(i=0;i<N0;i++)
	{
		for(j=0;j<N1;j++)
		{
			for(m=0;m<N2;m++)
				{
				if(abs(y5[j]-x5[i])<Radius && abs(y6[j]-x6[i])<Radius && abs(k5[m]-x5[i])<Radius && abs(k6[m]-x6[i])<Radius )
				 	fprintf(fave,"%f %f %f %f %f %f %s %s %f %f %f %f %f %f %f %f \n %f %f %f %f %f %f %s %s %f %f %f %f %f %f %f %f \n %f %f %f %f %f %f %s %s %f %f %f %f %f %f %f %f \n",x1[i],x2[i],x3[i],x4[i],x5[i],x6[i],x7[i],x8[i],x9[i],x10[i],x11[i],x12[i],x13[i],x14[i],x15[i],x16[i],y1[j],y2[j],y3[j],y4[j],y5[j],y6[j],y7[j],y8[j],y9[j],y10[j],y11[j],y12[j],y13[j],y14[j],y15[j],y16[j],k1[m],k2[m],k3[m],k4[m],k5[m],k6[m],k7[m],k8[m],k9[m],k10[m],k11[m],k12[m],k13[m],k14[m],k15[m],k16[m]);
				}
		}
	}	
	fclose(fave);
}
