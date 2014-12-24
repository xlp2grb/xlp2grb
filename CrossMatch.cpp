/*
 * CrossMatch.cpp
 *
 *  Created on: 2012-11-21
 *      Author: chb
 */
#include <stdio.h>
#include <malloc.h>
#include "CrossMatch.h"
#include <string.h>
#include <vector>
#include <sys/time.h>
#include<stdlib.h>
#include <math.h>
using namespace std;

int	main(int argc, char *argv[])
{
  unsigned int tmpuint;
	if (argc<5)
	   {
		printf("argc=%d\n",argc);
		printf("CrossMatch needs 4 parameters: 1st is maxerr for matching \n");
		printf("                               2nd is image star table\n");
		printf("                               3nd is template table\n");
		printf("                               4nd is output filename\n");

	   }
	else
	   {
		tmpuint=atoi(argv[1]);
		printf("maxerr:%d \n",tmpuint);
		printf("image star:%s \n",argv[2]);
		printf("template:%s \n",argv[3]);
		printf("output:%s \n",argv[4]);

		if(CrossMatch(1024*3,1024*3,tmpuint,argv[2],argv[3],argv[4]))
            printf("everything is OK \n");
	   }
   return 1;
}

int CrossMatch(int imgcols,int imgrows,unsigned int maxerr,char imgtablename[],char templatename[],char outfilename[])
{
  char readbuf[512];
  unsigned char *imgtablemap,*templatemap;
  unsigned int *realimgstarmap,*tmpuintpt1,*tmpuintpt2;
  char *strpt;

  int status;
  unsigned int start,i,j,rline;
  unsigned int deltax,deltay,bx,ex,nx,by,ey,tmpn,nx2;
  unsigned int starnum,maxcorrect;
  float deltaxf,deltayf;
  vector<ST_STARSTRUCT> imgtablevec;
  vector<ST_STARSTRUCT> templatevec;
  ST_STARSTRUCT tmpstarstruct;
  FILE *filefp;
  struct timeval tv[6];
  gettimeofday(&tv[0], NULL);

  imgtablemap=(unsigned char *)malloc(imgcols*imgrows*sizeof(unsigned char));
  templatemap=(unsigned char *)malloc(imgcols*imgrows*sizeof(unsigned char));
  realimgstarmap=(unsigned int *)malloc(imgcols*imgrows*sizeof(unsigned int));

  if(imgtablemap!=NULL)
  	  memset(imgtablemap,0,imgcols*imgrows*sizeof(unsigned char));
    if(templatemap!=NULL)
    	memset(templatemap,0xff,imgcols*imgrows*sizeof(unsigned char));
    if(realimgstarmap!=NULL)
    	memset(realimgstarmap,0,imgcols*imgrows*sizeof(unsigned int));

    imgtablevec.clear();
    templatevec.clear();
    gettimeofday(&tv[1], NULL);
  filefp=fopen(templatename,"r");
  if(filefp!=NULL)
    {
	  while(!feof(filefp))
	  {

		  if((fgets(readbuf,512,filefp))!=NULL)
		    {
			  start=strspn(readbuf," \t");
			  strpt=readbuf+start;
			  if(*strpt!=(char)'#')
			  	  {
				  status=sscanf(strpt,"%f %f %f",&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.mag);


				  if(status)
				    {
					  templatevec.push_back(tmpstarstruct);
					  //pixcorrect(tmpstarstruct.x_image,tmpstarstruct.y_image,&deltax,&deltay);
					  deltax=deltay=maxerr;
					  bx=tmpstarstruct.x_image>(float)deltax?(unsigned int)(tmpstarstruct.x_image-deltax+0.5):0;
					  nx=(tmpstarstruct.x_image+deltax+1.5)<=(float)imgcols?(unsigned int)(tmpstarstruct.x_image+deltax+1.5)-bx:imgcols-bx;
					  					  //nx=(bx+deltax*2+1)<=(float)imgcols?deltax*2+1:imgcols-bx;
					  by=tmpstarstruct.y_image>(float)deltay?(unsigned int)(tmpstarstruct.y_image-deltay+0.5):0;
					  ey=(tmpstarstruct.y_image+deltay+1.5)<=(float)imgrows?(unsigned int)(tmpstarstruct.y_image+deltay+0.5):imgrows-1;
					  for(i=by;i<=ey;i++)
                          {
                    	    memset(&templatemap[i*imgcols+bx],0,nx);
                          }
				    }
			  	  }
		    }
	  }
	  fclose(filefp);
    }
  else
  {
	  printf("Cann't open %s \n",templatename);
	  return 0;

  }

  gettimeofday(&tv[2], NULL);
  starnum=0;
  filefp=fopen(imgtablename,"r");
    if(filefp!=NULL)
      {
  	  while(!feof(filefp))
  	  {

  		  if((fgets(readbuf,512,filefp))!=NULL)
  		    {
  			  start=strspn(readbuf," \t");
  			  strpt=readbuf+start;
  			  if(*strpt!=(char)'#')
  			  	  {
  				/*status=sscanf(strpt,"%f %f %d %f %f %f %f %d",&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.number,&tmpstarstruct.fluxerr_iso,&tmpstarstruct.mag_auto,&tmpstarstruct.magerr_auto,&tmpstarstruct.fwhm_image,&tmpstarstruct.flags);*/
  				status=sscanf(strpt,"%f %f %f %d %f %f %f %f %f %f",&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.flux,&tmpstarstruct.flag,&tmpstarstruct.bgflux,&tmpstarstruct.threshold,&tmpstarstruct.mag,&tmpstarstruct.merr,&tmpstarstruct.ellipticity,&tmpstarstruct.class_star);

  				  if(status)
  				    {
  					  pixcorrect(tmpstarstruct.x_image,tmpstarstruct.y_image,&deltaxf,&deltayf);
  					tmpstarstruct.x_image=(tmpstarstruct.x_image+deltaxf)>0?(tmpstarstruct.x_image+deltaxf)<(imgcols-1)?(tmpstarstruct.x_image+deltaxf):0.0:0.0;
  					tmpstarstruct.y_image=(tmpstarstruct.y_image+deltayf)>0?(tmpstarstruct.y_image+deltayf)<(imgrows-1)?(tmpstarstruct.y_image+deltayf):0.0:0.0;

  					  imgtablevec.push_back(tmpstarstruct);


  					  bx=(unsigned int)((float)tmpstarstruct.x_image+0.5);
  					  by=(unsigned int)((float)tmpstarstruct.y_image+0.5);
  					  imgtablemap[by*imgcols+bx]=0xFF;
  					  realimgstarmap[by*imgcols+bx]=starnum;
  					  starnum++;
  				    }
  			  	  }
  		    }
  	     }
  	  fclose(filefp);
      }
    else
      {
    	  printf("Cann't open %s \n",imgtablename);
    	  return 0;

      }
     /*match*/
    gettimeofday(&tv[3], NULL);
    maxcorrect=2*maxerr;
    bx=maxcorrect;
    nx2=nx=(imgcols-maxcorrect*2)/4;
    by=maxcorrect;
    ey=(imgrows-maxcorrect);


    for(i=by;i<ey;i++)
      {
    	rline=i*imgcols+bx;
    	tmpuintpt1=(unsigned int*)(&imgtablemap[rline]);
    	tmpuintpt2=(unsigned int*)(&templatemap[rline]);
    	nx=nx2;
    	while(nx--)
    	  {
    		*tmpuintpt1=(*tmpuintpt1)&(*tmpuintpt2);
    		tmpuintpt1++;
    		tmpuintpt2++;
    	  }
      }

   //record
    gettimeofday(&tv[4], NULL);
    filefp=fopen(outfilename,"w");
    ex=bx+4*nx2;
    for(i=by;i<ey;i++)
      {
    	rline=i*imgcols;
       for(j=bx;j<ex;j++)
           {
        	if(imgtablemap[rline+j])
        	   {
        		tmpn=realimgstarmap[rline+j];
        		if(imgtablevec.size()>tmpn)
        		   {
        			tmpstarstruct=imgtablevec[tmpn];
        			if(filefp!=NULL)
        			   {
        				/*fprintf(filefp,"%f %f %d %f %f %f %f %d \n",tmpstarstruct.x_image,tmpstarstruct.y_image,tmpstarstruct.number,tmpstarstruct.fluxerr_iso,tmpstarstruct.mag_auto,tmpstarstruct.magerr_auto,tmpstarstruct.fwhm_image,tmpstarstruct.flags);*/
        				fprintf(filefp,"%f %f %f %d %f %f %f %f %f %f \n",tmpstarstruct.x_image,tmpstarstruct.y_image,tmpstarstruct.flux,tmpstarstruct.flag,tmpstarstruct.bgflux,tmpstarstruct.threshold,tmpstarstruct.mag,tmpstarstruct.merr,tmpstarstruct.ellipticity,tmpstarstruct.class_star);


        			   }
        		   }
        	   }
           }

      }

    if(filefp!=NULL)
    	fclose(filefp);


  if(imgtablemap!=NULL)
	  free(imgtablemap);
  if(templatemap!=NULL)
	  free(templatemap);
  gettimeofday(&tv[5], NULL);

  printf("start time:%d s  %d us\n",tv[0].tv_sec,tv[0].tv_usec);
  printf("time before reading template:%d s  %d us\n",tv[1].tv_sec,tv[1].tv_usec);
  printf("time after reading template:%d s  %d us\n",tv[2].tv_sec,tv[2].tv_usec);
  printf("time after reading image table:%d s  %d us\n",tv[3].tv_sec,tv[3].tv_usec);
  printf("time after matching table:%d s  %d us\n",tv[4].tv_sec,tv[4].tv_usec);
  printf("end time after output:%d s  %d us\n",tv[5].tv_sec,tv[5].tv_usec);
  return 1;
}


