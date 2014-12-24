#include  <stdio.h>
#include  <math.h>
#include  <stdlib.h>
#include <sys/io.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
//#include <syslib.h>
main()
{
        int     i,j,k,m,N0,N1,N2;
	float	rxc1,ryc2,rflux3,oxc1,oyc2,oflux3;
	float 	inputxc1,inputyc2;
        float   x1[5000],x2[5000],x3[5000],y1[5000],y2[5000],y3[5000],y4[5000],k1[5000],k2[5000],k3[5000];
        FILE    *fp1; 
//	FILE	*fp1,fp1;
	FILE	*fave;
	char    *refall, *refsmall,*objall;

	refall="ref.db";
	objall="obj.db";
	refsmall="mattmp.db";

//	printf("refall = %s\n",refall);
//	printf("refsmall = %s\n",refsmall);
//	printf("objall = %s\n",objall);

	i=0;
	j=0;
	m=0;
	fave=fopen("diffmatch.cat","w+");
	
	fp1=fopen(refall,"r");	
	if(fp1)
	{
	        while((fscanf(fp1,"%f %f %f \n",&rxc1,&ryc2,&rflux3))!=EOF)
	        {
                x1[i]=rxc1;
                x2[i]=ryc2;
                x3[i]=rflux3;
		//printf("%.3f %.3f %.3f\n",x1[i],x2[i],x3[i]);
		i++;
		}
		N0=i;
	}
	fclose(fp1);
	
	fp1=fopen(refsmall,"r");	
	if(fp1)
	{
          while((fscanf(fp1,"%f %f %f  %f\n",&rxc1,&ryc2,&inputxc1,&inputyc2))!=EOF)
          {
          y1[j]=rxc1;
          y2[j]=ryc2;
	  y3[j]=inputxc1;
	  y4[j]=inputyc2;
          j++;
          }
	  N1=j;
	}
	fclose(fp1);
	
	fp1=fopen(objall,"r");
        if(fp1)
        {
//	  printf("####\n");
          while((fscanf(fp1,"%f %f %f \n",&oxc1,&oyc2,&oflux3))!=EOF)
          {
          k1[m]=oxc1;
          k2[m]=oyc2;
          k3[m]=oflux3;
          m++;
          }
          N2=m;
        }
        fclose(fp1);

	
	for(j=0;j<N1;j++)
	{
		for(i=0;i<N0;i++)
		{
			for(m=0;m<N2;m++)
				{
				if(y1[j]==x1[i] && y2[j]==x2[i] && y3[j]==k1[m] && y4[j]==k2[m])
				 	fprintf(fave,"%.3f %.3f %.3f %.3f %.3f %.3f\n",x1[i],x2[i],x3[i],k1[m],k2[m],k3[m]);
				}
		}
	}	
	fclose(fave);
}
