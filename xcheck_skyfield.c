#include  <stdio.h>
#include  <math.h>
#include  <stdlib.h>
#include <sys/io.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
main()
{
        int     i,k,m,N0,N2;
	float	ra_sky,dec_sky,ra_mount,dec_mount;
	char    skyfield[50],idMountCamara[50];
        float   x1[5000],x2[5000],k1[5000],k2[5000],k3[5000],k4[5000];
	char    x3[200][500],k5[200][500],k6[200][500];
        FILE    *fp1; 
//	FILE	*fp1,fp1;
	FILE	*fave;
	char    *newCoord, *cata;

	newCoord="newimageCoord";
	cata="GPoint_catalog";
//the premeters in newimageCoord are ra_mount dec_mount ID_MountCamara
//the premeters in GPoint_catalog are ra_sky dec_sky ra_mount dec_mount "ID_MountCamara"_ra_sky"_"dec_sky ID_MountCamara
	//printf("newCoord = %s\n",newCoord);
	//printf("cata = %s\n",cata);

	i=0;
	m=0;
	fave=fopen("xcheckResult","w+");
	
	fp1=fopen(newCoord,"r");	
	if(fp1)
	{
	        while((fscanf(fp1,"%f %f %s\n",&ra_mount,&dec_mount,idMountCamara))!=EOF)
	        {
                x1[i]=ra_mount;
                x2[i]=dec_mount;
		strcpy(x3[i],idMountCamara);
		//x3[i]=idMountcamara;
		i++;
		}
		N0=i;
	}
	fclose(fp1);
	
	fp1=fopen(cata,"r");
        if(fp1)
        {
          while((fscanf(fp1,"%f %f %f %f %s %s\n",&ra_sky,&dec_sky,&ra_mount,&dec_mount,skyfield,idMountCamara))!=EOF)
          {
	  //printf("####\n");
          k1[m]=ra_sky;
          k2[m]=dec_sky;
	  k3[m]=ra_mount;
	  k4[m]=dec_mount;	
	  strcpy(k5[m],skyfield);
	  strcpy(k6[m],idMountCamara);
	 // printf("** skyfield is %s\n",skyfield);
	 // printf("** ,idMountCamara is %s\n",idMountCamara);
//	  printf("** k3[%d] is %s\n", m, k3[m]);
//          k3[m]=skyfield;
          m++;
          }
          N2=m;
        }
        fclose(fp1);

		for(i=0;i<N0;i++)
		{
			for(m=0;m<N2;m++)
				{
					if(abs(k3[m]-x1[i])<0.05 && abs(k4[m]-x2[i])<0.05 && strcmp(k6[m],x3[i])==0)
			 		{
						fprintf(fave,"%f %f %s %f %f %f %f %s %s \n",x1[i],x2[i],x3[i],k1[m],k2[m],k3[m],k4[m],k5[m],k6[m]);
						printf("%f %f %s %f %f %f %f %s %s\n",x1[i],x2[i],x3[i],k1[m],k2[m],k3[m],k4[m],k5[m],k6[m]);
						break;
					}
				}
		}
	fclose(fave);
}
