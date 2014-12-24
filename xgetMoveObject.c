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
	float	ajd,sxc1,syc1,Rmag,cxc1,cyc1,cRmag,cRmerr,csxc1,csyc1,csRmag;
	float	sum,averagemag,diff,diff_sum,sigma;
        float   r1[50000],r2[50000],r3[50000],r11[50000],r17[50000],r21[50000],rsmag[50000];
        FILE    *fp1; 
	FILE	*fave;
	char    *refnew;

	refnew="lc_output.cat";
	i=0;
	fave=fopen("xlcavmagrmslist.cat","a+");
	sum=0;
	diff=diff_sum=0;
	averagemag=sigma=0;

	fp1=fopen(refnew,"r");	
	if(fp1)
	{
	        while((fscanf(fp1,"%f %f %f %f %f %f %f %d %f %f %f %f %f %f %f %f %f %f %f %f %f\n",&ajd,&sxc1,&syc1,&Rmag,&rxc1,&ryc1,&flux,&flag,&bg,&threshold,&mag,&merr,&elte,&class,&cxc1,&cyc1,&cRmag,&cRmerr,&csxc1,&csyc1,&csRmag))!=EOF)
	        {
                r1[i]=ajd;
		r2[i]=sxc1;
		r3[i]=syc1;
                r11[i]=mag;
		r17[i]=cRmag;
		r21[i]=csRmag;
		rsmag[i]=r11[i]-r17[i]+r21[i];
		sum=sum+rsmag[i];
		i++;
		}
		N1=i;
	}
	fclose(fp1);

	averagemag=sum/N1;
	for(i=0;i<N1;i++) //to calculate the sigma
        {
        diff = (rsmag[i]-averagemag)*(rsmag[i]-averagemag);
        diff_sum=diff_sum+diff;
	}
	sigma=sqrt(diff_sum/N1);
	fprintf(fave,"%.3f %.3f %d %.3f %.3f\n",r2[0],r3[0],N1,averagemag,sigma);

	fclose(fave);
}
