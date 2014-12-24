//#include "stdafx.h"
#include"unistd.h"
#include"sys/types.h"
#include"fcntl.h"
#include"dirent.h"
//#include"stdio.h"


#include <stdio.h>
#include <malloc.h>
#include <sys/time.h>
//#include <time.h>
#include <math.h>
#include<stdlib.h>
#include "TemplateMark.h"
const char	notokstr[] = {" \t=,;\n\r\""};

vector <ST_STARTABLE_VEC> starmatchvec;
vector <ST_STARTABLE_VEC_B> starmatchvec_B;
unsigned int g_imgnum;
unsigned short g_status;


int	main(int argc, char *argv[])
{
	unsigned int tmpminmatchnum,tmpmatchnum,tmpfileflag,tmpoutputflag,tmpoption;
	float tmpdis;
	struct dirent *dpr;
	DIR *dp;
	int firstflag=1;

	char outfile[512];
	char procfile[512];
	if (argc<2)
	{
		printf("number of parameters error\n");
		return 0;
	}

	tmpoption=atoi(argv[1]);
	if(tmpoption==1)
	{
		if (argc<9)
			   {
			   	printf("argc=%d\n",argc);
			   	printf("1st parameter is an option for matching \n");
			   	printf("option 1:\n");
			   	printf("         2nd parameter is fileflag,1 means 1st table,>1 means middle tables,0 means the last table\n");
			   	printf("         3rd parameter is max distance(float) for matching\n");
			   	printf("         4th parameter is min matching number\n");
			    printf("         5th parameter is input filename\n");
			   	printf("         6th parameter is tmp filename\n");
			   	printf("         7th pparameter is output flag,0 means outputing unmatched stars,1 means outputing matched stars,2 means outputing matched and unmatched stars\n");
			   	printf("         8th parameter is output filename\n");
				printf("option 2:\n");
				   	printf("         2nd parameter is fileflag,1 means 1st table,>1 means middle tables\n");
				   	printf("         3rd parameter is max distance(float) for matching\n");
				   	printf("         4th parameter is min matching number\n");
				    printf("         5th parameter is the number of files for matching\n");
				    printf("         6th parameter is input filename\n");
				   	printf("         7th parameter is tmp filename\n");
				   	printf("         8th pparameter is output flag,0 means outputing unmatched stars,1 means outputing matched stars,2 means outputing matched and unmatched stars\n");
				   	printf("         9th parameter is output filename\n");
			   }
		else
		  {
			tmpfileflag=atoi(argv[2]);
			tmpdis=atof(argv[3]);
			tmpminmatchnum=atoi(argv[4]);
					//tmpmatchnum

			tmpoutputflag=atoi(argv[7]);
			TemplateMark(tmpfileflag,tmpdis,tmpminmatchnum,argv[5],argv[6],tmpoutputflag,argv[8]);
		  }

	}
	else if(tmpoption==2)
	{
		if (argc<10)
					   {
					   	printf("argc=%d\n",argc);
					   	printf("1st parameter is an option for matching \n");
					   	printf("option 1:\n");
					   	printf("         2nd parameter is fileflag,1 means 1st table,>1 means middle tables,0 means the last table\n");
					   	printf("         3rd parameter is max distance(float) for matching\n");
					   	printf("         4th parameter is min matching number\n");
					    printf("         5th parameter is input filename\n");
					   	printf("         6th parameter is tmp filename\n");
					   	printf("         7th pparameter is output flag,0 means outputing unmatched stars,1 means outputing matched stars,2 means outputing matched and unmatched stars\n");
					   	printf("         8th parameter is output filename\n");
						printf("option 2:\n");
						   	printf("         2nd parameter is fileflag,1 means 1st table,>1 means middle tables\n");
						   	printf("         3rd parameter is max distance(float) for matching\n");
						   	printf("         4th parameter is min matching number\n");
						    printf("         5th parameter is the number of files for matching\n");
						    printf("         6th parameter is input filename\n");
						   	printf("         7th parameter is tmp filename\n");
						   	printf("         8th pparameter is output flag,0 means outputing unmatched stars,1 means outputing matched stars,2 means outputing matched and unmatched stars\n");
						   	printf("         9th parameter is output filename\n");
					   }
			else
				  {
					tmpfileflag=atoi(argv[2]);
					tmpdis=atof(argv[3]);
					tmpminmatchnum=atoi(argv[4]);
				   tmpmatchnum=atoi(argv[5]);

					tmpoutputflag=atoi(argv[8]);
					//TemplateMark_B(firstflag,2.0,3,5,procfile,argv[2],2,0,outfile);
					TemplateMark_B(tmpfileflag,tmpdis,tmpminmatchnum,tmpmatchnum,argv[6],argv[7],tmpoutputflag,0,argv[9]);
				  }

	}
	else
	{
		printf("1st parameter error \n");

	}
	return 1;

	//char wholefile[512];
	/*if (argc<8)
	   {
	   	printf("argc=%d\n",argc);
	   	printf("1st parameter is an option for matching \n");
	   	printf("option 1:\n);
	   	printf("         2nd parameter is fileflag,1 means 1st table,>1 means middle tables,0 means the last table\n");
	   	printf("         3rd parameter is max distance(float) for matching\n");
	   	printf("         4th parameter is min matching number\n");
	    printf("         5th parameter is input filename\n");
	   	printf("         6th parameter is tmp filename\n");
	   	printf("         7th pparameter is output flag,0 means outputing unmatched stars,1 means outputing matched stars,2 means outputing matched and unmatched stars\n");
	   	printf("         8th parameter is output filename\n");

	   	printf("option 2:\n);
	   	printf("         2nd parameter is fileflag,1 means 1st table,>1 means middle tables\n");
	   	printf("         3rd parameter is max distance(float) for matching\n");
	   	printf("         4th parameter is min matching number\n");
	    printf("         5th parameter is the number of files for matching\n");
	    printf("         6th parameter is input filename\n");
	   	printf("         7th parameter is tmp filename\n");
	   	printf("         8th pparameter is output flag,0 means outputing unmatched stars,1 means outputing matched stars,2 means outputing matched and unmatched stars\n");
	   	printf("         9th parameter is output filename\n");




	   }
	else
	   {
		tmpdis=atof(argv[1]);
		tmpmatchnum=atoi(argv[2]);
		tmpfileflag=atoi(argv[3]);
		tmpoutputflag=atoi(argv[6]);

		printf("max distance:%f \n",tmpdis);
		printf("input filename:%s \n",argv[4]);
		printf("tmp filename:%s \n",argv[5]);
		printf("output filename:%s \n",argv[7]);

		TemplateMark(tmpfileflag,tmpdis,tmpmatchnum,3072,3072,argv[4],argv[5],tmpoutputflag,argv[7]);
	   }*/

/*
	struct dirent **namelist;
	int n;
	n = scandir(argv[1], &namelist, myfilter, alphasort);

	if(n<0)
		printf("not found file in dir");
	else
	{
		for(int i=0;i<n;i++)
		{
			//printf("%s\n", namelist[i]->d_name);


			sprintf(procfile,"%s%s",argv[1],namelist[i]->d_name);
			sprintf(outfile,"%sxxx_%d.txt",argv[3],firstflag);
			//TemplateMark_B(firstflag,2.0,3,5,procfile,argv[2],2,0,outfile);
			TemplateMark(firstflag,2.0,3,procfile,argv[2],2,outfile);

			if(firstflag==0)
			{
				break;

			}
			firstflag++;
			if(firstflag>=5)
			{firstflag=0;

			}
		}

	}


return 1;*/
}

