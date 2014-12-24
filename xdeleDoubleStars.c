#include  <stdio.h>
#include  <math.h>
#include  <stdlib.h>
#include <sys/io.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
//#define CriRadius 1
main()
{
        int     i,j,k,m,N0,N1,N2,NumCross;
        float   rxc1,ryc2,rflux3,oxc1,oyc2,oflux3,oflux4,oflux5,oflux6,oflux7;
        float   inputxc1,inputyc2;
	float   CriRadius;
	float	deltax,deltay,deltaxy;
        float   x1[200000],x2[200000],x3[200000],k1[200000],k2[200000],k3[200000],k4[200000],k5[200000],k6[200000],k7[200000];
        FILE    *fp1;
        FILE    *fave,*faved;
        char    *refall, *objall;

        refall="refcom3d.cat";
        objall="4p.xymagnew";

        printf("refall = %s\n",refall);
        printf("objall = %s\n",objall);

        i=0;
        j=0;
        m=0;
        fave=fopen("4pxymagnewDeleDoubleStardiffRadius.cat","w+");
	faved=fopen("4pxymagnewDeleDoubleStardiffRadiusDele.cat","w+");

        fp1=fopen(refall,"r");
        if(fp1)
        {
	//	printf("#####refcom3d.cat#####");
                while((fscanf(fp1,"%f %f %f \n",&rxc1,&ryc2,&rflux3))!=EOF)
                {
                x1[i]=rxc1;
                x2[i]=ryc2;
                x3[i]=rflux3;
                i++;
                }
                N1=i;
        }
        fclose(fp1);

        fp1=fopen(objall,"r");
        if(fp1)
        {
	  //printf("#########image.cat###########3");
          while((fscanf(fp1,"%f %f %f %f %f %f %f\n",&oxc1,&oyc2,&oflux3,&oflux4,&oflux5,&oflux6,&oflux7))!=EOF)
          {
          k1[m]=oxc1;
          k2[m]=oyc2;
          k3[m]=oflux3;
	  k4[m]=oflux4;
	  k5[m]=oflux5;
	  k6[m]=oflux6;
	  k7[m]=oflux7;	
          m++;
          }
          N2=m;
        }
        fclose(fp1);
        
	for(m=0;m<N2;m++)
        {
	      NumCross=0;	
	      CriRadius=sqrt((k4[m]-k3[m])*(k4[m]-k3[m])+(k6[m]-k5[m])*(k6[m]-k5[m]))/2;
	      //printf("%.3f\n", CriRadius); 
	       	      for(i=0;i<N1;i++)
                      {
			deltax=x1[i]-k1[m];
			deltay=x2[i]-k2[m];
			deltaxy=sqrt(deltax*deltax+deltay*deltay);
                      	if(deltaxy<CriRadius)
			{
			  NumCross++;
			}
                      }
			if(NumCross<2)
				fprintf(fave,"%.3f  %.3f  %.3f  %.3f  %.3f  %.3f  %.3f  %d  %.3f\n",k1[m],k2[m],k3[m],k4[m],k5[m],k6[m],k7[m],NumCross,CriRadius);
			else
				fprintf(faved,"%.3f  %.3f  %.3f  %.3f  %.3f  %.3f  %.3f  %d  %.3f\n",k1[m],k2[m],k3[m],k4[m],k5[m],k6[m],k7[m],NumCross,CriRadius);
			
        }
        fclose(fave);
	fclose(faved);
}

