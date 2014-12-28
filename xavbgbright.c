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
	float	sum,averagebg,diff,diff_sum,sigma;
    float   r10[200000];
    FILE    *fp1; 
	FILE	*fave;
	char    *refnew;

	refnew="newbgbright.cat";
	i=0;
	fave=fopen("newbgbrightres.cat","a+");
	sum=0;
	diff=diff_sum=0;
	averagebg=sigma=0;

	fp1=fopen(refnew,"r");	
	if(fp1)
	{
	    while((fscanf(fp1,"%f %f %f %d %f %f %f %f %f %f \n",&rxc1,&ryc1,&flux,&flag,&bg,&threshold,&mag,&merr,&elte,&class))!=EOF)
	        {
                r10[i]=bg;
		        sum=sum+r10[i];
		        i++;
		    }
		N1=i;
	}
	fclose(fp1);

	averagebg=sum/N1;
//	for(i=0;i<N1;i++) //to calculate the sigma
//    {
//        diff = (r10[i]-averagebg)*(r10[i]-averagebg);
//        diff_sum=diff_sum+diff;
//	}
//	sigma=sqrt(diff_sum/N1);
//	fprintf(fave,"%.3f %.3f\n",averagebg,sigma);
	fprintf(fave,"%.0f\n",averagebg);

	fclose(fave);
}