int myfilter(const struct dirent *filename)
{
	if((strcmp(filename->d_name,".")==0)||(strcmp(filename->d_name,"..")==0))
	{
		return 0;
	}
	return 1;
}


int TemplateMark_B(unsigned int fileflag,float maxerr,unsigned short minmatchnum,unsigned short imgloopnum,char templatename[],char tmpfilename[],unsigned short outputflag,unsigned short outputmeanflag,char outfilename[])
{
	int status,tmpvecflag;
	unsigned int tmpvecnum;
	char *strpt,*tok=NULL,*tmpcharbuf=NULL;
	char readbuf[512];
	unsigned int start,i,j;
	unsigned int tmp_imgnum;
	unsigned short tmp_status;
	float maxerrpower=maxerr*maxerr;
	ST_STARTABLE_VEC_B tmpstarstructvec;
	ST_STARSTRUCT_B  tmpstarstruct;
	FILE *filefp;
	bool ifmatch=false,iftmpfile=false;
	float tmpfloat;
	unsigned int tmpvecsize;
	unsigned short tmpflag;
	struct timeval tv[2];
	bool tmpbool=false;
	unsigned int deleteimgnum=0;
	float meanx,meany;
	//time_t t[10];
	//int tnum=0;

	//	t[tnum]=time(NULL);
	//tnum++;
	//printf("fileflag=%d dis=%f matchnum=%d cols=%d rows=%d  outputflag=%d\n",fileflag,maxerr,minmatchnum,imgcols,imgrows,outputflag);
	gettimeofday(&tv[0], NULL);

	if(fileflag==1)
	{
		g_imgnum=1;
		g_status=0;
		starmatchvec_B.clear();
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
						tmpstarstructvec.peervec.clear();
						// status=sscanf(strpt,"%f %f %d %f %f %f %f %d",&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.number,&tmpstarstruct.fluxerr_iso,&tmpstarstruct.mag_auto,&tmpstarstruct.magerr_auto,&tmpstarstruct.fwhm_image,&tmpstarstruct.flags);
						status=sscanf(strpt,"%f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f",&tmpstarstruct.ra,&tmpstarstruct.dec,&tmpstarstruct.xcim,&tmpstarstruct.ycim,&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.time,&tmpstarstruct.imagename,&tmpstarstruct.flux,&tmpstarstruct.flags,&tmpstarstruct.bgflux,&tmpstarstruct.threshold,
								&tmpstarstruct.mag,&tmpstarstruct.merr,&tmpstarstruct.ellipticity,&tmpstarstruct.class_star);


						if(status)
						{
							tmpstarstruct.imgnum=g_imgnum;
							tmpstarstructvec.peervec.push_back(tmpstarstruct);
							starmatchvec_B.push_back(tmpstarstructvec);

						}
					}
				}
			}
			fclose(filefp);
		}
		//write tmp file
		filefp=fopen(tmpfilename,"w");
		if(filefp!=NULL)
		{
			fprintf(filefp,"#TemplatMarkfile\n");
			fprintf(filefp,"#FileNum %d\n",g_imgnum);
			fprintf(filefp,"#FileStatus %d\n",g_status);


			for(i=0;i<starmatchvec_B.size();i++)
			{
				//fprintf(filefp,"%d %d %f %f %d %f %f %f %f %d %d\n",1,i,starmatchvec_B[i].peervec[0].x_image,starmatchvec_B[i].peervec[0].y_image,starmatchvec_B[i].peervec[0].number,starmatchvec_B[i].peervec[0].fluxerr_iso,starmatchvec_B[i].peervec[0].mag_auto,starmatchvec_B[i].peervec[0].magerr_auto,starmatchvec_B[i].peervec[0].fwhm_image,starmatchvec_B[i].peervec[0].flags,starmatchvec_B[i].peervec[0].imgnum);
				fprintf(filefp,"%d %d %f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f %d\n",1,i,starmatchvec_B[i].peervec[0].ra,starmatchvec_B[i].peervec[0].dec,starmatchvec_B[i].peervec[0].xcim,starmatchvec_B[i].peervec[0].ycim,starmatchvec_B[i].peervec[0].x_image,starmatchvec_B[i].peervec[0].y_image,starmatchvec_B[i].peervec[0].time,starmatchvec_B[i].peervec[0].imagename,starmatchvec_B[i].peervec[0].flux,starmatchvec_B[i].peervec[0].flags,starmatchvec_B[i].peervec[0].bgflux,starmatchvec_B[i].peervec[0].threshold,
						starmatchvec_B[i].peervec[0].mag,starmatchvec_B[i].peervec[0].merr,starmatchvec_B[i].peervec[0].ellipticity,starmatchvec_B[i].peervec[0].class_star,starmatchvec_B[i].peervec[0].imgnum);

				for(j=1;j<starmatchvec_B[i].peervec.size();j++)
				{

					//fprintf(filefp,"%d %d %f %f %d %f %f %f %f %d %d\n",0,i,starmatchvec_B[i].peervec[j].x_image,starmatchvec_B[i].peervec[j].y_image,starmatchvec_B[i].peervec[j].number,starmatchvec_B[i].peervec[j].fluxerr_iso,starmatchvec_B[i].peervec[j].mag_auto,starmatchvec_B[i].peervec[j].magerr_auto,starmatchvec_B[i].peervec[j].fwhm_image,starmatchvec_B[i].peervec[j].flags,starmatchvec_B[i].peervec[j].imgnum);
					fprintf(filefp,"%d %d %f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f %d\n",0,i,starmatchvec_B[i].peervec[j].ra,starmatchvec_B[i].peervec[j].dec,starmatchvec_B[i].peervec[j].xcim,starmatchvec_B[i].peervec[j].ycim,starmatchvec_B[i].peervec[j].x_image,starmatchvec_B[i].peervec[j].y_image,starmatchvec_B[i].peervec[j].time,starmatchvec_B[i].peervec[j].imagename,starmatchvec_B[i].peervec[j].flux,starmatchvec_B[i].peervec[j].flags,starmatchvec_B[i].peervec[j].bgflux,starmatchvec_B[i].peervec[j].threshold,
							starmatchvec_B[i].peervec[j].mag,starmatchvec_B[i].peervec[j].merr,starmatchvec_B[i].peervec[j].ellipticity,starmatchvec_B[i].peervec[j].class_star,starmatchvec_B[i].peervec[j].imgnum);

				}

			}

			fclose(filefp);
		}
	}
	else
	{
		g_imgnum++;
		if(!g_status)
		{
			if(g_imgnum>=imgloopnum)
			{
				g_status=1;
				tmpbool=true;
			}
		}
		//read tmp filename
		iftmpfile=false;
		starmatchvec_B.clear();
		filefp=fopen(tmpfilename,"r");
		if(filefp!=NULL)
		{
			while(!feof(filefp))
			{
				if((fgets(readbuf,512,filefp))!=NULL)
				{
					start=strspn(readbuf," \t");
					strpt=readbuf+start;
					if(*strpt==(char)'#')
					{
						tok=strtok_r(strpt,notokstr,&tmpcharbuf);
						if(tok!=NULL)
						{
							if(strcmp(tok,"#TemplatMarkfile")==0)
								iftmpfile=true;

							else
							{
								//if(tok!=NULL)
								//    {
								if(strcmp(tok,"#FileNum")==0)
								{
									//printf("test 2\n");
									tok=strtok_r(NULL,notokstr,&tmpcharbuf);
									if(tok!=NULL)
									{
										tmp_imgnum=atoi(tok);
										tmp_imgnum++;
										if(g_imgnum!=tmp_imgnum)
											printf("g_imgnum=%d ok tmp_imgnum=%d\n",g_imgnum,tmp_imgnum);
									}
								}
								else if(strcmp(tok,"#FileStatus")==0)
								{
									tok=strtok_r(NULL,notokstr,&tmpcharbuf);
									if(tok!=NULL)
									{
										tmp_status=atoi(tok);
									}
								}
								else
								{

								}
								//}
							}
						}
					}
					else
					{
						if(!iftmpfile)
						{
							printf("tmp file is error\n");
							fclose(filefp);
							return 0;
						}
						// status=sscanf(strpt,"%d %d %f %f %d %f %f %f %f %d %d",&tmpvecflag,&tmpvecnum,&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.number,&tmpstarstruct.fluxerr_iso,&tmpstarstruct.mag_auto,&tmpstarstruct.magerr_auto,&tmpstarstruct.fwhm_image,&tmpstarstruct.flags,&tmpstarstruct.imgnum);
						status=sscanf(strpt,"%d %d %f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f %d",&tmpvecflag,&tmpvecnum,&tmpstarstruct.ra,&tmpstarstruct.dec,&tmpstarstruct.xcim,&tmpstarstruct.ycim,&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.time,&tmpstarstruct.imagename,&tmpstarstruct.flux,&tmpstarstruct.flags,&tmpstarstruct.bgflux,&tmpstarstruct.threshold,
								&tmpstarstruct.mag,&tmpstarstruct.merr,&tmpstarstruct.ellipticity,&tmpstarstruct.class_star,&tmpstarstruct.imgnum);


						if(tmpvecflag==1)
						{
							//tmpstarstructvec.starpoint=tmpstarstruct;
							tmpstarstructvec.peervec.clear();
							tmpstarstructvec.peervec.push_back(tmpstarstruct);
							starmatchvec_B.push_back(tmpstarstructvec);
						}
						else
						{
							if(tmpvecnum>=starmatchvec_B.size())
							{
								printf("tmp file is error 2\n");
								fclose(filefp);
								return 0;
							}
							starmatchvec_B[tmpvecnum].peervec.push_back(tmpstarstruct);

						}
					}
				}
			}

			fclose(filefp);
		}
		if(g_status)
		{
			if(!tmpbool)
			{
				//delete
				if(g_imgnum>=imgloopnum)
					deleteimgnum=g_imgnum-imgloopnum;
				else
					deleteimgnum=(4294967295-imgloopnum)+g_imgnum+1;
				i=j=0;
				while(i<starmatchvec_B.size())
				{

					while(j<starmatchvec_B[i].peervec.size())
					{
						if(starmatchvec_B[i].peervec[j].imgnum==deleteimgnum)
						{
							starmatchvec_B[i].peervec.erase(starmatchvec_B[i].peervec.begin()+j);
						}
						else
						{
							j++;
						}

					}
					if(starmatchvec_B[i].peervec.size()==0)
					{
						starmatchvec_B.erase(starmatchvec_B.begin()+i);
					}
					else
						i++;

				}
			}

		}
		//read file
		tmpvecsize=starmatchvec_B.size();
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
						//status=sscanf(strpt,"%f %f %d %f %f %f %f %d",&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.number,&tmpstarstruct.fluxerr_iso,&tmpstarstruct.mag_auto,&tmpstarstruct.magerr_auto,&tmpstarstruct.fwhm_image,&tmpstarstruct.flags);
						status=sscanf(strpt,"%f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f",&tmpstarstruct.ra,&tmpstarstruct.dec,&tmpstarstruct.xcim,&tmpstarstruct.ycim,&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.time,&tmpstarstruct.imagename,&tmpstarstruct.flux,&tmpstarstruct.flags,&tmpstarstruct.bgflux,&tmpstarstruct.threshold,
								&tmpstarstruct.mag,&tmpstarstruct.merr,&tmpstarstruct.ellipticity,&tmpstarstruct.class_star);



						tmpstarstruct.imgnum=g_imgnum;
						ifmatch=false;
						if(status)
						{
							for(i=0;i<tmpvecsize;i++)
							{
								for(j=0;j<starmatchvec_B[i].peervec.size();j++)
								{
									tmpfloat=((tmpstarstruct.x_image-starmatchvec_B[i].peervec[j].x_image)*(tmpstarstruct.x_image-starmatchvec_B[i].peervec[j].x_image)+(tmpstarstruct.y_image-starmatchvec_B[i].peervec[j].y_image)*(tmpstarstruct.y_image-starmatchvec_B[i].peervec[j].y_image));
									if(tmpfloat<maxerrpower)
									{
										ifmatch=true;
										starmatchvec_B[i].peervec.push_back(tmpstarstruct);
										break;
									}

								}

								if(ifmatch)
									break;
							}
							if(!ifmatch)
							{
								tmpstarstructvec.peervec.clear();
								tmpstarstructvec.peervec.push_back(tmpstarstruct);
								starmatchvec_B.push_back(tmpstarstructvec);
							}

						}
					}
				}
			}
			fclose(filefp);
		}
		//write tmp file
		filefp=fopen(tmpfilename,"w");
		if(filefp!=NULL)
		{
			fprintf(filefp,"#TemplatMarkfile\n");
			fprintf(filefp,"#FileNum %d\n",g_imgnum);
			fprintf(filefp,"#FileStatus %d\n",g_status);


			for(i=0;i<starmatchvec_B.size();i++)
			{
				//fprintf(filefp,"%d %d %f %f %d %f %f %f %f %d %d\n",1,i,starmatchvec_B[i].peervec[0].x_image,starmatchvec_B[i].peervec[0].y_image,starmatchvec_B[i].peervec[0].number,starmatchvec_B[i].peervec[0].fluxerr_iso,starmatchvec_B[i].peervec[0].mag_auto,starmatchvec_B[i].peervec[0].magerr_auto,starmatchvec_B[i].peervec[0].fwhm_image,starmatchvec_B[i].peervec[0].flags,starmatchvec_B[i].peervec[0].imgnum);
				fprintf(filefp,"%d %d %f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f %d\n",1,i,starmatchvec_B[i].peervec[0].ra,starmatchvec_B[i].peervec[0].dec,starmatchvec_B[i].peervec[0].xcim,starmatchvec_B[i].peervec[0].ycim,starmatchvec_B[i].peervec[0].x_image,starmatchvec_B[i].peervec[0].y_image,starmatchvec_B[i].peervec[0].time,starmatchvec_B[i].peervec[0].imagename,starmatchvec_B[i].peervec[0].flux,starmatchvec_B[i].peervec[0].flags,starmatchvec_B[i].peervec[0].bgflux,starmatchvec_B[i].peervec[0].threshold,
						starmatchvec_B[i].peervec[0].mag,starmatchvec_B[i].peervec[0].merr,starmatchvec_B[i].peervec[0].ellipticity,starmatchvec_B[i].peervec[0].class_star,starmatchvec_B[i].peervec[0].imgnum);

				for(j=1;j<starmatchvec_B[i].peervec.size();j++)
				{

					//fprintf(filefp,"%d %d %f %f %d %f %f %f %f %d %d\n",0,i,starmatchvec_B[i].peervec[j].x_image,starmatchvec_B[i].peervec[j].y_image,starmatchvec_B[i].peervec[j].number,starmatchvec_B[i].peervec[j].fluxerr_iso,starmatchvec_B[i].peervec[j].mag_auto,starmatchvec_B[i].peervec[j].magerr_auto,starmatchvec_B[i].peervec[j].fwhm_image,starmatchvec_B[i].peervec[j].flags,starmatchvec_B[i].peervec[j].imgnum);
					fprintf(filefp,"%d %d %f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f %d\n",0,i,starmatchvec_B[i].peervec[j].ra,starmatchvec_B[i].peervec[j].dec,starmatchvec_B[i].peervec[j].xcim,starmatchvec_B[i].peervec[j].ycim,starmatchvec_B[i].peervec[j].x_image,starmatchvec_B[i].peervec[j].y_image,starmatchvec_B[i].peervec[j].time,starmatchvec_B[i].peervec[j].imagename,starmatchvec_B[i].peervec[j].flux,starmatchvec_B[i].peervec[j].flags,starmatchvec_B[i].peervec[j].bgflux,starmatchvec_B[i].peervec[j].threshold,
							starmatchvec_B[i].peervec[j].mag,starmatchvec_B[i].peervec[j].merr,starmatchvec_B[i].peervec[j].ellipticity,starmatchvec_B[i].peervec[j].class_star,starmatchvec_B[i].peervec[j].imgnum);

				}

			}

			fclose(filefp);
		}
		//write result file
		if(g_status)
		{

			filefp=fopen(outfilename,"w");
			for(i=0;i<starmatchvec_B.size();i++)
			{
				//printf("test3 size=%d,minmatchnum=%d\n",starmatchvec_B[i].peervec.size(),minmatchnum);
				if((starmatchvec_B[i].peervec.size())>=(minmatchnum))
				{
					tmpflag=1;
					if(outputflag!=0)
					{
						if(outputmeanflag!=1)
						{
							if(filefp!=NULL)
							{
								//fprintf(filefp,"%f %f %d %d %d %d\n",starmatchvec[i].starpoint.x_image,starmatchvec[i].starpoint.y_image,0,0,starmatchvec[i].starpoint.imgnum,tmpflag);
								for(j=0;j<starmatchvec_B[i].peervec.size();j++)
								{
									// fprintf(filefp,"%f %f %d %d %d %d\n",starmatchvec_B[i].peervec[j].x_image,starmatchvec_B[i].peervec[j].y_image,0,0,starmatchvec_B[i].peervec[j].imgnum,tmpflag);
									// fprintf(filefp,"%f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f %d\n",starmatchvec_B[i].peervec[j].ra,starmatchvec_B[i].peervec[j].dec,starmatchvec_B[i].peervec[j].xcim,starmatchvec_B[i].peervec[j].ycim,starmatchvec_B[i].peervec[j].x_image,starmatchvec_B[i].peervec[j].y_image,starmatchvec_B[i].peervec[j].time,starmatchvec_B[i].peervec[j].imagename,starmatchvec_B[i].peervec[j].flux,starmatchvec_B[i].peervec[j].flags,starmatchvec_B[i].peervec[j].bgflux,starmatchvec_B[i].peervec[j].threshold,
									//						    	 							    		  starmatchvec_B[i].peervec[j].mag,starmatchvec_B[i].peervec[j].merr,starmatchvec_B[i].peervec[j].ellipticity,starmatchvec_B[i].peervec[j].class_star,starmatchvec_B[i].peervec[j].imgnum);
									fprintf(filefp,"%f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f %d %d\n",starmatchvec_B[i].peervec[j].ra,starmatchvec_B[i].peervec[j].dec,starmatchvec_B[i].peervec[j].xcim,starmatchvec_B[i].peervec[j].ycim,starmatchvec_B[i].peervec[j].x_image,starmatchvec_B[i].peervec[j].y_image,starmatchvec_B[i].peervec[j].time,starmatchvec_B[i].peervec[j].imagename,starmatchvec_B[i].peervec[j].flux,starmatchvec_B[i].peervec[j].flags,starmatchvec_B[i].peervec[j].bgflux,starmatchvec_B[i].peervec[j].threshold,
											starmatchvec_B[i].peervec[j].mag,starmatchvec_B[i].peervec[j].merr,starmatchvec_B[i].peervec[j].ellipticity,starmatchvec_B[i].peervec[j].class_star,starmatchvec_B[i].peervec[j].imgnum,tmpflag);
									//printf("%f %f\n",starmatchvec[i].peervec[j].ra,starmatchvec[i].peervec[j].dec);
								}

							}
						}
						else
						{
							if(filefp!=NULL)
							{
								meanx=meany=0.0;
								for(j=0;j<starmatchvec_B[i].peervec.size();j++)
								{
									meanx+=starmatchvec_B[i].peervec[j].x_image;
									meany+=starmatchvec_B[i].peervec[j].y_image;
								}
								if(starmatchvec_B[i].peervec.size()!=0)
								{
									meanx/=starmatchvec_B[i].peervec.size();
									meany/=starmatchvec_B[i].peervec.size();
									fprintf(filefp,"%f %f %d %d %d %d\n",meanx,meany,0,0,starmatchvec_B[i].peervec[0].imgnum,tmpflag);

								}
							}

						}
					}
				}
				else
				{
					tmpflag=0;
					if(outputflag!=1)
					{
						if(outputmeanflag!=1)
						{
							if(filefp!=NULL)
							{
								//fprintf(filefp,"%f %f %d %d %d %d\n",starmatchvec[i].starpoint.x_image,starmatchvec[i].starpoint.y_image,0,0,starmatchvec[i].starpoint.imgnum,tmpflag);
								for(j=0;j<starmatchvec_B[i].peervec.size();j++)
								{
									//fprintf(filefp,"%f %f %d %d %d %d\n",starmatchvec_B[i].peervec[j].x_image,starmatchvec_B[i].peervec[j].y_image,0,0,starmatchvec_B[i].peervec[j].imgnum,tmpflag);
									fprintf(filefp,"%f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f %d %d\n",starmatchvec_B[i].peervec[j].ra,starmatchvec_B[i].peervec[j].dec,starmatchvec_B[i].peervec[j].xcim,starmatchvec_B[i].peervec[j].ycim,starmatchvec_B[i].peervec[j].x_image,starmatchvec_B[i].peervec[j].y_image,starmatchvec_B[i].peervec[j].time,starmatchvec_B[i].peervec[j].imagename,starmatchvec_B[i].peervec[j].flux,starmatchvec_B[i].peervec[j].flags,starmatchvec_B[i].peervec[j].bgflux,starmatchvec_B[i].peervec[j].threshold,
											starmatchvec_B[i].peervec[j].mag,starmatchvec_B[i].peervec[j].merr,starmatchvec_B[i].peervec[j].ellipticity,starmatchvec_B[i].peervec[j].class_star,starmatchvec_B[i].peervec[j].imgnum,tmpflag);

								}

							}
						}
						else
						{
							if(filefp!=NULL)
							{
								meanx=meany=0.0;
								for(j=0;j<starmatchvec_B[i].peervec.size();j++)
								{
									meanx+=starmatchvec_B[i].peervec[j].x_image;
									meany+=starmatchvec_B[i].peervec[j].y_image;
								}
								if(starmatchvec_B[i].peervec.size()!=0)
								{
									meanx/=starmatchvec_B[i].peervec.size();
									meany/=starmatchvec_B[i].peervec.size();
									fprintf(filefp,"%f %f %d %d %d %d\n",meanx,meany,0,0,starmatchvec_B[i].peervec[0].imgnum,tmpflag);

								}
							}
						}

					}

				}

			}
			if(filefp!=NULL)
			{
				fclose(filefp);
			}

		}

	}


	gettimeofday(&tv[1], NULL);
