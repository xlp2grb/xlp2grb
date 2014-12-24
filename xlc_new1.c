#include  <stdio.h>
#include  <math.h>
#include  <stdlib.h>
#include <sys/io.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
//#include <syslib.h>
#define NPIX  1.0
#define DMAG  0.3 //variation of the brightness for an object.
main()
{
        int     i,j,k,N1,N3,N,m,Nmax,Nmin;
	float 	maxmag,minmag,maxtime,mintime;
	float	ra,dec,rxc1,ryc2,rxt1,ryt2,mag,merr,elte,timeh;
	char	time[50],image[50];
	float   delx,dely,delr,deltemag;
        float   r1[50000],r2[50000],r3[50000],r4[50000],r5[50000],r6[50000],r8[50000],r10[50000],r11[50000],r12[50000];
	int	t[50000]={0};
	char	r7[50000][50],r9[50000][50];
        FILE    *fp1; 
	FILE	*fbgVarStar,*fStableStar;
	FILE	*fmatch,*fnomatch,*fp;
	char    *refall;

	refall="newframeOT.obj";
	printf("refall = %s\n",refall);

	i=0;
	j=0;
	k=0;
	fmatch=fopen("upnewframeOT.obj","w+");
	fbgVarStar=fopen("newVarableStar.cat","w+");
	fStableStar=fopen("newStableStar.cat","w+");

	fp1=fopen(refall,"r");	
	if(fp1)
	{
	        while((fscanf(fp1,"%f %f %f %f %f %f %s %f %s %f %f %f\n",&ra,&dec,&rxc1,&ryc2,&rxt1,&ryt2,time,&timeh,image,&mag,&merr,&elte))!=EOF)
	        {
                r1[i]=ra;
		r2[i]=dec;
		r3[i]=rxc1;
                r4[i]=ryc2;
		r5[i]=rxt1;
		r6[i]=ryt2;
		strcpy(r7[i],time);
		r8[i]=timeh;
		strcpy(r9[i],image);
		r10[i]=mag;
		r11[i]=merr;
		r12[i]=elte;
//		printf("%.3f %.3f %.3f %.3f %.3f %.3f %s %.3f %s %.3f %.3f %.3f\n",r1[i],r2[i],r3[i],r4[i],r5[i],r6[i],r7[i],r8[i],r9[i],r10[i],r11[i],r12[i]);
		i++;
		}
		N1=i;
	}
	
	fclose(fp1);

	printf("N1=%d\n",N1);	


	j=0;
	while(j<N1)
	{
		N=0;
		for(i=j;i<N1;i++)
		{
			if(t[i]==0)
			{	delx=r5[i]-r5[j];
				dely=r6[i]-r6[j];
				delr=sqrt(pow(delx,2)+pow(dely,2));
				if(delr<NPIX)
				{
	//			printf("%f %f %f %f %f %f  %s %f %s %f %f %f \n",r1[i],r2[i],r3[i],r4[i],r5[i],r6[i],r7[i],r8[i],r9[i],r10[i],r11[i],r12[i]);
				t[i]=j;
				fprintf(fmatch,"%f %f %f %f %f %f  %s %f %s %f %f %f %d\n",r1[i],r2[i],r3[i],r4[i],r5[i],r6[i],r7[i],r8[i],r9[i],r10[i],r11[i],r12[i],t[i]);
				N=N++;
				}
			}
		}
		if(N>=1)
		{
	//	 	printf("@@@@@@@@@@@@@@@@@@@@@@@@@@\n");
			maxtime=r8[j];
			mintime=r8[j];
	                maxmag=r10[j];
        	        minmag=r10[j];
			for(i=j;i<N1;i++)
		  	{
				if(t[i]==j)
				{
                	                if(r8[i]>maxtime)
                        	                 maxtime=r8[i];
                                	else if(r8[i]<mintime)
                                        	 mintime=r8[i];
	                                if(r10[i]>maxmag)
        	                        	{
							maxmag=r10[i];
							Nmax=i;
						}
                	                else if(r10[i]<minmag)
                        	                {
							minmag=r10[i];
							Nmin=i;
						}
				}
		 	}
                 	for(i=j;i<N1;i++)
                 	{
				if(t[i]==j)
				{
                        		if(r8[i]==mintime)
                                		{ 
							m=i;    
	//						printf("m=%d\n",m);
						}
				}
                 	}
                 	deltemag=maxmag-minmag;
	//		printf("second m=%d\n",m);
                 	if(deltemag>DMAG)
                        	 fprintf(fbgVarStar,"%f %f %f %f %f %f %s %f %s %f %f %f %s %s %f %f %f %d\n",r1[m],r2[m],r3[m],r4[m],r5[m],r6[m],r7[m],r8[m],r9[m],r10[m],r11[m],r12[m],r9[Nmax],r9[Nmin],maxmag,minmag,deltemag,N);
                 	else
                        	 fprintf(fStableStar,"%f %f %f %f %f %f %s %f %s %f %f %f %s %s %f %f %f %d\n",r1[m],r2[m],r3[m],r4[m],r5[m],r6[m],r7[m],r8[m],r9[m],r10[m],r11[m],r12[m],r9[Nmax],r9[Nmin],maxmag,minmag,deltemag,N);
		}
	j=j++;  
	}
	fclose(fmatch);
	fclose(fbgVarStar);
	fclose(fStableStar);
}
