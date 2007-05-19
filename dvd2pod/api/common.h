/* $Id: common.h,v 1.51 2005/11/04 13:09:40 titer Exp $

   This file is part of the HandBrake source code.
   Homepage: <http://handbrake.m0k.org/>.
   It may be used under the terms of the GNU General Public License. */

#ifndef HB_COMMON_H
#define HB_COMMON_H

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <unistd.h>
#include <inttypes.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>

#ifndef MIN
#define MIN( a, b ) ( (a) > (b) ? (b) : (a) )
#endif
#ifndef MAX
#define MAX( a, b ) ( (a) > (b) ? (a) : (b) )
#endif

#define EVEN( a )        ( (a) + ( (a) & 1 ) )
#define MULTIPLE_16( a ) ( 16 * ( ( (a) + 8 ) / 16 ) )

typedef struct hb_handle_s hb_handle_t;
typedef struct hb_list_s hb_list_t;
typedef struct hb_rate_s hb_rate_t;
typedef struct hb_job_s  hb_job_t;
typedef struct hb_title_s hb_title_t;
typedef struct hb_chapter_s hb_chapter_t;
typedef struct hb_audio_s hb_audio_t;
typedef struct hb_subtitle_s hb_subtitle_t;
typedef struct hb_state_s hb_state_t;
typedef union  hb_esconfig_u     hb_esconfig_t;
typedef struct hb_work_private_s hb_work_private_t;
typedef struct hb_work_object_s  hb_work_object_t;
typedef struct hb_buffer_s hb_buffer_t;
typedef struct hb_fifo_s hb_fifo_t;
typedef struct hb_lock_s hb_lock_t;

#include "ports.h"
#ifdef __LIBMEDIAFORK__
#include "internal.h"
#endif

hb_list_t * hb_list_init();
int         hb_list_count( hb_list_t * );
void        hb_list_add( hb_list_t *, void * );
void        hb_list_rem( hb_list_t *, void * );
void      * hb_list_item( hb_list_t *, int );
void        hb_list_close( hb_list_t ** );

void hb_reduce( int *x, int *y, int num, int den );

#define HB_KEEP_WIDTH  0
#define HB_KEEP_HEIGHT 1
void hb_fix_aspect( hb_job_t * job, int keep );

int hb_calc_bitrate( hb_job_t *, int size );

struct hb_rate_s
{
    char * string;
    int    rate;
};

#define HB_ASPECT_BASE 9
#define HB_VIDEO_RATE_BASE   27000000

extern hb_rate_t hb_video_rates[];
extern int       hb_video_rates_count;
extern hb_rate_t hb_audio_rates[];
extern int       hb_audio_rates_count;
extern int       hb_audio_rates_default;
extern hb_rate_t hb_audio_bitrates[];
extern int       hb_audio_bitrates_count;
extern int       hb_audio_bitrates_default;

/******************************************************************************
 * hb_job_t: settings to be filled by the UI
 *****************************************************************************/
struct hb_job_s
{
    /* Pointer to the title to be ripped */
    hb_title_t    * title;
    
    /* Chapter selection */
    int             chapter_start;
    int             chapter_end;

    /* Picture settings:
         crop:                must be multiples of 2 (top/bottom/left/right)
         deinterlace:         0 or 1
         width:               must be a multiple of 16
         height:              must be a multiple of 16
         keep_ratio:          used by UIs 
         pixel_ratio:         store pixel aspect ratio in the video
         pixel_aspect_width:  numerator for pixel aspect ratio
         pixel_aspect_height: denominator for pixel aspect ratio */

    int             crop[4];
    int             deinterlace;
    int             width;
    int             height;
    int             keep_ratio;
    int             grayscale;
    int             pixel_ratio;
    int             pixel_aspect_width;
    int             pixel_aspect_height;

    /* Video settings:
         vcodec:            output codec
         vquality:          output quality (0.0..1.0)
                            if < 0.0 or > 1.0, bitrate is used instead
         vbitrate:          output bitrate (kbps)
         pass:              0, 1 or 2
         vrate, vrate_base: output framerate is vrate / vrate_base */
#define HB_VCODEC_MASK   0x0000FF
#define HB_VCODEC_FFMPEG 0x000001
#define HB_VCODEC_XVID   0x000002
#define HB_VCODEC_X264   0x000004

    int             vcodec;
    float           vquality;
    int             vbitrate;
    int             vrate;
    int             vrate_base;
    int             pass;
    int             h264_13;
	int				h264_level;
	int				crf;
	
    /* Audio tracks:
         Indexes in hb_title_t's audios list, starting from 0.
         -1 indicates the end of the list */
    int             audios[8];

    /* Audio settings:
         acodec:   output codec
         abitrate: output bitrate (kbps)
         arate:    output samplerate (Hz)
       HB_ACODEC_AC3 means pass-through, then abitrate and arate are
       ignored */
#define HB_ACODEC_MASK   0x00FF00
#define HB_ACODEC_FAAC   0x000100
#define HB_ACODEC_LAME   0x000200
#define HB_ACODEC_VORBIS 0x000400
#define HB_ACODEC_AC3    0x000800
#define HB_ACODEC_MPGA   0x001000
#define HB_ACODEC_LPCM   0x002000
    int             acodec;
    int             abitrate;
    int             arate;

    /* Subtitle settings:
         subtitle: index in hb_title_t's subtitles list, starting
         from 0. -1 means no subtitle */
    int             subtitle;

