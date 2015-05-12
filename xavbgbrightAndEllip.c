#include  <stdio.h>
#include  <math.h>
#include  <stdlib.h>
#include <sys/io.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
main()
{
    int     i,j,k,N1,N3,N,m,Nmax,Nmin;
	float	rxc1,ryc1,flux,bg,threshold,mag,merr,elte,class;
	int	flag;
	float	sumbg,averagebg;
    float   sumEllip,averageEllip;
    float   r5[200000],r9[200000];
    FILE    *fp1; 
	FILE	*fave;
	char    *refnew;

	refnew="newbgbright.cat";
	i=0;
	fave=fopen("newbgbrightres.cat","a+");
	sumbg=0;
	averagebg=averageEllip=0;
	sumEllip=0;

	fp1=fopen(refnew,"r");	
	if(fp1)
	{
	    while((fscanf(fp1,"%f %f %f %d %f %f %f %f %f %f \n",&rxc1,&ryc1,&flux,&flag,&bg,&threshold,&mag,&merr,&elte,&class))!=EOF)
	        {
                r5[i]=bg;
                r9[i]=elte;
		sumbg=sumbg+r5[i];
                sumEllip=sumEllip+r9[i];
		i++;
		}
		N1=i;
	}
	fclose(fp1);

		averagebg=sumbg/N1;
	    averageEllip=sumEllip/N1;
	fprintf(fave,"%.1f   %.3f\n",averagebg, averageEllip);
	fclose(fave);
}
