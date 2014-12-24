#include  <stdio.h>
#include  <math.h>
#include  <stdlib.h>
#include <sys/io.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
#define xc 1528
#define yc 1528
#define rc 1500  // 1635,90% pixel will be in the inner file
#define MAXNUM 100000
main()
{
        int     i,k,m,N0,N2;
	float	xcc,ycc,flux,bg,trierod,mag,merr,ell,eclass,dr;
	int	flag;
        //float   x1[100000],x2[100000],x3[100000],x5[100000],x6[100000],x7[100000],x8[100000],x9[100000],x10[100000];
        float   x1[MAXNUM],x2[MAXNUM],x3[MAXNUM],x5[MAXNUM],x6[MAXNUM],x7[MAXNUM],x8[MAXNUM],x9[MAXNUM],x10[MAXNUM];
	int	x4[MAXNUM];
        FILE    *fp1; 
	FILE	*fave1;
	FILE 	*fave2;
	char    *newCoord;

	newCoord="xcrossInnerOuterStar.cat";
	fave1=fopen("xcrossInnerOuterStar.inner","w+");
	fave2=fopen("xcrossInnerOuterStar.outer","w+");
	
	fp1=fopen(newCoord,"r");	
	i=0;
	if(fp1)
	{
	        while((fscanf(fp1,"%f %f %f %d %f %f %f %f %f %f\n",&xcc,&ycc,&flux,&flag,&bg,&trierod,&mag,&merr,&ell,&eclass))!=EOF)
	        {
                x1[i]=xcc;
                x2[i]=ycc;
		x3[i]=flux;
		x4[i]=flag;
		x5[i]=bg;
		x6[i]=trierod;
		x7[i]=mag;
		x8[i]=merr;
		x9[i]=ell;
		x10[i]=eclass;
		i++;
		}
		N0=i;
	}
	fclose(fp1);
	
		for(i=0;i<N0;i++)
		{
			dr=sqrt((x1[i]-xc)*(x1[i]-xc)+(x2[i]-yc)*(x2[i]-yc));
			if(dr<rc)
			{
				fprintf(fave1,"%f %f %f %d %f %f %f %f %f %f\n",x1[i],x2[i],x3[i],x4[i],x5[i],x6[i],x7[i],x8[i],x9[i],x10[i]);
			}
			else
			{
				fprintf(fave2,"%f %f %f %d %f %f %f %f %f %f\n",x1[i],x2[i],x3[i],x4[i],x5[i],x6[i],x7[i],x8[i],x9[i],x10[i]);
			}
		}
	fclose(fave1);
	fclose(fave2);
}
