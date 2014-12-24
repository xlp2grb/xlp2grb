#ifndef TEMPLATEMARK_H_
#define TEMPLATEMARK_H_


#include <vector>
#include <string.h>
using namespace std;
typedef struct
{
	/*float x_image;
	float y_image;
	float fwhm_image;
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
	float magerr_auto;
	float minx;
	float miny;
	unsigned int peernum;
	unsigned int imgnum;*/
	float ra;
	float dec;
	float xcim;
	float ycim;
	float x_image;
	float y_image;
    char time[32];
    char imagename[256];
    float flux;
    unsigned int flags;
    float bgflux;
    float threshold;
    float mag;
    float merr;
    float ellipticity;
    float class_star;
    unsigned int imgnum;
} ST_STARSTRUCT_B;

typedef struct
{
	ST_STARSTRUCT_B starpoint;
	vector<ST_STARSTRUCT_B> peervec;
	

} ST_STARTABLE_VEC;

typedef struct
{
	vector<ST_STARSTRUCT_B> peervec;


} ST_STARTABLE_VEC_B;


extern vector <ST_STARTABLE_VEC> starmatchvec;
extern vector <ST_STARTABLE_VEC_B> starmatchvec_B;
//extern vector <ST_STARTABLE_VEC_B> starmatchvec_C;
extern unsigned int g_imgnum;
extern unsigned short g_status;
int TemplateMark(unsigned int fileflag,float maxerr,unsigned short minmatchnum,char templatename[],char tmpfilename[],unsigned short outputflag,char outfilename[]);
int TemplateMark_B(unsigned int fileflag,float maxerr,unsigned short minmatchnum,unsigned short imgloopnum,char templatename[],char tmpfilename[],unsigned short outputflag,unsigned short outputmeanflag,char outfilename[]);
int myfilter(const struct dirent *filename);



#endif 

