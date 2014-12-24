//liping Xin 2012.7.24
//调试完毕 20120806


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
        int     i,j,k,m;
	float	xc1,yc2,fwhm3,mag4,merr5,num6;
        float   x1[50000],x2[50000],x3[50000],x4[50000],x5[50000],x6[50000],y3[50000];
	int     a[10];
	float	sum,average,diff,diff_sum,sigma,rationum,diffave;
	float	star_number,star_number_begin;
	float   average0,average1;
	float   nstar;
		

	char	tables[50];
 //       char    chtable1[50];
//	char	chlist[20];
	char 	*chlist;
        FILE    *fp1; 
//	FILE	*fplist;
	FILE	*fave;

	///////////////  Initiate  Variables  //////////////////
	memset(x3,0,sizeof(float));
	memset(y3,0,sizeof(float));
	
	////////////////////////////////////////////////////////

//	printf("Input list:");	
	

//	scanf("%s",&chlist);
	chlist="list_fin";

	//sprintf(chlist,"list_res");
//	printf("#\n");
	
//	printf("chlist = %s\n",chlist);
//	printf("##\n");
	
	fp1=fopen(chlist,"r");
//	printf("###\n");

	  if( remove( "averagefile_new" ) == -1 )
      		perror( "Could not delete 'averagefile_new'" );
	   else
     	 	printf( "Deleted 'averagefile_new'\n" );

	fave=fopen("averagefile_new","a+");
	
//	if(fplist)
//	{
//		printf("####\n");
//		while((fscanf(fplist,"%s",tables))!=EOF)
//   		{
			
			i=0;
			j=0;
			k=0;
			
//			printf("#####\n");
//			j++;
			//chtable1=tables;
			//strcpy(chtable1,tables);
//			printf("######\n");
		       	//printf("%d chtable1= %s\n",j, chtable1);
//		       	printf("%d tables= %s\n",j, tables);
//			printf("#######\n");
//			strcpy(chtable1,tables);
//			printf("%d chtable1= %s\n",j, chtable1);
		 	
		
//			fp1=fopen(chtable1,"r");

			
			sum=0;
 			nstar=0;    			
			if(fp1)
         		{
        	        	printf("%s is openning\n", chlist);

	        	        while((fscanf(fp1,"%f %f %f %f %f %f\n",&xc1,&yc2,&fwhm3,&mag4,&merr5,&num6))!=EOF)
	        	        {
        	                x1[i]=xc1;
        	                x2[i]=yc2;
        	                x3[i]=fwhm3;
        	                x4[i]=mag4;
        	                x5[i]=merr5;
        	                x6[i]=num6;

				sum = sum+x3[i];
			//	printf("fwhm_read=%.3f, i=%d, fwhm_res=%f,sum=%.3f\n",fwhm3, i, x3[i],sum);
				nstar=nstar+1;
				i++;
				}
				
//				star_number=x6[i-1];
				star_number=nstar;
				star_number_begin=star_number; //the star number at the begining
				average=sum/star_number;
				average0=average;
                                diff=diff_sum=0;
                                diffave=10; //the difference average between the next two average value.
                                sigma=0; 
				rationum=1;
				printf("Nstar=%.1f, average0= %.3f\n", nstar, average0);
			}
			else
              		  	printf("Could not open file\n");
				
			fclose(fp1);
			
				for(m=0;m<10;m++) //最多10次回归计算平均值
				{
					if(diffave > 0.02 && rationum > 0.5) //收敛而且数目不小于0.5倍的原始数目
					{ 
						for(i=0;i<star_number;i++) //to calculate the sigma
				       		{ 
						diff = (x3[i]-average)*(x3[i]-average);
						diff_sum=diff_sum+diff;
				//		printf("-----i=%d,average=%.3f,x3[i]=%.3f\n",i,average,x3[i]);
						}
						sigma=sqrt(diff_sum)/star_number; 
//						printf("diffave=%.3f,rationum=%.2f, m=%d\n",diffave,rationum,m);
//                        	       		printf("---average=%.3f, sigma=%.3f,star_number=%.1f,sum=%.3f\n",average,sigma,star_number,sum); 
						memset(y3,0,sizeof(float));
					        k=0;
						sum=0;
                        	       		for(j=0;j<star_number;j++) 
                        	       		 {
							if(x3[j]>average-30*sigma && x3[j]< average+30*sigma)
						  	  {
								sum=sum+x3[j];
								y3[k]=x3[j]; //give a new good table after making 30-sigma filter
//								printf("%d  %d  %.3f  %.3f %.3f  %.3f\n",k,j,x3[j],y3[k],average,sigma);
								k++;
							  }
							else
								sum=sum;
                        	       		 }
						star_number=k;
						average=sum/star_number;
						average1=average;
//						printf("average=%.3f, star_number=%.1f\n",average,star_number);
						// x3[k]={0};
						memset(x3,0,sizeof(float));
						for(i=0;i<k;i++)	
					        	x3[i]=y3[i];
//						printf("m= %d\n",m);
//						printf("star_number= %.1f\n",star_number);   
//						printf("average1= %.1f, sigma=%.1f\n",average1,sigma);
					diffave=average1-average0;
					average0=average1;
					average=average1;
					rationum=star_number/star_number_begin;
//					printf("average1= %.3f, m=%d, rationum=%.3f, diffave=%.3f\n", average1,m,rationum,diffave);
					}
					else
						break;
				  }
//				printf("k and k/star_number_begin: %d, %.3f\n",k, rationum);
				printf("m= %d, star_number_begin=%.1f\n",m,star_number_begin);
				printf("fwhmAverage = %.3f, sigma=%.3f, star_number=%.1f, ratio_num=%.1f, diff_ave=%.3f\n", average,sigma,star_number,rationum,diffave);
			//	fprintf(fave,"%s  %.3f %.1f %.3f %.3f  %.3f %.1f\n",&chtable1,sum,star_number,average,sigma,rationum,star_number_begin);
                              // fprintf(fave,"%s  %.3f %.1f %.3f %.3f\n",&chlist,sum,star_number,average,sigma);
                               fprintf(fave,"%.3f %.1f %.3f %.3f\n",sum,star_number,average,sigma);
//	 		 }

//		}
	
//	        fclose(fp1);
	        fclose(fave);
//        	fclose(fplist);

}
