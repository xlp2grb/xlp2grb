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
        int     i,j,k,N1,N3,N;
	float 	max,min;
	float	rxc1,ryc2,mag,merr;
	char	time[50],image[50];
	float   delx,dely,delr,deltemag;
        float   r1[50000],r2[50000],r5[50000],r6[50000];
	char	r3[5000][50],r4[5000][50];
        FILE    *fp1; 
	FILE	*fbgVarStar,*fStableStar;
	FILE	*fmatch,*fnomatch,*fp;
	char    *refall;

	refall="updaterefcom3d.cat";
//	printf("refall = %s\n",refall);

	i=0;
	j=0;
	k=0;
	fmatch=fopen("uprefcom3d_match.cat","w+");
	fbgVarStar=fopen("VarableStar.cat","w+");
	fStableStar=fopen("StableStar.cat","w+");

	fp1=fopen(refall,"r");	
	if(fp1)
	{
	        while((fscanf(fp1,"%f %f %s %s %f %f \n",&rxc1,&ryc2,time,image,&mag,&merr))!=EOF)
	        {
                r1[i]=rxc1;
                r2[i]=ryc2;
		strcpy(r3[i],time);
		strcpy(r4[i],image);
		r5[i]=mag;
		r6[i]=merr;
		printf("%.3f %.3f %s %s %.3f %.3f\n",r1[i],r2[i],r3[i],r4[i],r5[i],r6[i]);
		i++;
		}
		N1=i;
	}
	
	fclose(fp1);

	printf("N1=%d\n",N1);	

//	printf("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&\n");	
//	for(i=0;i<N1;i++)
//	{
//		printf("%f %f %s %s %f %f\n",r1[i],r2[i],r3[i],r4[i],r5[i],r6[i]);
//	}


	j=0;
	while(j<N1)
	{
		for(i=j;i<N1;i++)
		{
			delx=r1[i]-r1[j];
			dely=r2[i]-r2[j];
			delr=sqrt(pow(delx,2)+pow(dely,2));
			if(delr<NPIX)
			{
//				printf("^^^^^^^^^^^^^^^^\n");
				fprintf(fmatch,"%f %f %s %s %f %f \n",r1[i],r2[i],r3[i],r4[i],r5[i],r6[i]);
//				printf("j=%d,i=%d\n",j,i);
//				printf("%f %f %s %s %f %f \n",r1[i],r2[i],r3[i],r4[i],r5[i],r6[i]);
			}
			else
			{
			//	printf("!!!!!!!!!!!!!!!!!!!!!!!\n");	
			//	printf("%f %f %s %s %f %f \n",r1[j],r2[j],r3[j],r4[j],r5[j],r6[j]);
//				printf("==================\n");
		//		max=0;
		//		min=0;
		//		printf("first j= %d,max= %f,min= %f ,r5[j]= %f \n",j,max,min,r5[j]);
				max=r5[j];
				min=r5[j];
//				printf("second j=%d,max=%f,min=%f,r5[j]=%f\n",j,max,min,r5[j]);
				for(k=j;k<i;k++)
				{	
					if(r5[k]>max) 
						max=r5[k];
					else if(r5[k]<min)
						min=r5[k];	
				}
				deltemag=max-min;
				N=i-j;
//				printf("max, min and deltemag are: %f, %f and %f\n", max,min,deltemag);
				if(deltemag>DMAG)
					fprintf(fbgVarStar,"%f %f %s %s %f %f %f %f %f %d\n",r1[j],r2[j],r3[j],r4[j],r5[j],r6[j],max,min,deltemag,N);
				else
					fprintf(fStableStar,"%f %f %s %s %f %f %f %f %f %d\n",r1[j],r2[j],r3[j],r4[j],r5[j],r6[j],max,min,deltemag,N);
				break;
			}
		}
	
	j=i++;

	}	
	fclose(fmatch);
	fclose(fbgVarStar);
	fclose(fStableStar);
}