/*	printf("No.%d img start time %d s %d us\n",g_imgnum,tv[0].tv_sec,tv[0].tv_usec);
	printf("No.%d img over time %d s %d us\n",g_imgnum,tv[1].tv_sec,tv[1].tv_usec);
*/
	return 1;
}




/*
fileflag: 1��ʾ��1��ͼ
          >1��ʾ�м�ͼ
		  0��ʾ���1��ͼ
outputflag:0��ʾֻ���δƥ����
           1��ʾֻ����ɹ�ƥ����
		   2��ʾδƥ������ɹ�ƥ���Ǿ����
 */
int TemplateMark(unsigned int fileflag,float maxerr,unsigned short minmatchnum,char templatename[],char tmpfilename[],unsigned short outputflag,char outfilename[])
{
	int status,tmpvecflag;
	unsigned int tmpvecnum;
	char *strpt,*tok=NULL,*tmpcharbuf=NULL;
	char readbuf[512];
	unsigned int start,i,j;
	int rval;

	float maxerrpower=maxerr*maxerr;
	ST_STARTABLE_VEC tmpstarstructvec;
	ST_STARSTRUCT_B  tmpstarstruct;
	FILE *filefp;
	bool ifmatch=false,iftmpfile=false;
	float tmpfloat;
	unsigned int tmpvecsize;
	unsigned short tmpflag;
	struct timeval tv[2];
	//time_t t[10];
	//int tnum=0;

	//	t[tnum]=time(NULL);
	//tnum++;
	//printf("fileflag=%d dis=%f matchnum=%d cols=%d rows=%d  outputflag=%d\n",fileflag,maxerr,minmatchnum,imgcols,imgrows,outputflag);
	gettimeofday(&tv[0], NULL);
	if(fileflag==1)
	{
		starmatchvec.clear();
		g_imgnum=0;
		g_imgnum++;
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
						tmpstarstructvec.peervec.clear();
						//status=sscanf(strpt,"%f %f %d %f %f %f %f %d",&tmpstarstructvec.starpoint.x_image,&tmpstarstructvec.starpoint.y_image,&tmpstarstructvec.starpoint.number,&tmpstarstructvec.starpoint.fluxerr_iso,&tmpstarstructvec.starpoint.mag_auto,&tmpstarstructvec.starpoint.magerr_auto,&tmpstarstructvec.starpoint.fwhm_image,&tmpstarstructvec.starpoint.flags);
						//status=sscanf(strpt,"%f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f",&tmpstarstructvec.starpoint.ra,&tmpstarstructvec.starpoint.dec,&tmpstarstructvec.starpoint.xcim,&tmpstarstructvec.starpoint.ycim,&tmpstarstructvec.starpoint.x_image,&tmpstarstructvec.starpoint.y_image,&tmpstarstructvec.starpoint.time,&tmpstarstructvec.starpoint.imagename,&tmpstarstructvec.starpoint.flux,&tmpstarstructvec.starpoint.flags,&tmpstarstructvec.starpoint.bgflux,&tmpstarstructvec.starpoint.threshold,
						//	&tmpstarstructvec.starpoint.mag,&tmpstarstructvec.starpoint.merr,&tmpstarstructvec.starpoint.ellipticity,&tmpstarstructvec.starpoint.class_star);
						status=sscanf(strpt,"%f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f",&tmpstarstruct.ra,&tmpstarstruct.dec,&tmpstarstruct.xcim,&tmpstarstruct.ycim,&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.time,&tmpstarstruct.imagename,&tmpstarstruct.flux,&tmpstarstruct.flags,&tmpstarstruct.bgflux,&tmpstarstruct.threshold,
								&tmpstarstruct.mag,&tmpstarstruct.merr,&tmpstarstruct.ellipticity,&tmpstarstruct.class_star);
						tmpstarstructvec.starpoint=tmpstarstruct;
						tmpstarstructvec.starpoint.imgnum=g_imgnum;
						if(status)
						{
							starmatchvec.push_back(tmpstarstructvec);

						}
					}
				}
			}
			fclose(filefp);
		}
		//write tmp file
		filefp=fopen(tmpfilename,"w");
		if(filefp!=NULL)
		{
			fprintf(filefp,"#TemplatMark tmp file\n");
			fprintf(filefp,"#FileNum %d\n",g_imgnum);
			for(i=0;i<starmatchvec.size();i++)
			{
				//status=sscanf(strpt,"%d %d %f %f %d %f %f %f %f %d",&tmpvecflag,&tmpvecnum,&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.number,&tmpstarstruct.fluxerr_iso,&tmpstarstruct.mag_auto,&tmpstarstruct.magerr_auto,&tmpstarstruct.fwhm_image,&tmpstarstruct.flags);
				//fprintf(filefp,"%f %f %d %d %d %d\n",starmatchvec[i].starpoint.x_image,starmatchvec[i].starpoint.y_image,0,0,starmatchvec[i].starpoint.imgnum,tmpflag);
				fprintf(filefp,"%d %d %f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f %d\n",1,i,starmatchvec[i].starpoint.ra,starmatchvec[i].starpoint.dec,starmatchvec[i].starpoint.xcim,starmatchvec[i].starpoint.ycim,starmatchvec[i].starpoint.x_image,starmatchvec[i].starpoint.y_image,starmatchvec[i].starpoint.time,starmatchvec[i].starpoint.imagename,starmatchvec[i].starpoint.flux,starmatchvec[i].starpoint.flags,starmatchvec[i].starpoint.bgflux,starmatchvec[i].starpoint.threshold,
						starmatchvec[i].starpoint.mag,starmatchvec[i].starpoint.merr,starmatchvec[i].starpoint.ellipticity,starmatchvec[i].starpoint.class_star,starmatchvec[i].starpoint.imgnum);

				//fprintf(filefp,"%d %d %f %f %d %f %f %f %f %d %d\n",1,i,starmatchvec[i].starpoint.x_image,starmatchvec[i].starpoint.y_image,starmatchvec[i].starpoint.number,starmatchvec[i].starpoint.fluxerr_iso,starmatchvec[i].starpoint.mag_auto,starmatchvec[i].starpoint.magerr_auto,starmatchvec[i].starpoint.fwhm_image,starmatchvec[i].starpoint.flags,starmatchvec[i].starpoint.imgnum);
				for(j=0;j<starmatchvec[i].peervec.size();j++)
				{
					fprintf(filefp,"%d %d %f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f %d\n",0,i,starmatchvec[i].peervec[j].ra,starmatchvec[i].peervec[j].dec,starmatchvec[i].peervec[j].xcim,starmatchvec[i].peervec[j].ycim,starmatchvec[i].peervec[j].x_image,starmatchvec[i].peervec[j].y_image,starmatchvec[i].peervec[j].time,starmatchvec[i].peervec[j].imagename,starmatchvec[i].peervec[j].flux,starmatchvec[i].peervec[j].flags,starmatchvec[i].peervec[j].bgflux,starmatchvec[i].peervec[j].threshold,
							starmatchvec[i].peervec[j].mag,starmatchvec[i].peervec[j].merr,starmatchvec[i].peervec[j].ellipticity,starmatchvec[i].peervec[j].class_star,starmatchvec[i].peervec[j].imgnum);

					//fprintf(filefp,"%d %d %f %f %d %f %f %f %f %d %d\n",0,i,starmatchvec[i].peervec[j].x_image,starmatchvec[i].peervec[j].y_image,starmatchvec[i].peervec[j].number,starmatchvec[i].peervec[j].fluxerr_iso,starmatchvec[i].peervec[j].mag_auto,starmatchvec[i].peervec[j].magerr_auto,starmatchvec[i].peervec[j].fwhm_image,starmatchvec[i].peervec[j].flags,starmatchvec[i].peervec[j].imgnum);

					//fprintf(filefp,"%d %d %f %f %d %d %d %d\n",0,i,starmatchvec[i].peervec[j].x_image,starmatchvec[i].peervec[j].y_image,0,0,starmatchvec[i].peervec[j].imgnum,tmpflag);

				}

			}

			fclose(filefp);
		}


	}


	else
	{
		//read tmp filename
		iftmpfile=false;
		starmatchvec.clear();
		filefp=fopen(tmpfilename,"r");
		if(filefp!=NULL)
		{
			while(!feof(filefp))
			{
				if((fgets(readbuf,512,filefp))!=NULL)
				{
					start=strspn(readbuf," \t");
					strpt=readbuf+start;
					if(*strpt==(char)'#')
					{
						rval=strcmp(strpt,"#TemplatMark tmp file");
						//printf("rval=%d\n",rval);
						if(rval>=0)
						{
							iftmpfile=true;

						}

						else
						{
							tok=strtok_r(strpt,notokstr,&tmpcharbuf);
							if(tok!=NULL)
							{
								if(strcmp(tok,"#FileNum")==0)
								{
									//printf("test 2\n");
									tok=strtok_r(NULL,notokstr,&tmpcharbuf);
									if(tok!=NULL)
									{
										g_imgnum=atoi(tok);

										//printf("g_imgnum ok =%d\n",g_imgnum);

									}
								}

							}
						}
					}
					else
					{
						if(!iftmpfile)
						{printf("tmp file is error\n");
						fclose(filefp);
						return 0;
						}
						status=sscanf(strpt,"%d %d %f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f %d",&tmpvecflag,&tmpvecnum,&tmpstarstruct.ra,&tmpstarstruct.dec,&tmpstarstruct.xcim,&tmpstarstruct.ycim,&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.time,&tmpstarstruct.imagename,&tmpstarstruct.flux,&tmpstarstruct.flags,&tmpstarstruct.bgflux,&tmpstarstruct.threshold,
								&tmpstarstruct.mag,&tmpstarstruct.merr,&tmpstarstruct.ellipticity,&tmpstarstruct.class_star,&tmpstarstruct.imgnum);
						//status=sscanf(strpt,"%d %d %f %f %d %f %f %f %f %d %d",&tmpvecflag,&tmpvecnum,&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.number,&tmpstarstruct.fluxerr_iso,&tmpstarstruct.mag_auto,&tmpstarstruct.magerr_auto,&tmpstarstruct.fwhm_image,&tmpstarstruct.flags,&tmpstarstruct.imgnum);
						if(tmpvecflag==1)
						{
							tmpstarstructvec.starpoint=tmpstarstruct;
							tmpstarstructvec.peervec.clear();
							starmatchvec.push_back(tmpstarstructvec);
						}
						else
						{
							if(tmpvecnum>=starmatchvec.size())
							{
								printf("tmp file is error 2\n");
								fclose(filefp);
								return 0;
							}
							starmatchvec[tmpvecnum].peervec.push_back(tmpstarstruct);

						}

					}


				}
			}

			fclose(filefp);
		}






		tmpvecsize=starmatchvec.size();
		g_imgnum++;
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
						//status=sscanf(strpt,"%f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f",&tmpstarstruct.ra,&tmpstarstruct.dec,&tmpstarstruct.xcim,&tmpstarstruct.ycim,&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.time,&tmpstarstruct.imagename,&tmpstarstruct.flux,&tmpstarstruct.flags,&tmpstarstruct.bgflux,&tmpstarstruct.threshold,
						//	&tmpstarstruct.mag,&tmpstarstruct.merr,&tmpstarstruct.ellipticity,&tmpstarstruct.class_star);
						status=sscanf(strpt,"%f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f",&tmpstarstruct.ra,&tmpstarstruct.dec,&tmpstarstruct.xcim,&tmpstarstruct.ycim,&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.time,&tmpstarstruct.imagename,&tmpstarstruct.flux,&tmpstarstruct.flags,&tmpstarstruct.bgflux,&tmpstarstruct.threshold,
								&tmpstarstruct.mag,&tmpstarstruct.merr,&tmpstarstruct.ellipticity,&tmpstarstruct.class_star);
						tmpstarstructvec.starpoint=tmpstarstruct;
						//status=sscanf(strpt,"%f %f %d %f %f %f %f %d",&tmpstarstruct.x_image,&tmpstarstruct.y_image,&tmpstarstruct.number,&tmpstarstruct.fluxerr_iso,&tmpstarstruct.mag_auto,&tmpstarstruct.magerr_auto,&tmpstarstruct.fwhm_image,&tmpstarstruct.flags);
						tmpstarstruct.imgnum=g_imgnum;
						ifmatch=false;
						if(status)
						{
							for(i=0;i<tmpvecsize;i++)
							{
								tmpfloat=((tmpstarstruct.x_image-starmatchvec[i].starpoint.x_image)*(tmpstarstruct.x_image-starmatchvec[i].starpoint.x_image)+(tmpstarstruct.y_image-starmatchvec[i].starpoint.y_image)*(tmpstarstruct.y_image-starmatchvec[i].starpoint.y_image));
								if(tmpfloat<maxerrpower)
								{
									ifmatch=true;
									starmatchvec[i].peervec.push_back(tmpstarstruct);
									//break;
								}
								else
								{
									for(j=0;j<starmatchvec[i].peervec.size();j++)
									{
										tmpfloat=((tmpstarstruct.x_image-starmatchvec[i].peervec[j].x_image)*(tmpstarstruct.x_image-starmatchvec[i].peervec[j].x_image)+(tmpstarstruct.y_image-starmatchvec[i].peervec[j].y_image)*(tmpstarstruct.y_image-starmatchvec[i].peervec[j].y_image));
										if(tmpfloat<maxerrpower)
										{
											ifmatch=true;
											starmatchvec[i].peervec.push_back(tmpstarstruct);
											break;
										}
									}
								}
								if(ifmatch)
									break;

							}
							if(!ifmatch)
							{
								tmpstarstructvec.peervec.clear();
								tmpstarstructvec.starpoint=tmpstarstruct;
								starmatchvec.push_back(tmpstarstructvec);
							}

						}
					}
				}
			}
			fclose(filefp);
		}

		if(fileflag>=2)
		{
			//write tmp file
			filefp=fopen(tmpfilename,"w");
			if(filefp!=NULL)
			{
				fprintf(filefp,"#TemplatMark tmp file\n");
				fprintf(filefp,"#FileNum %d\n",g_imgnum);
				for(i=0;i<starmatchvec.size();i++)
				{
					// fprintf(filefp,"%d %d %f %f %d %f %f %f %f %d %d\n",1,i,starmatchvec[i].starpoint.x_image,starmatchvec[i].starpoint.y_image,starmatchvec[i].starpoint.number,starmatchvec[i].starpoint.fluxerr_iso,starmatchvec[i].starpoint.mag_auto,starmatchvec[i].starpoint.magerr_auto,starmatchvec[i].starpoint.fwhm_image,starmatchvec[i].starpoint.flags,starmatchvec[i].starpoint.imgnum);
					fprintf(filefp,"%d %d %f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f %d\n",1,i,starmatchvec[i].starpoint.ra,starmatchvec[i].starpoint.dec,starmatchvec[i].starpoint.xcim,starmatchvec[i].starpoint.ycim,starmatchvec[i].starpoint.x_image,starmatchvec[i].starpoint.y_image,starmatchvec[i].starpoint.time,starmatchvec[i].starpoint.imagename,starmatchvec[i].starpoint.flux,starmatchvec[i].starpoint.flags,starmatchvec[i].starpoint.bgflux,starmatchvec[i].starpoint.threshold,
							starmatchvec[i].starpoint.mag,starmatchvec[i].starpoint.merr,starmatchvec[i].starpoint.ellipticity,starmatchvec[i].starpoint.class_star,starmatchvec[i].starpoint.imgnum);

					for(j=0;j<starmatchvec[i].peervec.size();j++)
					{

						//fprintf(filefp,"%d %d %f %f %d %f %f %f %f %d %d\n",0,i,starmatchvec[i].peervec[j].x_image,starmatchvec[i].peervec[j].y_image,starmatchvec[i].peervec[j].number,starmatchvec[i].peervec[j].fluxerr_iso,starmatchvec[i].peervec[j].mag_auto,starmatchvec[i].peervec[j].magerr_auto,starmatchvec[i].peervec[j].fwhm_image,starmatchvec[i].peervec[j].flags,starmatchvec[i].peervec[j].imgnum);
						fprintf(filefp,"%d %d %f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f %d\n",0,i,starmatchvec[i].peervec[j].ra,starmatchvec[i].peervec[j].dec,starmatchvec[i].peervec[j].xcim,starmatchvec[i].peervec[j].ycim,starmatchvec[i].peervec[j].x_image,starmatchvec[i].peervec[j].y_image,starmatchvec[i].peervec[j].time,starmatchvec[i].peervec[j].imagename,starmatchvec[i].peervec[j].flux,starmatchvec[i].peervec[j].flags,starmatchvec[i].peervec[j].bgflux,starmatchvec[i].peervec[j].threshold,
								starmatchvec[i].peervec[j].mag,starmatchvec[i].peervec[j].merr,starmatchvec[i].peervec[j].ellipticity,starmatchvec[i].peervec[j].class_star,starmatchvec[i].peervec[j].imgnum);

						//fprintf(filefp,"%d %d %f %f %d %d %d %d\n",0,i,starmatchvec[i].peervec[j].x_image,starmatchvec[i].peervec[j].y_image,0,0,starmatchvec[i].peervec[j].imgnum,tmpflag);

					}

				}

				fclose(filefp);
			}

		}

	}

	//t[tnum]=time(NULL);
	//tnum++;
	if(fileflag==0)   //last table
	{
		filefp=fopen(outfilename,"w");
		for(i=0;i<starmatchvec.size();i++)
		{
			//printf("test3 size=%d,minmatchnum=%d\n",starmatchvec[i].peervec.size(),minmatchnum);
			if((starmatchvec[i].peervec.size()+1)>=(minmatchnum))
			{
				tmpflag=1;
				if(outputflag!=0)
				{
					if(filefp!=NULL)
					{
						fprintf(filefp,"%f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f %d %d\n",starmatchvec[i].starpoint.ra,starmatchvec[i].starpoint.dec,starmatchvec[i].starpoint.xcim,starmatchvec[i].starpoint.ycim,starmatchvec[i].starpoint.x_image,starmatchvec[i].starpoint.y_image,starmatchvec[i].starpoint.time,starmatchvec[i].starpoint.imagename,starmatchvec[i].starpoint.flux,starmatchvec[i].starpoint.flags,starmatchvec[i].starpoint.bgflux,starmatchvec[i].starpoint.threshold,
								starmatchvec[i].starpoint.mag,starmatchvec[i].starpoint.merr,starmatchvec[i].starpoint.ellipticity,starmatchvec[i].starpoint.class_star,starmatchvec[i].starpoint.imgnum,tmpflag);

						//fprintf(filefp,"%f %f %d %d %d %d\n",starmatchvec[i].starpoint.x_image,starmatchvec[i].starpoint.y_image,0,0,starmatchvec[i].starpoint.imgnum,tmpflag);
						for(j=0;j<starmatchvec[i].peervec.size();j++)
						{
							// fprintf(filefp,"%f %f %d %d %d %d\n",starmatchvec[i].peervec[j].x_image,starmatchvec[i].peervec[j].y_image,0,0,starmatchvec[i].peervec[j].imgnum,tmpflag);
							fprintf(filefp,"%f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f %d %d\n",starmatchvec[i].peervec[j].ra,starmatchvec[i].peervec[j].dec,starmatchvec[i].peervec[j].xcim,starmatchvec[i].peervec[j].ycim,starmatchvec[i].peervec[j].x_image,starmatchvec[i].peervec[j].y_image,starmatchvec[i].peervec[j].time,starmatchvec[i].peervec[j].imagename,starmatchvec[i].peervec[j].flux,starmatchvec[i].peervec[j].flags,starmatchvec[i].peervec[j].bgflux,starmatchvec[i].peervec[j].threshold,
									starmatchvec[i].peervec[j].mag,starmatchvec[i].peervec[j].merr,starmatchvec[i].peervec[j].ellipticity,starmatchvec[i].peervec[j].class_star,starmatchvec[i].peervec[j].imgnum,tmpflag);

						}

					}
				}
			}
			else
			{
				tmpflag=0;
				if(outputflag!=1)
				{
					if(filefp!=NULL)
					{
						//fprintf(filefp,"%f %f %d %d %d %d\n",starmatchvec[i].starpoint.x_image,starmatchvec[i].starpoint.y_image,0,0,starmatchvec[i].starpoint.imgnum,tmpflag);
						fprintf(filefp,"%f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f %d %d\n",starmatchvec[i].starpoint.ra,starmatchvec[i].starpoint.dec,starmatchvec[i].starpoint.xcim,starmatchvec[i].starpoint.ycim,starmatchvec[i].starpoint.x_image,starmatchvec[i].starpoint.y_image,starmatchvec[i].starpoint.time,starmatchvec[i].starpoint.imagename,starmatchvec[i].starpoint.flux,starmatchvec[i].starpoint.flags,starmatchvec[i].starpoint.bgflux,starmatchvec[i].starpoint.threshold,
								starmatchvec[i].starpoint.mag,starmatchvec[i].starpoint.merr,starmatchvec[i].starpoint.ellipticity,starmatchvec[i].starpoint.class_star,starmatchvec[i].starpoint.imgnum,tmpflag);

						for(j=0;j<starmatchvec[i].peervec.size();j++)
						{
							// fprintf(filefp,"%f %f %d %d %d %d\n",starmatchvec[i].peervec[j].x_image,starmatchvec[i].peervec[j].y_image,0,0,starmatchvec[i].peervec[j].imgnum,tmpflag);
							fprintf(filefp,"%f %f %f %f %f %f %s %s %f %d %f %f %f %f %f %f %d %d\n",starmatchvec[i].peervec[j].ra,starmatchvec[i].peervec[j].dec,starmatchvec[i].peervec[j].xcim,starmatchvec[i].peervec[j].ycim,starmatchvec[i].peervec[j].x_image,starmatchvec[i].peervec[j].y_image,starmatchvec[i].peervec[j].time,starmatchvec[i].peervec[j].imagename,starmatchvec[i].peervec[j].flux,starmatchvec[i].peervec[j].flags,starmatchvec[i].peervec[j].bgflux,starmatchvec[i].peervec[j].threshold,
									starmatchvec[i].peervec[j].mag,starmatchvec[i].peervec[j].merr,starmatchvec[i].peervec[j].ellipticity,starmatchvec[i].peervec[j].class_star,starmatchvec[i].peervec[j].imgnum,tmpflag);

						}

					}

				}

			}

		}
		if(filefp!=NULL)
		{
			fclose(filefp);
		}
	}
	//t[tnum]=time(NULL);
	//tnum++;

	//TRACE("��%d��ͼ:t0=%d;t1=%d;t2=%d;\n",g_imgnum,t[0],t[1],t[2]);
	gettimeofday(&tv[1], NULL);

//	printf("No.%d img start time %d s %d us\n",g_imgnum,tv[0].tv_sec,tv[0].tv_usec);
//	printf("No.%d img over time %d s %d us\n",g_imgnum,tv[1].tv_sec,tv[1].tv_usec);

	return 1;
}




