#include  <stdio.h>
#include  <math.h>
#include  <stdlib.h>
#include <sys/io.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
//#include <syslib.h>
#define NPIX  1
main()
{
        int     i,j,k,N1,N3,N,m,Nmax,Nmin;
	int	Nc,Ns,n,Navrms;
	float	rxc1,ryc1,flux,bg,threshold,mag,merr,elte,class;
	float	avmag,rms,Nimage;
	int	flag;
	float   delx,dely,delr,delcr,delcor,MIN_OC;
	double	jd;
        float   r1[50000],r2[50000],r3[50000],r5[50000],r6[50000],r7[50000],r8[50000],r9[50000],r10[50000];
	int	r4[50000];
	float	s1[10000],s2[10000],s3[10000],c1[5000],c2[5000],c3[5000],co1[20],co2[20],co3[20];
	float	avrms1[50000],avrms2[50000],avrms3[50000],avrms4[50000],avrms5[50000];
	double 	ajd[50];
        FILE    *fp1; 
	FILE	*fmatch;
	char    *imagecatalog,*refstarlist,*compstar,*imagejd,*avmagrms;

	char *fileName = (char*)malloc(1024*sizeof(char));

	MIN_OC=6000;

	imagecatalog="starinnewimg.lc.cat1";
	refstarlist="inputstarlist.cat";
	compstar="inputcomplist.cat";
	imagejd="obstimejd";
	avmagrms="xaveragermslist"
//	printf("refnew = %s\n",refnew);

	i=0;
//	fmatch=fopen("output_inputstarlist.cat","w+");


// read the star catalog list for match.
	fp1=fopen(imagecatalog,"r");	
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

// read the jd from obstimejd for this image
// only one data in this file.
        i=0;
        fp1=fopen(imagejd,"r");
        if(fp1)
        {
                while((fscanf(fp1,"%lf\n",&jd))!=EOF)
                {
                ajd[i]=jd;
		printf("jd=%.8f",ajd[i]);
                i++;
                }
        }
        fclose(fp1);

// read the avmag and rms for the star list
        i=0;
        fp1=fopen(avmagrms,"r");
        if(fp1)
        {
                while((fscanf(fp1,"%f %f %f %f %d\n",&rxc1,&ryc1,&avmag,&rms,&Nimage))!=EOF)
                {
                avrms1[i]=rxc1;
		avrms2[i]=ryc1;
		avrms3[i]=avmag;
		avrms4[i]=rms;
		avrms5[i]=Nimage;
                i++;
                }
		Navrms=i;
        }
        fclose(fp1);

// read the obj coordnates.	
	i=0;
	k=0;
	fp1=fopen(refstarlist,"r");
	if(fp1)
	{
		while((fscanf(fp1,"%f %f %f\n",&rxc1,&ryc1,&mag))!=EOF)
		{
		s1[k]=rxc1;
                s2[k]=ryc1;
		s3[k]=mag;
		k++;
		}
		Ns=k;
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

	//for(k=0;k<Ns;k++)
	for(i=0;i<N1;i++) //for the star list in the new image
	{	
		for(k=0;k<Ns;k++) // for the star list in the temp image
		//for(i=0;i<N1;i++)
		{
			if(r7[i]<19.0) // delete the data with wrong mag 
			{
				delx=s1[k]-r1[i];
				dely=s2[k]-r2[i];
				delr=sqrt(pow(delx,2)+pow(dely,2));
				if(delr<NPIX)
				{
					printf("@@@@@@@@@@@@@@\n");
					printf("delr=%f\n",delr);
					// choose the compare star for this obj.
					// 
					for(n=0;n<Nc;n++)  
					{
						delx=c1[n]-s1[k];
						dely=c2[n]-s2[k];
						delcor=sqrt(pow(delx,2)+pow(dely,2));
						if(delcor<MIN_OC)
						{
            				            co1[0]=c1[n];
            				            co2[0]=c2[n];
            				            co3[0]=c3[n];
            				            MIN_OC=delcor;
            				        }
					}
					//
					for(m=0;m<N1;m++)  // to match the comp. star in the new image star list
					{
						delx=co1[0]-r1[m];
						dely=co2[0]-r2[m];
						delcr=sqrt(pow(delx,2)+pow(dely,2));
						if(delcr<NPIX)
						{
							printf("delcr=%f\n",delcr);
							printf("jd=%.8f\n",ajd[0]);
							//define the output file for temp star
							//name is xc_yc-rmag.cat.output
							//in wich xc is s1[k],yc is s2[k],rmag is s3[k];
							sprintf(fileName, "abc%f_%f_%.3f.cat.output", s1[k], s2[k], s3[k]);
							fmatch=fopen(fileName, "a+");
							fprintf(fmatch,"%.8f %0.3f %0.3f %0.3f  %0.3f %0.3f %0.3f %d %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f\n",ajd[0],s1[k],s2[k],s3[k],r1[i],r2[i],r3[i],r4[i],r5[i],r6[i],r7[i],r8[i],r9[i],r10[i],r1[m],r2[m],r7[m],r8[m],co1[0],co2[0],co3[0]);
							fclose(fmatch);
							
							//======================== have not finished
							fmatch=fopen(avmagrms, "a+");
							Objmag[0]=r7[i]-r7[m]+co3[0];
							for(j=0;j<Navrms;j++)
							{
								avrms1[i]
								avrms2[i]
								avrms3[i]
								avrms	
							}
							fprintf(fmatch,"%0.3f %0.3f %0.3f  %0.3f %d",);
							fclose(fmatch);
							//========================
							break;
						}
					
					}
				}
			}
		}
	}
free(fileName);
}
