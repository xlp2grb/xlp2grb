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
	float	magmin,magmax,magbin_minMax;
	float	magbin;
    int     Numbin,NumMagbin3;
    float   rxc1,ryc2,oxc1,oyc2,omag3;
	float	deltax,deltay,deltaxy,deltamag;
    float   x1[200000],k1[200000],k2[200000],k3[200000];
    int     x3[200000];
    FILE    *fp1;
    FILE    *fave,*favebin;
    char    *refall, *objall;

    refall="refall_magbin.cat";
    objall="outputlimit.cat";

    //printf("refall = %s\n",refall);
    //printf("objall = %s\n",objall);

    i=0;
    j=0;
    m=0;
	magmin=8.0;
	magmax=14.0;

    fp1=fopen(refall,"r");
    if(fp1)
    {
	  //printf("#########refall_magbin.cat###########\n");
        while((fscanf(fp1,"%f %d\n",&magbin_minMax,&NumMagbin3))!=EOF)
        {
        x1[i]=magbin_minMax;
        x3[i]=NumMagbin3;
        i++;
        }
        N1=i;
    }
    fclose(fp1);
    //printf("N1=%d\n",N1);

    fp1=fopen(objall,"r");
    if(fp1)
     {
     //printf("#########outputlimit.cat###########\n");
        while((fscanf(fp1,"%f %f %f \n",&oxc1,&oyc2,&omag3))!=EOF)
        {
        k1[m]=oxc1;
        k2[m]=oyc2;
        k3[m]=omag3;
        m++;
        }
        N2=m;
        }        
	fclose(fp1);

	favebin=fopen("newimg_magbin.cat","w+");
	for(magbin=magmin;magbin<magmax;magbin+=0.1)
	{
    //    printf("magbin=%.1f\n",magbin);
		Numbin=0;
		for(m=0;m<N2;m++)
		{
    //        printf("m=%d\n",m);
			deltamag=magbin-k3[m];
			if(deltamag<0.1 && deltamag>=0)
			{
				Numbin++;
        //        printf("===Numbin=%d\n",Numbin);
			}
		}
			fprintf(favebin,"%.1f %d \n",magbin,Numbin);
	}
    fclose(favebin);	
}

