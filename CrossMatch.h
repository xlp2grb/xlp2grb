/*
 * CrossMatch.h
 *
 *  Created on: 2012-11-21
 *      Author: chb
 */

#ifndef CROSSMATCH_H_
#define CROSSMATCH_H_



typedef struct
{
	float x_image;
	float y_image;
	float flux;
	int flag;
	float bgflux;
	float threshold;
	float mag;
	float merr;
	float ellipticity;
	float class_star;


	/*float fwhm_image;
	float mag_aper;
	float magerr_aper;
	unsigned int number;
	float ellipticity;
	unsigned int flags;
	float mag_isocor;
	float magerr_isocor;
	float background;
	float threshold;
	float flux_aper;
	float fluxerr_iso;
	float mag_auto;
	float magerr_auto;*/

} ST_STARSTRUCT;


struct ST_PIXMAP
{
 unsigned int flag;
 unsigned short matchnum;
 unsigned char ifcenter;

};



int CrossMatch(int imgcols,int imgrows,unsigned int maxerr,char imgtablename[],char templatename[],char outfilename[]);
int pixcorrect(float pixcol,float pixrow,float *deltax,float *deltay);
unsigned int maxpixcorrect();
//int CrossMatch_B(int imgcols,int imgrows,unsigned int maxerr,char imgtablename[],char templatename[],char outfilename[]);
//int CrossMatch_C(int imgcols,int imgrows,unsigned int maxerr,char imgtablename[],char templatename[],char outfilename[]);
int CrossMatch_C(int imgcols,int imgrows,float maxerr,float magerr,char imgtablename[],char templatename[],char outfilename[]);


#endif /* CROSSMATCH_H_ */
