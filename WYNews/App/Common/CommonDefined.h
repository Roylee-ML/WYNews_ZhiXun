//
//  CommonDefined.h
//  Douban
//
//  Created by y_小易 on 15/5/14.
//  Copyright (c) 2015年 lanou3g 蓝鸥科技. All rights reserved.
//


//#pragma mark --------日志设置 Log ---------
//
//#define __DEBUG_LOG_ENABLED__ 1
//
//#if __DEBUG_LOG_ENABLED__
//
//#define NSLog(s, ...) NSLog(@"DEBUG %s(%d): %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
//
//#else
//
//#define NSLog(s, ...)
//
//#endif


#pragma mark -------电台数据-------

#define kFMModelList @"fm_cList"

#define kFMListTop @"fm_top"

#define kIndex @"playIndex"

#define kDiskImage @"diskImage"

#define kDiskCover @"diskCover"

#define BackAudioMark @"backToAudio"

#define LEFT_EDGE 10.0f

#define ImagesArray @[[UIImage imageNamed:@"playing01"],[UIImage imageNamed:@"playing02"]]

#define TitleFont_Size 18

#define StandorFont [UIFont fontWithName:@"AmericanTypewriter" size:TitleFont_Size]



#define WAWA_FONT @"DFWaWaW5-GB"

#define POP_FONT @"DFPOP1W5-GB"

#define YUAN_FONT @"DFYuanW5-GB"

#define LIBIAN_FONT @"Libian SC"

#define WEBEI_FONT @"Weibei-SC-Bold"

#define TITLE_FONT @"Libian SC"

#define HODER_IMG @"kawayi"

#define HeadViewKey @"headViewKey"

#define DownLoadKey @"downloadDataKey"

#define NC_IMG @""
#define BACK_ICON @"back"
#define BACK_ICON_HL @"back"
#define TIME_ICON @"audionews_playlist_duration"
#define PLAYCOUNT_ICON @"video_play_icon"
#define ENTER_ICON @"jinru_icon"
#define LISTENCOUNT_ICON @"erji_icon"

#define LINE_HEIGHT [UIScreen mainScreen].bounds.size.width/40

#pragma mark --------程序进入后台通知--------

#define kBecomeInActive @"becomeInActive"

#define kBecomeActive @"becomeActive"