    /* Muxer settings
         mux:  output file format
         file: file path */
#define HB_MUX_MASK 0xFF0000
#define HB_MUX_MP4  0x010000
#define HB_MUX_PSP  0x020000
#define HB_MUX_AVI  0x040000
#define HB_MUX_OGM  0x080000
#define HB_MUX_IPOD 0x100000
	
    int             mux;
    char          * file;

#ifdef __LIBMEDIAFORK__
    /* Internal data */
    hb_handle_t   * h;
    hb_lock_t     * pause;
    volatile int  * die;
    volatile int    done;

    hb_fifo_t     * fifo_mpeg2;   /* MPEG-2 video ES */
    hb_fifo_t     * fifo_raw;     /* Raw pictures */
    hb_fifo_t     * fifo_sync;    /* Raw pictures, framerate corrected */
    hb_fifo_t     * fifo_render;  /* Raw pictures, scaled */
    hb_fifo_t     * fifo_mpeg4;   /* MPEG-4 video ES */

    hb_thread_t   * reader;
    hb_thread_t   * muxer;

    hb_list_t     * list_work;

    hb_esconfig_t config;

    hb_mux_data_t * mux_data;
#endif
};

struct hb_audio_s
{
    int  id;
    char lang[1024];
    char lang_simple[1024];
    int  codec;
    int  rate;
    int  bitrate;
    int  channels;

#ifdef __LIBMEDIAFORK__
    /* Internal data */
    hb_fifo_t * fifo_in;   /* AC3/MPEG/LPCM ES */
    hb_fifo_t * fifo_raw;  /* Raw audio */
    hb_fifo_t * fifo_sync; /* Resampled, synced raw audio */
    hb_fifo_t * fifo_out;  /* MP3/AAC/Vorbis ES */

    hb_esconfig_t config;
    hb_mux_data_t * mux_data;
#endif
};

struct hb_chapter_s
{
    int      index;
    int      cell_start;
    int      cell_end;
    int      block_start;
    int      block_end;
    int      block_count;

    /* Visual-friendly duration */
    int      hours;
    int      minutes;
    int      seconds;

    /* Exact duration (in 1/90000s) */
    uint64_t duration;
};

struct hb_subtitle_s
{
    int  id;
    char lang[1024];

#ifdef __LIBMEDIAFORK__
    /* Internal data */
    hb_fifo_t * fifo_in;  /* SPU ES */
    hb_fifo_t * fifo_raw; /* Decodec SPU */
#endif
};

struct hb_title_s
{
    char        dvd[1024];
    char        name[1024];
    int         index;
    int         vts;
    int         ttn;
    int         cell_start;
    int         cell_end;
    int         block_start;
    int         block_end;
    int         block_count;

    /* Visual-friendly duration */
    int         hours;
    int         minutes;
    int         seconds;

    /* Exact duration (in 1/90000s) */
    uint64_t    duration;

    int         width;
    int         height;
    int         aspect;
    int         rate;
    int         rate_base;
    int         crop[4];

    uint32_t    palette[16];

    hb_list_t * list_chapter;
    hb_list_t * list_audio;
    hb_list_t * list_subtitle;

    /* Job template for this title */
    hb_job_t  * job;
};


struct hb_state_s
{
#define HB_STATE_IDLE     1
#define HB_STATE_SCANNING 2
#define HB_STATE_SCANDONE 4
#define HB_STATE_WORKING  8
#define HB_STATE_PAUSED   16
#define HB_STATE_WORKDONE 32
#define HB_STATE_MUXING   64
    int state;

    union
    {
        struct
        {
            /* HB_STATE_SCANNING */
            int title_cur;
            int title_count;
        } scanning;

        struct
        {
            /* HB_STATE_WORKING */
            float progress;
            int   job_cur;
            int   job_count;
            float rate_cur;
            float rate_avg;
            int   hours;
            int   minutes;
            int   seconds;
        } working;

        struct
        {
            /* HB_STATE_WORKDONE */
#define HB_ERROR_NONE     0
#define HB_ERROR_CANCELED 1
#define HB_ERROR_UNKNOWN  2
            int error;
        } workdone;

        struct
        {
            /* HB_STATE_MUXING */
            float progress;
        } muxing;
    } param;
};

struct hb_work_object_s
{
    int                 id;
    char              * name;

#ifdef __LIBMEDIAFORK__
    int              (* init)  ( hb_work_object_t *, hb_job_t * );
    int              (* work)  ( hb_work_object_t *, hb_buffer_t **,
                                 hb_buffer_t ** );
    void             (* close) ( hb_work_object_t * );

    hb_fifo_t         * fifo_in;
    hb_fifo_t         * fifo_out;
    hb_esconfig_t     * config;

    hb_work_private_t * private_data;

    hb_thread_t       * thread;
    volatile int      * done;

    hb_work_object_t  * next;
	int				  thread_sleep_interval;
#endif
};

extern hb_work_object_t hb_sync;
extern hb_work_object_t hb_decmpeg2;
extern hb_work_object_t hb_decsub;
extern hb_work_object_t hb_render;
extern hb_work_object_t hb_encavcodec;
extern hb_work_object_t hb_encxvid;
extern hb_work_object_t hb_encx264;
extern hb_work_object_t hb_deca52;
extern hb_work_object_t hb_decavcodec;
extern hb_work_object_t hb_declpcm;
extern hb_work_object_t hb_encfaac;
extern hb_work_object_t hb_enclame;
extern hb_work_object_t hb_encvorbis;

#endif
