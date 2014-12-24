#include  <stdio.h>
#include  <math.h>
#include  <stdlib.h>
#include <sys/io.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
//#include <syslib.h>
#define NPIX  1
#define NPIX_CO 500
main()
{
        int     i,j,k,N1,N3,N,m,Nmax,Nmin;
	int	Nc,n;
	float	rxc1,ryc1,flux,bg,threshold,mag,merr,elte,class;
	int	flag;
	float   delx,dely,delr,delcr,delcor;
        float   r1[50000],r2[50000],r3[50000],r5[50000],r6[50000],r7[50000],r8[50000],r9[50000],r10[50000];
	int	r4[50000];
	float	s1[500],s2[500],c1[5000],c2[5000],c3[5000],co1[20],co2[20],co3[20];
        FILE    *fp1; 
	FILE	*fmatch;
	char    *refnew,*refstarlist,*compstar;

	refnew="starinnewimg.lc.cat1";
	refstarlist="inputstarlist.cat";
	compstar="inputcomplist.cat";
//	printf("refnew = %s\n",refnew);

	i=0;
	fmatch=fopen("output_inputstarlist.cat","w+");


// read the star catalog list for match.
	fp1=fopen(refnew,"r");	
	if(fp1)
	{
	        while((fscanf(fp1,"%f %f %f %d %f %f %f %f %f %f\n",&rxc1,&ryc1,&flux,&flag,&bg,&threshold,&mag,&merr,&elte,&class))!=EOF)
	        {
                r1[i]=rxc1;
		r2[i]=ryc1;
		r3[i]=flux;
                r4[i]=flag;
		r5[i]=bg;
		r6[i]=threshold;
		r7[i]=mag;
		r8[i]=merr;
		r9[i]=elte;
		r10[i]=class;
//		printf("%0.3f %0.3f %0.3f %d %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f\n",r1[i],r2[i],r3[i],r4[i],r5[i],r6[i],r7[i],r8[i],r9[i],r10[i]);
		i++;
		}
		N1=i;
	}
	fclose(fp1);
//	printf("N1=%d\n",N1);	


// read the obj coordnates.	
	i=0;
	k=0;
	fp1=fopen(refstarlist,"r");
	if(fp1)
	{
		while((fscanf(fp1,"%f %f\n",&rxc1,&ryc1))!=EOF)
		{
		s1[k]=rxc1;
                s2[k]=ryc1;
		k++;
		}
	}
	fclose(fp1);

// read the compared star list
        j=0;
        fp1=fopen(compstar,"r");
        if(fp1)
        {
                while((fscanf(fp1,"%f %f %f\n",&rxc1,&ryc1,&mag))!=EOF)
                {
                c1[j]=rxc1;
                c2[j]=ryc1;
		c3[j]=mag;
                j++;
                }
		Nc=j;
        }
        fclose(fp1);

// choose the compare star for this obj.
	 co1[0]=c1[0];
         co2[0]=c2[0];
         co3[0]=c3[0];
	for(n=0;n<Nc;n++)
	{
		delx=c1[n]-s1[0];
		dely=c2[n]-s2[0];
		delcor=sqrt(pow(delx,2)+pow(dely,2));
		if(delcor<NPIX_CO)
		{
			co1[0]=c1[n];
			co2[0]=c2[n];
			co3[0]=c3[n];	
		}	

	}

	printf("%f %f %f %f %f\n",co1[0],co2[0],co3[0],s1[0],s2[0]);


	k=0;
//	j=0;
//	printf("%.3f %.3f\n",s1[k],s2[k]);
		for(i=0;i<N1;i++)
		{
				delx=s1[k]-r1[i];
				dely=s2[k]-r2[i];
				delr=sqrt(pow(delx,2)+pow(dely,2));
				if(delr<NPIX)
				{
					printf("@@@@@@@@@@@@@@\n");
					printf("delr=%f\n",delr);
					for(m=0;m<N1;m++)
					{
						delx=co1[0]-r1[m];
						dely=co2[0]-r2[m];
						delcr=sqrt(pow(delx,2)+pow(dely,2));
						if(delcr<NPIX)
						{
							printf("delcr=%f\n",delcr);
							fprintf(fmatch,"%0.3f %0.3f %0.3f %d %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f\n",r1[i],r2[i],r3[i],r4[i],r5[i],r6[i],r7[i],r8[i],r9[i],r10[i],r1[m],r2[m],r7[m],r8[m],co1[0],co2[0],co3[0]);
							break;
						}
					}
				}
		}
	fclose(fmatch);
}
