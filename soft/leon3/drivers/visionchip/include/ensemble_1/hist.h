/**************************/
/***    UNCLASSIFIED    ***/
/**************************/

/***

ALL SOURCE CODE PRESENT IN THIS FILE IS UNCLASSIFIED AND IS
BEING PROVIDED IN SUPPORT OF THE DARPA PERFECT PROGRAM.

THIS CODE IS PROVIDED AS-IS WITH NO WARRANTY, EXPRESSED, IMPLIED, 
OR OTHERWISE INFERRED. USE AND SUITABILITY FOR ANY PARTICULAR
APPLICATION IS SOLELY THE RESPONSIBILITY OF THE IMPLEMENTER. 
NO CLAIM OF SUITABILITY FOR ANY APPLICATION IS MADE.
USE OF THIS CODE FOR ANY APPLICATION RELEASES THE AUTHOR
AND THE US GOVT OF ANY AND ALL LIABILITY.

THE POINT OF CONTACT FOR QUESTIONS REGARDING THIS SOFTWARE IS:

US ARMY RDECOM CERDEC NVESD, RDER-NVS-SI (JOHN HODAPP), 
10221 BURBECK RD, FORT BELVOIR, VA 22060-5806

THIS HEADER SHALL REMAIN PART OF ALL SOURCE CODE FILES.

***/


#ifndef _HIST_H
#define _HIST_H

#include "defs.h"
#include "types.h"

// nBpp = Number of Bits per pixel; if bytes required, I use nBytesPP

int hist(algPixel_t *streamA, int *h, int nRows, int nCols, int nBpp);
int histEq(algPixel_t *streamA, algPixel_t *out, int *h, int nRows, int nCols, int nInpBpp, int nOutBpp);
//int histEq(algPixel_t *streamA, algPixel_t *out, int nRows, int nCols, int nInpBpp, int nOutBpp);


#endif //_HIST_H