int pixcorrect(float pixcol,float pixrow,float *deltax,float *deltay)
{
  *deltax=0.0;
  *deltay=0.0;
  return 1;
}

unsigned int maxpixcorrect()
{

   return 8;
}

/*
int CrossMatch_B(int imgcols,int imgrows,unsigned int maxerr,char imgtablename[],char templatename[],char outfilename[])
{
  char readbuf[512];
  unsigned char *imgtablemap,*templatemap;
  unsigned int *realimgstarmap;
  char *strpt;
  //int nRead;
  int status;
  unsigned int start,i,j;
  unsigned int deltax,deltay,nx,nx2;//bx,ex,nx,by,ey,tmpn,nx2;
  unsigned int starnum,maxcorrect;
  unsigned int minborderx,maxborderx,minbordery,maxbordery;
  vector<ST_STARSTRUCT> imgtablevec;
  vector<ST_STARSTRUCT> templatevec;
  ST_STARSTRUCT tmpstarstruct;
  FILE *filefp;
  struct timeval tv[6];
  float deltaxf,deltayf;


  gettimeofday(&tv[0], NULL);

  imgtablemap=(unsigned char *)malloc(imgcols*imgrows*sizeof(unsigned char));
  templatemap=(unsigned char *)malloc(imgcols*imgrows*sizeof(unsigned char));
  realimgstarmap=(unsigned int *)malloc(imgcols*imgrows*sizeof(unsigned int));

  if(imgtablemap!=NULL)
  	  memset(imgtablemap,0,imgcols*imgrows*sizeof(unsigned char));
    if(templatemap!=NULL)
    	memset(templatemap,0xff,imgcols*imgrows*sizeof(unsigned char));
    if(realimgstarmap!=NULL)
    	memset(realimgstarmap,0,imgcols*imgrows*sizeof(unsigned int));

    imgtablevec.clear();
    templatevec.clear();

    gettimeofday(&tv[1], NULL);
  filefp=fopen(templatename,"r");

  if(filefp!=NULL)
    {
	  while(!feof(filefp))
	  {

		  if((fgets(readbuf,512,filefp))!=NULL)
		    {
			  start=strspn(readbuf," \t");
			  strpt=readbuf+start;
			  if(*strpt!=(char)'#')
			  	  {
				   status=sscanf(strpt,"%f %f %d %f %f %f %f %d",&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.number,&tmpstarstruct.fluxerr_iso,&tmpstarstruct.mag_auto,&tmpstarstruct.magerr_auto,&tmpstarstruct.fwhm_image,&tmpstarstruct.flags);

				  if(status)
				    {
					  templatevec.push_back(tmpstarstruct);



				    }
			  	  }
		    }
	  }
	  fclose(filefp);
    }
  else
  {
	  printf("Cann't open %s \n",templatename);
	  return 0;

  }


  gettimeofday(&tv[2], NULL);
  starnum=0;
  filefp=fopen(imgtablename,"r");
// FILE *filefpx=fopen(outfilename,"w");
    if(filefp!=NULL)
      {
  	  while(!feof(filefp))
  	  {
  		  //nRead=fread(readbuf,1,512,filefp);
  		  if((fgets(readbuf,512,filefp))!=NULL)
  		    {
  			  start=strspn(readbuf," \t");
  			  strpt=readbuf+start;
  			  if(*strpt!=(char)'#')
  			  	  {
				   status=sscanf(strpt,"%f %f %d %f %f %f %f %d",&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.number,&tmpstarstruct.fluxerr_iso,&tmpstarstruct.mag_auto,&tmpstarstruct.magerr_auto,&tmpstarstruct.fwhm_image,&tmpstarstruct.flags);

  				   if(status)
  				    {
  					 //pixcorrect(tmpstarstruct.x_image,tmpstarstruct.y_image,&deltaxf,&deltayf);
  					//tmpstarstruct.x_image=(tmpstarstruct.x_image+deltaxf)>0?(tmpstarstruct.x_image+deltaxf)<(imgcols-1)?(tmpstarstruct.x_image+deltaxf):0.0:0.0;
  					//tmpstarstruct.y_image=(tmpstarstruct.y_image+deltayf)>0?(tmpstarstruct.y_image+deltayf)<(imgrows-1)?(tmpstarstruct.y_image+deltayf):0.0:0.0;

  					imgtablevec.push_back(tmpstarstruct);


  				    }
  			  	  }
  		    }
  	     }
  	  fclose(filefp);
      }
    else
      {
    	  printf("Cann't open %s \n",imgtablename);
    	  return 0;

      }

	//fclose(filefpx);
  //return 1;

     //match
    gettimeofday(&tv[3], NULL);
	nx=templatevec.size();
	nx2=imgtablevec.size();



	minbordery=minborderx=maxerr*2;
	maxborderx=imgcols-maxerr*2;
	maxbordery=imgrows-maxerr*2;
	deltax=deltay=maxerr;
	for(j=0;j<nx2;j++)
	  {
	     if((imgtablevec[j].x_image<=minborderx)||(imgtablevec[j].x_image>=maxborderx)||(imgtablevec[j].y_image<=minbordery)||(imgtablevec[j].y_image>=maxbordery))
		  {
		     imgtablemap[j]=0xFF;
			 continue;
		  }
	     for(i=0;i<nx;i++)
		   {
		     //pixcorrect(templatevec[i].x_image,templatevec[i].y_image,&deltax,&deltay);
		     if(fabs(imgtablevec[j].x_image-templatevec[i].x_image)<=(deltax))
		     {
		      if(fabs(imgtablevec[j].y_image-templatevec[i].y_image)<=(deltay))
			   {

				  imgtablemap[j]=0xFF;
				  break;
			    }
		     }
		   }
	  }




	gettimeofday(&tv[4], NULL);
	 filefp=fopen(outfilename,"w");
	 for(j=0;j<nx2;j++)
	 {
	   if(imgtablemap[j]==0)
	   {
			tmpstarstruct=imgtablevec[j];
        	if(filefp!=NULL)
        			   {
        				fprintf(filefp,"%f %f %d %f %f %f %f %d \n",tmpstarstruct.x_image,tmpstarstruct.y_image,tmpstarstruct.number,tmpstarstruct.fluxerr_iso,tmpstarstruct.mag_auto,tmpstarstruct.magerr_auto,tmpstarstruct.fwhm_image,tmpstarstruct.flags);
					   }
	   }
	 }
	 if(filefp!=NULL)
    	fclose(filefp);





  if(imgtablemap!=NULL)
	  free(imgtablemap);
  if(templatemap!=NULL)
	  free(templatemap);

  gettimeofday(&tv[5], NULL);
  printf("start time:%d s  %d us\n",tv[0].tv_sec,tv[0].tv_usec);
    printf("time before reading template:%d s  %d us\n",tv[1].tv_sec,tv[1].tv_usec);
    printf("time after reading template:%d s  %d us\n",tv[2].tv_sec,tv[2].tv_usec);
    printf("time after reading image table:%d s  %d us\n",tv[3].tv_sec,tv[3].tv_usec);
    printf("time after matching table:%d s  %d us\n",tv[4].tv_sec,tv[4].tv_usec);
    printf("end time after output:%d s  %d us\n",tv[5].tv_sec,tv[5].tv_usec);
  return 1;
}


int CrossMatch_C(int imgcols,int imgrows,unsigned int maxerr,char imgtablename[],char templatename[],char outfilename[])
{
  char readbuf[512];
  unsigned char *imgtablemap,*templatemap;
  unsigned int *realimgstarmap,*tmpuintpt1,*tmpuintpt2;
  char *strpt;
  int nRead;
  int status;
  unsigned int start,i,j,rline;
  unsigned int deltax,deltay,bx,ex,nx,by,ey,tmpn,nx2;
  unsigned int starnum,maxcorrect;
  vector<ST_STARSTRUCT> imgtablevec;
  vector<ST_STARSTRUCT> templatevec;
  ST_STARSTRUCT tmpstarstruct;
  FILE *filefp;
  //struct timeval tv_begin, tv_end;
  time_t t0,t1,t2,t3,t4;
  bool ifmatch=false;
  char tmpfileoutname[]="/home/chb/workspace/CrossMatch/Release/tmpout_A.cat";
  FILE *tmpoutfp;
  //gettimeofday(&tv_begin, NULL);

  //t0=time(NULL);
  imgtablemap=(unsigned char *)malloc(imgcols*imgrows*sizeof(unsigned char));
  templatemap=(unsigned char *)malloc(imgcols*imgrows*sizeof(unsigned char));
  realimgstarmap=(unsigned int *)malloc(imgcols*imgrows*sizeof(unsigned int));

  if(imgtablemap!=NULL)
  	  memset(imgtablemap,0,imgcols*imgrows*sizeof(unsigned char));
    if(templatemap!=NULL)
    	memset(templatemap,0xff,imgcols*imgrows*sizeof(unsigned char));
    if(realimgstarmap!=NULL)
    	memset(realimgstarmap,0,imgcols*imgrows*sizeof(unsigned int));

    imgtablevec.clear();
    templatevec.clear();

  filefp=fopen(templatename,"r");

  if(filefp!=NULL)
    {
	  while(!feof(filefp))
	  {

		  if((fgets(readbuf,512,filefp))!=NULL)
		    {
			  start=strspn(readbuf," \t");
			  strpt=readbuf+start;
			  if(*strpt!=(char)'#')
			  	  {
					  status=sscanf(strpt,"%f %f %d %f %f %f %f %d",&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.number,&tmpstarstruct.fluxerr_iso,&tmpstarstruct.mag_auto,&tmpstarstruct.magerr_auto,&tmpstarstruct.fwhm_image,&tmpstarstruct.flags);

				  if(status)
				    {
					  templatevec.push_back(tmpstarstruct);



				    }
			  	  }
		    }
	  }
	  fclose(filefp);
    }
  else
  {
	  printf("Cann't open %s \n",templatename);
	  return 0;

  }
  printf("templatename=%s num=%d\n",templatename,templatevec.size());
  //t1=time(NULL);

  starnum=0;
  filefp=fopen(imgtablename,"r");
// FILE *filefpx=fopen(outfilename,"w");
    if(filefp!=NULL)
      {
  	  while(!feof(filefp))
  	  {
  		  //nRead=fread(readbuf,1,512,filefp);
  		  if((fgets(readbuf,512,filefp))!=NULL)
  		    {
  			  start=strspn(readbuf," \t");
  			  strpt=readbuf+start;
  			  if(*strpt!=(char)'#')
  			  	  {
				   status=sscanf(strpt,"%f %f %d %f %f %f %f %d",&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.number,&tmpstarstruct.fluxerr_iso,&tmpstarstruct.mag_auto,&tmpstarstruct.magerr_auto,&tmpstarstruct.fwhm_image,&tmpstarstruct.flags);

  				   if(status)
  				    {
  					  imgtablevec.push_back(tmpstarstruct);


  				    }
  			  	  }
  		    }
  	     }
  	  fclose(filefp);
      }
    else
      {
    	  printf("Cann't open %s \n",imgtablename);
    	  return 0;

      }
    printf("imgtablename=%s num=%d\n",imgtablename,imgtablevec.size());
	//fclose(filefpx);
  //return 1;
	//t2=time(NULL);
     //match
	nx=templatevec.size();
	nx2=imgtablevec.size();

	tmpoutfp=fopen(tmpfileoutname,"w");
    if(tmpoutfp==NULL)
        printf("Cann't Open tmpoutfile=%s\n",tmpfileoutname);
	for(j=0;j<nx2;j++)
	  {
         if(imgtablevec[j].number==128)
               {
        	     printf("test1:%f %f %d\n",imgtablevec[j].x_image,imgtablevec[j].y_image,imgtablevec[j].number);
               }

	     if((imgtablevec[j].x_image<=10)||(imgtablevec[j].x_image>=3062)||(imgtablevec[j].y_image<=10)||(imgtablevec[j].y_image>=3062))
		  {
		     imgtablemap[j]=0xFF;

			 continue;
		  }
	     for(i=0;i<nx;i++)
		   {
		     //pixcorrect(templatevec[i].x_image,templatevec[i].y_image,&deltax,&deltay);
	    	 deltax=deltay=4;
	    	 if((imgtablevec[j].number==128)&&(templatevec[i].number==115))
	    	    {
	    		 printf("test2:%f %f\n",fabs(imgtablevec[j].x_image-templatevec[i].x_image),fabs(imgtablevec[j].y_image-templatevec[i].y_image));

	    	    }


		     if(fabs(imgtablevec[j].x_image-templatevec[i].x_image)<=(deltax))
		     {
		      if(fabs(imgtablevec[j].y_image-templatevec[i].y_image)<=(deltay))
			   {

				  imgtablemap[j]=0xFF;
				  if(tmpoutfp!=NULL)
				  		        {
				  		    	 fprintf(tmpoutfp,"%f %f %d                     %f %f %d\n",imgtablevec[j].x_image,imgtablevec[j].y_image,imgtablevec[j].number,
				  		    			templatevec[i].x_image,templatevec[i].y_image,templatevec[i].number);

				  		        }
				  break;
			    }
		     }
		   }
	  }

	 if(tmpoutfp!=NULL)
		 fclose(tmpoutfp);


	//t3=time(NULL);
	 filefp=fopen(outfilename,"w");
	 for(j=0;j<nx2;j++)
	 {
	   if(imgtablemap[j]==0)
	   {
			tmpstarstruct=imgtablevec[j];
        	if(filefp!=NULL)
        			   {
        				fprintf(filefp,"%f %f %d %f %f %f %f %d %d\n",tmpstarstruct.x_image,tmpstarstruct.y_image,tmpstarstruct.number,tmpstarstruct.fluxerr_iso,tmpstarstruct.mag_auto,tmpstarstruct.magerr_auto,tmpstarstruct.fwhm_image,tmpstarstruct.flags,j);
					   }
	   }
	 }
	 if(filefp!=NULL)
    	fclose(filefp);


	//t4=time(NULL);
	//printf("t0=%d;t1=%d;t2=%d;t3=%d;t4=%d \n",t0,t1,t2,t3,t4);

  if(imgtablemap!=NULL)
	  free(imgtablemap);
  if(templatemap!=NULL)
	  free(templatemap);
  return 1;
}*/




