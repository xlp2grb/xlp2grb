#include  <stdio.h>
#include  <math.h>
#include  <stdlib.h>
#include <sys/io.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
//#include <syslib.h>
#define Npix  3
main()
{
        int     i,j,k,N1,N2;
	float	rxc1,ryc2,rflux3;
	float   oxc1,oyc2,oflux3,obg5,other6,omag7,omerr8,oell9,oclass10;
	int     oflag4;
	float   delx,dely,delr;
        float   rx[500000],ry[500000],rf[500000],o1[50000],o2[50000],o3[50000],o5[50000],o6[50000],o7[50000],o8[50000],o9[50000],o10[50000];
	int     o4[50000];
        FILE    *fp1; 
//	FILE	*fp1,fp1;
	FILE	*fmatch,*fnomatch;
	char    *refall,*subobj;

	refall="refcom3d.cat";
	subobj="subobj.db";

	printf("refall = %s\n",refall);
	printf("subobj = %s\n",subobj);

	i=0;
	j=0;
	k=0;
	fmatch=fopen("match_c.db","w+");
	fnomatch=fopen("nomatch_c.db","w+");
	fp1=fopen(refall,"r");	
	if(fp1)
	{
	        while((fscanf(fp1,"%f %f %f \n",&rxc1,&ryc2,&rflux3))!=EOF)
	        {
                rx[i]=rxc1;
                ry[i]=ryc2;
                rf[i]=rflux3;
		i++;
		}
		N1=i;
	}
	fclose(fp1);
	
	
//	 printf("####\n");
	fp1=fopen(subobj,"r");
        if(fp1)
        {
          while((fscanf(fp1,"%f %f %f %d %f %f %f %f %f %f\n",&oxc1,&oyc2,&oflux3,&oflag4,&obg5,&other6,&omag7,&omerr8,&oell9,&oclass10))!=EOF)
          {
          o1[j]=oxc1;
          o2[j]=oyc2;
          o3[j]=oflux3;
	  o4[j]=oflag4;	
	  o5[j]=obg5;
	  o6[j]=other6;
	  o7[j]=omag7;
	  o8[j]=omerr8;
	  o9[j]=oell9;
	  o10[j]=oclass10;
          j++;
          }
          N2=j;
        }
        fclose(fp1);

	
	for(j=0;j<N2;j++)
	{
		k=0;
		for(i=0;i<N1;i++)
		{
			delx=rx[i]-o1[j];
			dely=ry[i]-o2[j];
			delr=sqrt(pow(delx,2)+pow(dely,2));
			if(delr<Npix)
			{
				fprintf(fmatch,"%.3f %.3f %.3f %d %.3f %.3f %.3f %.3f %.3f %.3f %.3f\n",o1[j],o2[j],o3[j],o4[j],o5[j],o6[j],o7[j],o8[j],o9[j],o10[j],delr);
				k++;
				break;
			}
		}
		if(k==0)
		{
			fprintf(fnomatch,"%.3f %.3f %.3f %d %.3f %.3f %.3f %.3f %.3f %.3f\n",o1[j],o2[j],o3[j],o4[j],o5[j],o6[j],o7[j],o8[j],o9[j],o10[j]);	
		}
	}	
	fclose(fmatch);
	fclose(fnomatch);
}
