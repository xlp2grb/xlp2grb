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
	float tmpfloat,tmpfloat2;
	if (argc<6)
	{
		printf("argc=%d\n",argc);
		printf("CrossMatch needs 4 parameters: 1st is maxerr for matching \n");
		printf("                               2nd is magerr for matching\n");
		printf("                               3nd is image star table\n");
		printf("                               4nd is template table\n");
		printf("                               5nd is output filename\n");

	}
	else
	{
		//tmpuint=atoi(argv[1]);
		tmpfloat=atof(argv[1]);
		printf("maxerr:%f \n",tmpfloat);
		tmpfloat2=atof(argv[2]);
		printf("magerr:%f\n",tmpfloat2);
		printf("image star:%s \n",argv[3]);
		printf("template:%s \n",argv[4]);
		printf("output:%s \n",argv[5]);

		if(CrossMatch_C(1024*3,1024*3,tmpfloat,tmpfloat2,argv[3],argv[4],argv[5]))
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




int CrossMatch_C(int imgcols,int imgrows,float maxerr,float magerr,char imgtablename[],char templatename[],char outfilename[])
{

	char readbuf[512];
	//unsigned int *imgtablemap;
	ST_PIXMAP *templatemap;
	//unsigned int *realimgstarmap,*tmpuintpt1,*tmpuintpt2;
	float maxerrd=maxerr*maxerr;
	float magerrabs=fabs(magerr);
	char *strpt;

	int status;
	unsigned int start,i,j,rline;
	unsigned int deltax,deltay,bx,ex,nx,by,ey,tmpn,nx2;
	unsigned int starnum,maxcorrect;
	float deltaxf,deltayf;
	float mindis,dis;
	unsigned int minstarnum=0,tmpstarn=0;
	vector<ST_STARSTRUCT> imgtablevec;
	vector<ST_STARSTRUCT> templatevec;
	ST_STARSTRUCT tmpstarstruct;
	FILE *filefp,*filefpx,*filefpy;
	int x;
	struct timeval tv[6];
	gettimeofday(&tv[0], NULL);
	//ST_PIXMAP *pixarray;
	unsigned short arraynum=1,arrayusednum=0;
	unsigned int totalarray;
	//ST_PIXMAP *tmppixp;
	void *reallocpt;
	float tmpmagerr,minmag;
	// imgtablemap=(unsigned char *)malloc(imgcols*imgrows*sizeof(unsigned char));
	templatemap=(ST_PIXMAP *)malloc(imgcols*imgrows*sizeof(ST_PIXMAP));
//	realimgstarmap=(unsigned int *)malloc(imgcols*imgrows*sizeof(unsigned int));


	totalarray=1024*2*arraynum;
	//pixarray=(ST_PIXMAP *)malloc(totalarray*sizeof(ST_PIXMAP));
	//	  if(imgtablemap!=NULL)
	//  	  memset(imgtablemap,0,imgcols*imgrows*sizeof(unsigned char));
	if(templatemap!=NULL)
		memset(templatemap,0,imgcols*imgrows*sizeof(ST_PIXMAP));


	imgtablevec.clear();
	templatevec.clear();
	starnum=1;
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
						x++;
						if(x==224)
							printf("test1 \n");
						templatevec.push_back(tmpstarstruct);
						//pixcorrect(tmpstarstruct.x_image,tmpstarstruct.y_image,&deltax,&deltay);
						deltax=deltay=(unsigned int)maxerr+2;
						bx=tmpstarstruct.x_image>(float)deltax?(unsigned int)(tmpstarstruct.x_image-deltax+0.5):0;
						nx=(tmpstarstruct.x_image+deltax+1.5)<=(float)imgcols?(unsigned int)(tmpstarstruct.x_image+deltax+1.5)-bx:imgcols-bx;
						//nx=(bx+deltax*2+1)<=(float)imgcols?deltax*2+1:imgcols-bx;
						by=tmpstarstruct.y_image>(float)deltay?(unsigned int)(tmpstarstruct.y_image-deltay+0.5):0;
						ey=(tmpstarstruct.y_image+deltay+1.5)<=(float)imgrows?(unsigned int)(tmpstarstruct.y_image+deltay+0.5):imgrows-1;
						for(i=by;i<=ey;i++)
						{
							rline=i*imgcols+bx;

							for(j=nx;j--;)
							{
								if(templatemap[rline].flag==0)
									templatemap[rline].flag=starnum;
								else
								{
									templatemap[rline].matchnum++;




								}

								rline++;

							}
						}
						rline=(unsigned int)tmpstarstruct.y_image*imgcols+(unsigned int)tmpstarstruct.x_image;
						templatemap[rline].flag=starnum;
						templatemap[rline].ifcenter=1;
						starnum++;
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


	filefpx=fopen(outfilename,"w");

	gettimeofday(&tv[2], NULL);
	starnum=0;
	filefpy=fopen(imgtablename,"r");
	if(filefpy!=NULL)
	{
		while(!feof(filefpy))
		{

			if((fgets(readbuf,512,filefpy))!=NULL)
			{
				start=strspn(readbuf," \t");
				strpt=readbuf+start;
				if(*strpt!=(char)'#')
				{
					status=sscanf(strpt,"%f %f %f %d %f %f %f %f %f %f",&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.flux,&tmpstarstruct.flag,&tmpstarstruct.bgflux,&tmpstarstruct.threshold,&tmpstarstruct.mag,&tmpstarstruct.merr,&tmpstarstruct.ellipticity,&tmpstarstruct.class_star);

					if(status)
					{
						pixcorrect(tmpstarstruct.x_image,tmpstarstruct.y_image,&deltaxf,&deltayf);
						tmpstarstruct.x_image=(tmpstarstruct.x_image+deltaxf)>0?(tmpstarstruct.x_image+deltaxf)<(imgcols-1)?(tmpstarstruct.x_image+deltaxf):0.0:0.0;
						tmpstarstruct.y_image=(tmpstarstruct.y_image+deltayf)>0?(tmpstarstruct.y_image+deltayf)<(imgrows-1)?(tmpstarstruct.y_image+deltayf):0.0:0.0;

						imgtablevec.push_back(tmpstarstruct);

						//float tttxxx=tmpstarstruct.x_image-1821.0;
                       /*if(fabs(tmpstarstruct.x_image-1821.0)<1.0)
                           {
                    	     printf("wait \n");

                           }*/

						rline=imgcols*(int)tmpstarstruct.y_image+(int)tmpstarstruct.x_image;
						if(templatemap[rline].flag!=0)
						{
							//mindis=1000.0;
                         if(templatemap[rline].matchnum==0)
                               {
                        	    tmpstarn=templatemap[rline].flag-1;
                        	 	 dis=(templatevec[tmpstarn].x_image-tmpstarstruct.x_image)*(templatevec[tmpstarn].x_image-tmpstarstruct.x_image)+(templatevec[tmpstarn].y_image-tmpstarstruct.y_image)*(templatevec[tmpstarn].y_image-tmpstarstruct.y_image);
                        	 	tmpmagerr=templatevec[tmpstarn].mag-tmpstarstruct.mag;
                        	 	 /*if((dis>maxerrd)||(tmpmagerr>magerrabs)||(tmpmagerr<(-magerrabs)))
                        	 								{

                        	 	                          if(filefpx!=NULL)
                        	 									fprintf(filefpx,"%f %f %f %d %f %f %f %f %f %f %f %f\n",tmpstarstruct.x_image,tmpstarstruct.y_image,tmpstarstruct.flux,tmpstarstruct.flag,tmpstarstruct.bgflux,tmpstarstruct.threshold,tmpstarstruct.mag,tmpstarstruct.merr,tmpstarstruct.ellipticity,tmpstarstruct.class_star,dis,tmpmagerr);

                        	 								}*/
                        	 	if(dis>maxerrd)
                        	 	{
                        	 		if(filefpx!=NULL)
                        	 		       fprintf(filefpx,"%f %f %f %d %f %f %f %f %f %f %f %f %d\n",tmpstarstruct.x_image,tmpstarstruct.y_image,tmpstarstruct.flux,tmpstarstruct.flag,tmpstarstruct.bgflux,tmpstarstruct.threshold,tmpstarstruct.mag,tmpstarstruct.merr,tmpstarstruct.ellipticity,tmpstarstruct.class_star,dis,tmpmagerr,1);


                        	 	}
                        	 	else
                        	 	{
                        	 		if((tmpmagerr>magerrabs)||(tmpmagerr<(-magerrabs)))
                        	 		{
                        	 			if(filefpx!=NULL)
                        	 			                        	 		       fprintf(filefpx,"%f %f %f %d %f %f %f %f %f %f %f %f %d\n",tmpstarstruct.x_image,tmpstarstruct.y_image,tmpstarstruct.flux,tmpstarstruct.flag,tmpstarstruct.bgflux,tmpstarstruct.threshold,tmpstarstruct.mag,tmpstarstruct.merr,tmpstarstruct.ellipticity,tmpstarstruct.class_star,dis,tmpmagerr,2);


                        	 		}
                        	 	}

                               }
                         else
                               {
                        	     bx=tmpstarstruct.x_image>(float)deltax?(unsigned int)(tmpstarstruct.x_image-deltax+0.5):0;
                        	 	  nx=(tmpstarstruct.x_image+deltax+1.5)<=(float)imgcols?(unsigned int)(tmpstarstruct.x_image+deltax+1.5)-bx:imgcols-bx;
                        	 						//nx=(bx+deltax*2+1)<=(float)imgcols?deltax*2+1:imgcols-bx;
                        	 	 by=tmpstarstruct.y_image>(float)deltay?(unsigned int)(tmpstarstruct.y_image-deltay+0.5):0;
                        	 	 ey=(tmpstarstruct.y_image+deltay+1.5)<=(float)imgrows?(unsigned int)(tmpstarstruct.y_image+deltay+0.5):imgrows-1;
                        	 	 mindis=10000.0;
                        	 	 for(i=by;i<=ey;i++)
                        	 							{
                        	 								rline=i*imgcols+bx;

                        	 								for(j=nx;j--;)
                        	 								{
                        	 									if(templatemap[rline].ifcenter==1)
                        	 									   {
                        	 										tmpstarn=templatemap[rline].flag-1;
                        	 										 dis=(templatevec[tmpstarn].x_image-tmpstarstruct.x_image)*(templatevec[tmpstarn].x_image-tmpstarstruct.x_image)+(templatevec[tmpstarn].y_image-tmpstarstruct.y_image)*(templatevec[tmpstarn].y_image-tmpstarstruct.y_image);
                        	 										tmpmagerr=templatevec[tmpstarn].mag-tmpstarstruct.mag;

                        	 										if(mindis>dis)
                        	 										  {
                        	 											mindis=dis;
                        	 											minstarnum=tmpstarn;
                        	 											minmag=tmpmagerr;
                        	 										  }

                        	 									   }


                        	 									rline++;
                        	 								}
                        	 							}

                        	 	/*if(((mindis>maxerrd)&&(mindis<9000.0))||(minmag<-(magerrabs))||(minmag>magerrabs))
                        	 								{

                        	 	                          if(filefpx!=NULL)
                        	 									fprintf(filefpx,"%f %f %f %d %f %f %f %f %f %f %f %f\n",tmpstarstruct.x_image,tmpstarstruct.y_image,tmpstarstruct.flux,tmpstarstruct.flag,tmpstarstruct.bgflux,tmpstarstruct.threshold,tmpstarstruct.mag,tmpstarstruct.merr,tmpstarstruct.ellipticity,tmpstarstruct.class_star,mindis,minmag);

                        	 								}*/
                        	 	if((mindis>maxerrd)&&(mindis<9000.0))
                        	 	                        	 	{
                        	 	                        	 		if(filefpx!=NULL)
                        	 	                        	 		       fprintf(filefpx,"%f %f %f %d %f %f %f %f %f %f %f %f %d\n",tmpstarstruct.x_image,tmpstarstruct.y_image,tmpstarstruct.flux,tmpstarstruct.flag,tmpstarstruct.bgflux,tmpstarstruct.threshold,tmpstarstruct.mag,tmpstarstruct.merr,tmpstarstruct.ellipticity,tmpstarstruct.class_star,dis,tmpmagerr,1);


                        	 	                        	 	}
                        	 	                        	 	else
                        	 	                        	 	{
                        	 	                        	 		if((tmpmagerr>magerrabs)||(tmpmagerr<(-magerrabs)))
                        	 	                        	 		{
                        	 	                        	 			if(filefpx!=NULL)
                        	 	                        	 			   fprintf(filefpx,"%f %f %f %d %f %f %f %f %f %f %f %f %d\n",tmpstarstruct.x_image,tmpstarstruct.y_image,tmpstarstruct.flux,tmpstarstruct.flag,tmpstarstruct.bgflux,tmpstarstruct.threshold,tmpstarstruct.mag,tmpstarstruct.merr,tmpstarstruct.ellipticity,tmpstarstruct.class_star,dis,tmpmagerr,2);


                        	 	                        	 		}
                        	 	                        	 	}

                               }


							/*tmpstarn=templatemap[rline].flag-1;
							dis=templatevec[(*tmppixp).flag-1].x_image*templatevec[(*tmppixp).flag-1].x_image+templatevec[(*tmppixp).flag-1].y_image*templatevec[(*tmppixp).flag-1].y_image;
							mindis=dis;
							minstarnum=tmpstarn;
							tmppixp=templatemap[rline].pixp;

							while(tmppixp!=0)
							{
								tmpstarn=(*tmppixp).flag-1;
								dis=templatevec[tmpstarn].x_image*templatevec[tmpstarn].x_image+templatevec[tmpstarn].y_image*templatevec[tmpstarn].y_image;
								if(dis<mindis)
								{mindis=dis;
								minstarnum=tmpstarn;
								}

								tmppixp=(*tmppixp).pixp;
							}
							if(mindis>maxerrd)
							{

                          if(filefpx!=NULL)
								fprintf(filefpx,"%f %f %f %d %f %f %f %f %f %f %f\n",tmpstarstruct.x_image,tmpstarstruct.y_image,tmpstarstruct.flux,tmpstarstruct.flag,tmpstarstruct.bgflux,tmpstarstruct.threshold,tmpstarstruct.mag,tmpstarstruct.merr,tmpstarstruct.ellipticity,tmpstarstruct.class_star,mindis);

							}*/

						}
					 else
					    {
						   if(filefpx!=NULL)
								fprintf(filefpx,"%f %f %f %d %f %f %f %f %f %f %f %f %d\n",tmpstarstruct.x_image,tmpstarstruct.y_image,tmpstarstruct.flux,tmpstarstruct.flag,tmpstarstruct.bgflux,tmpstarstruct.threshold,tmpstarstruct.mag,tmpstarstruct.merr,tmpstarstruct.ellipticity,tmpstarstruct.class_star,-1.0,0.0,1);


					    }




						starnum++;
					}
				}
			}
		}
		fclose(filefpy);
		fclose(filefpx);
	}
	else
	{
		printf("Cann't open %s \n",imgtablename);
		return 0;

	}

	imgtablevec.clear();
	templatevec.clear();

	//if(pixarray!=NULL)
		//	free(pixarray);
		if(templatemap!=NULL)
			free(templatemap);
   gettimeofday(&tv[5], NULL);

	printf("start time:%d s  %d us\n",tv[0].tv_sec,tv[0].tv_usec);
	printf("time before reading template:%d s  %d us\n",tv[1].tv_sec,tv[1].tv_usec);
	printf("time after reading template:%d s  %d us\n",tv[2].tv_sec,tv[2].tv_usec);
		//printf("time after reading image table:%d s  %d us\n",tv[3].tv_sec,tv[3].tv_usec);
		//printf("time after matching table:%d s  %d us\n",tv[4].tv_sec,tv[4].tv_usec);
	printf("end time after output:%d s  %d us\n",tv[5].tv_sec,tv[5].tv_usec);
		return 1;




}








