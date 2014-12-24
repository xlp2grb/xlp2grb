#include  <stdio.h>
#include  <math.h>
#include  <stdlib.h>
#include <sys/io.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
//#include <syslib.h>
#define NPIX  1.0
#define DMAG  0.2 //variation of the brightness for an object.
main()
{
        int     i,j,k,N1,N3,N,m;
	float 	max,min,maxtime,mintime;
	float	ra,dec,rxc1,ryc2,rxt1,ryt2,mag,merr,elte,timeh;
	char	time[50],image[50];
	float   delx,dely,delr,deltemag;
        float   r1[50000],r2[50000],r3[50000],r4[50000],r5[50000],r6[50000],r8[50000],r10[50000],r11[50000],r12[50000];
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
		printf("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&\n"); 
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
		printf("%.3f %.3f %.3f %.3f %.3f %.3f %s %.3f %s %.3f %.3f %.3f\n",r1[i],r2[i],r3[i],r4[i],r5[i],r6[i],r7[i],r8[i],r9[i],r10[i],r11[i],r12[i]);
		i++;
		}
		N1=i;
	}
	
	fclose(fp1);

	printf("N1=%d\n",N1);	


	j=0;
	while(j<N1)
	{
		for(i=j;i<N1;i++)
		{
			delx=r5[i]-r5[j];
			dely=r6[i]-r6[j];
			delr=sqrt(pow(delx,2)+pow(dely,2));
			if(delr<NPIX)
			{
				fprintf(fmatch,"%f %f %f %f %f %f  %s %f %s %f %f %f \n",r1[i],r2[i],r3[i],r4[i],r5[i],r6[i],r7[i],r8[i],r9[i],r10[i],r11[i],r12[i]);
			}
			else
			{
				maxtime=r8[j];
				mintime=r8[j];
				for(k=j;k<i;k++)
				{
					if(r8[k]>maxtime)
						maxtime=r8[k];
					else if(r8[k]<mintime)
						mintime=r8[k];
				}
				for(k=j;k<i;k++)
				{
					if(r8[k]==mintime)
						m=k;					
				}
				
				max=r10[j];
				min=r10[j];
				for(k=j;k<i;k++)
				{	
					if(r10[k]>max) 
						max=r10[k];
					else if(r10[k]<min)
						min=r10[k];	
				}
				N=i-j;
				deltemag=max-min;
				if(deltemag>DMAG)
					fprintf(fbgVarStar,"%f %f %f %f %f %f %s %f %s %f %f %f %f %f %f %d\n",r1[m],r2[m],r3[m],r4[m],r5[m],r6[m],r7[m],r8[m],r9[m],r10[m],r11[m],r12[m],max,min,deltemag,N);
				else
					fprintf(fStableStar,"%f %f %f %f %f %f %s %f %s %f %f %f %f %f %f %d\n",r1[m],r2[m],r3[m],r4[m],r5[m],r6[m],r7[m],r8[m],r9[m],r10[m],r11[m],r12[m],max,min,deltemag,N);
				break;
			}
		}
	
	j=i++;

	}	
	fclose(fmatch);
	fclose(fbgVarStar);
	fclose(fStableStar);
}
