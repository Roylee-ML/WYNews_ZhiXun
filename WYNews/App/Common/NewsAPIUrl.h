//
//  NewsAPIUrl.h
//  WYNews
//
//  Created by lanou3g on 15/5/28.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#ifndef WYNews_NewsAPIUrl_h
#define WYNews_NewsAPIUrl_h

#ifdef __OBJC__


#pragma mark ----新闻各个版块的id信息----

#define NEWS_CATEGORY @"http://c.m.163.com/nc/topicset/ios/subscribe/manage/listspecial.html"


#pragma mark ----头条版块的轮播图----

#define HEAD_IMAGE @"http://c.m.163.com/nc/ad/headline/0-4.html"


#pragma mark ----新闻各个版块的内容----
#warning -----两部分网址拼接，中间拼接上各个新闻版块的id-----

//URL前半部分
/*头条版块前部分网址*/
#define LISTURL_HL @"http://c.m.163.com/nc/article/headline/"

/*其他版块前部分网址*/
#define LISTURL_OTH @"http://c.m.163.com/nc/article/list/"

//URL页数部分
/*头条版块前部分网址*/
#define LISTPAGE_HL(page) [NSString stringWithFormat:@"/%d-%d.html",page>1?140+(page-2)*20:0,page>1?20:140]

/*其他版块前部分网址*/
#define LISTPAGE_OTH(page) [NSString stringWithFormat:@"/%d-20.html",(page-1)*20]

#pragma mark ----视频网址----

//#define VIDEO_URL(page) [NSString stringWithFormat:@"http://c.m.163.com/nc/video/list/V9LG4B3A0/y/%d-10.html",page*10]

#define HOME_VIDEO_URL(page) [NSString stringWithFormat:@"http://c.m.163.com/nc/video/home/%d-10.html",page*10]

#define VIDEO_URL(s_id,page) [NSString stringWithFormat:@"http://c.m.163.com/nc/video/list/%@/y/%d-10.html",s_id,page*10]


#pragma mark ----电台网址----

/*电台列表*/
#define FM_URL @"http://c.3g.163.com/nc/topicset/ios/radio/index.html"

/*电台详情*/
#define FM_PLAY_URL(docid) [NSString stringWithFormat:@"http://c.3g.163.com/nc/article/%@/full.html",docid]

/*电台详情列表*/
#define FM_LIST(tid,page) [NSString stringWithFormat:@"http://c.3g.163.com/nc/article/list/%@/%d-20.html",tid,(page-1)*20]

/*电台分类板块列表*/
#define FM_CATELIST(cid,page) [NSString stringWithFormat:@"http://c.3g.163.com/nc/topicset/ios/radio/%@/%d-20.html",cid,(page-1)*20]




#endif

#endif
