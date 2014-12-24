#include  <stdio.h>
#include  <math.h>
#include  <stdlib.h>
#include <sys/io.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
#define CriRadius 1.0
main()
{
        int     i,j,k,m,N0,N1,N2,NumCross;
	float	magmin,magmax,Numbin,magbin_minMax;
	float	magbin,RatioNum;
        float   rxc1,ryc2,rflux3,rflux4,rflux5,oxc1,oyc2,NumMagbin3;
        float   inputxc1,inputyc2;
	float	deltax,deltay,deltaxy,deltamag;
        float   x1[200000],x2[200000],x3[200000],x4[200000],x5[200000],k1[200000],k2[200000],k3[200000];
        FILE    *fp1;
        FILE    *fave,*favebin,*favebinNew;
        char    *refall, *objall;

        refall="refall_magbin.cat";
        objall="outputlimit.cat";

        printf("refall = %s\n",refall);
        printf("objall = %s\n",objall);

        i=0;
        j=0;
        m=0;
	magmin=8.0;
	magmax=14.0;
	favebin=fopen("newimg_magbin.cat","w+");

        fp1=fopen(refall,"r");
        if(fp1)
        {
	//	printf("#####refcom3d.cat#####");
                while((fscanf(fp1,"%f %f\n",&magbin_minMax,&NumMagbin3))!=EOF)
                {
                x1[i]=rxc1;
                x2[i]=ryc2;
                x3[i]=rflux3;
	//	x4[i]=rflux4;
	//	x5[i]=rflux5;
                i++;
                }
                N1=i;
        }
        fclose(fp1);

        fp1=fopen(objall,"r");
        if(fp1)
        {
	  //printf("#########image.cat###########3");
          while((fscanf(fp1,"%f %f %f \n",&oxc1,&oyc2,&NumMagbin3))!=EOF)
          {
          k1[m]=oxc1;
          k2[m]=oyc2;
          k3[m]=NumMagbin3;
          m++;
          }
          N2=m;
        }        
	fclose(fp1);

	for(magbin=magmin;magbin<magmax;magbin+0.1)
	{
		Numbin=0;
		for(m=0;m<N2;m++)
		{
			deltamag=magbin-x3[m];
			if(deltamag<0.5 && deltamag>=0)
			{
				Numbin++;
			}
			else if(deltamag>=0.5)
				{
					break;
				}
			fprintf(favebin,"%.1f %d \n",magbin,Numbin);
		}
	}
	
// to get the ratio of detected stars to full number USNO B2 stars
	objall="newimg_magbin.cat";
        fp1=fopen(objall,"r");
        if(fp1)
        {
	  //printf("#########image.cat###########3");
          while((fscanf(fp1,"%f %f %f \n",&magbin_minMax,&NumMagbin3))!=EOF)
          {
          k1[j]=oxc1;
          k2[j]=oyc2;
          k3[j]=NumMagbin3;
          j++;
          }
          N2=j;
        }
        fclose(fp1);

	favebinNew=fopen("newimgLimitmag.cat","w+");	
	for(j=0;j<N2;j++)
	{
		RatioNum=k3[j]-x3[j];
		fprintf(favebinNew,"%.1f %f \n",k3[j],RatioNum);
		if (RatioNum<15 && RatioNum>5)
		{
		//	printf("%.1f %f \n",k3[j],RatioNum);
			fprintf(favebinNew,"%.1f %f \n",k3[j],RatioNum);
		}
	}
	fclose(favebinNew);

}

