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
        int     i,k,m,N0,N2;
	float	rxc1,ryc2,rflux3,oxc1,oyc2,oflux3;
	float 	inputxc1,inputyc2;
        float   x1[50000],x2[50000],x3[50000],y4[50000],k1[50000],k2[50000],k3[50000];
        FILE    *fp1; 
//	FILE	*fp1,fp1;
	FILE	*fave;
	char    *refall, *objall;

	refall="ref.db";
	objall="obj.db";

//	printf("refall = %s\n",refall);
//	printf("objall = %s\n",objall);

	i=0;
	m=0;
	fave=fopen("refsmall_new","w+");
	
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

	
		for(i=0;i<N0;i++)
		{
			for(m=0;m<N2;m++)
				{
				if(abs(k1[m]-x1[i])<0.3 && abs(k2[m]-x2[i])<0.3 )
			 	{
					fprintf(fave,"%.3f %.3f %.3f %.3f %.3f %.3f\n",x1[i],x2[i],x3[i],k1[m],k2[m],k3[m]);
					break;
					}
				}
		}
	fclose(fave);
}
