//
//  ShareManger.m
//  WYNews
//
//  Created by lanou3g on 15/5/28.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "ShareManger.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "CustomProgressView.h"
#import "DataBaseHandle.h"
#import "OnePlayer.h"
#import "Mantle.h"
#import "NSObject+UIAlert.h"

#define SELF_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define STATUS_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height

typedef void(^AlertBlock)();

@interface ShareManger()

//@property (nonatomic,strong) NSMutableDictionary * loadMarkDic; //记录存储新闻页面添加controller的个数

@property (nonatomic,copy) RefreshBlock refreshBlock;
@property (nonatomic,copy) RefreshHDBlock refreshHDBlock;
@property (nonatomic,strong) UIAlertView * alert;
@property (nonatomic,strong) MBProgressHUD * hud;
@property (nonatomic,assign) BOOL hudHide;
@property (nonatomic,copy) HUDBlock hudBlock;
@property (nonatomic,copy) PlaceBlock hoderBlock;
@property (nonatomic,copy) AlertBlock alertBlock;
@property (nonatomic,strong) NSTimer * myTimer;
@property (nonatomic,strong) NSMutableDictionary * downloadDic;
@property (nonatomic,strong) NSMutableDictionary * downloadingDic;


@end

@implementation ShareManger

-(instancetype)init
{
    if ([super init]) {
        //保证多任务恢复下载时的临时存储路径各不相同。允许连续创建50个可恢复下载的对象。
        self.pathNumArray = [@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"50"] mutableCopy];
        self.currentVideoSid = @"";
    }
    return self;
}

+(ShareManger*)defoutManger
{
    static ShareManger * manger = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manger = [[ShareManger alloc]init];
    });
    return manger;
}

+(void)getModelWithUrl:(NSURL*)url andByHandle:(DataBlock)block
{
    NSMutableArray * array = [NSMutableArray array];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    
//    dispatch_queue_t queue = dispatch_queue_create("com.mengliang.zhixun.model", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        NSData * data = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSArray * arr = dic[@"V9LG4B3A0"];
                for (NSDictionary * mdic in arr) {
                    VideoModel * model = [[VideoModel alloc]init];
                    [model setValuesForKeysWithDictionary:mdic];
                    [array addObject:model];
                }
                
                block(array);
            }
        });
    });
}

+ (void)getHomeVideoListWithPage:(int)page
                      mVideoList:(MHomeVideoList *)videoList
              complicationHandle:(DataBlock)result
                     errorHandle:(void(^)(NSError * error))errorHandle
{
    NSURL * url = [NSURL URLWithString:HOME_VIDEO_URL(page)];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        NSError * error = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        ;
        NSDictionary * jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        [videoList configMHomeVideoListWithJsonDic:jsonDic];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (nil != error) {
                errorHandle(error);
            }else {
                result(videoList);
            }
        });
    });
}

+ (void)getVideoListWithSortID:(NSString *)s_id
                          page:(int)page
                    mVideoList:(MVideoList *)videoList
            complicationHandle:(DataBlock)result
                   errorHandle:(void(^)(NSError * error))errorHandle
{
    [ShareManger defoutManger].currentVideoSid = s_id;
    NSURL * url = [NSURL URLWithString:VIDEO_URL(s_id,page)];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        NSError * error = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        ;
        NSDictionary * jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        [videoList configMVideoListWithJsonDic:jsonDic];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (nil != error) {
                errorHandle(error);
            }else {
                result(videoList);
            }
        });
    });
}

//解析电台数据
+(void)getFMDataWithUrl:(NSURL*)url andByHandle:(FMDataBlock)block
{
    NSMutableDictionary * dataDic = [NSMutableDictionary dictionary];
    NSMutableArray * array = [NSMutableArray array];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
//    dispatch_queue_t queue = dispatch_queue_create("com.mengliang.zhixun.fmdata", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        
        NSData * data = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary * daDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSArray * arr = daDic[@"cList"];
                for (NSDictionary * dic in arr) {
                    FMModel * model = [[FMModel alloc]init];
                    [model setValuesForKeysWithDictionary:dic];
                    [array addObject:model];
                }
                //将列表板块model数组加入字典
                [dataDic setValue:array forKey:kFMModelList];
                
//                NSArray * topArr = daDic[@"top"];
//                FMSubModel * topModel = [[FMSubModel alloc]init];
//                [topModel setValuesForKeysWithDictionary:topArr[0]];
                
                // 提取轻松一刻板块的model
                FMModel * topModel = [[FMModel alloc]init];
                [topModel setValuesForKeysWithDictionary:arr[0]];
                
                FMSubModel * subTopModel = (FMSubModel *)topModel.subModelArray[1];
                
                NSLog(@"topArray = %@",[(FMModel*)array[0] subModelArray]);
                
                //将头视图model加入字典
                [dataDic setValue:subTopModel forKey:kFMListTop];
            }
            
            block(dataDic);
        });
    });
}

//解析播放数据-获取正在播放数据
+(void)getFMPlayingDataWithUrl:(NSString*)docid andByHandle:(PlayBlock)playBlock
{
    NSURL * url = [NSURL URLWithString:FM_PLAY_URL(docid)];
    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_queue_t queue = dispatch_queue_create("com.mengliang.zhixun.playing", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        NSData * data = [NSData dataWithContentsOfURL:url];
        if (!data) {
            return;
        }
        NSLog(@"url ===========------ %@",url);
        NSDictionary * h_dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSDictionary * b_dic = h_dic[docid];
        
        FMPlayingModel * model = [[FMPlayingModel alloc]init];
        [model setValuesForKeysWithDictionary:b_dic];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            playBlock(model);
        });
    });
}

//解析播放数据
+(void)getFMPlayListDataWithUrl:(NSString*)tid page:(int)page andByHandle:(DataBlock)listBlock
{
    NSURL * url = [NSURL URLWithString:FM_LIST(tid, page)];
    
    NSMutableArray *dataArray = [NSMutableArray array];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
//    dispatch_queue_t queue = dispatch_queue_create("com.mengliang.zhixun.playlist", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        NSData * data = [NSData dataWithContentsOfURL:url];
        
        if (!data) {
            return ;
        }
        
        NSDictionary * h_dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSArray * array = h_dic[tid];
        for (NSDictionary * b_dic in array) {
            FMListModel * model = [[FMListModel alloc]init];
            [model setValuesForKeysWithDictionary:b_dic];
            
            [dataArray addObject:model];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            listBlock(dataArray);
        });
    });
}

//解析板块列表数据
+(void)getFMCateListDataWithUrl:(NSString*)cid page:(int)page andByHandel:(DataBlock)cateBlock
{
    NSURL * url = [NSURL URLWithString:FM_CATELIST(cid, page)];
    
    NSMutableArray *dataArray = [NSMutableArray array];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
//    dispatch_queue_t queue = dispatch_queue_create("com.mengliang.zhixun.category", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        
        NSData * data = [NSData dataWithContentsOfURL:url];
        if (!data) {
            return ;
        }
        
        NSDictionary * h_dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSArray * array = h_dic[@"tList"];
        for (NSDictionary * b_dic in array) {
            FMSubModel * model = [[FMSubModel alloc]init];
            [model setValuesForKeysWithDictionary:b_dic];
            
            [dataArray addObject:model];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cateBlock(dataArray);
        });
    });
}

//创建推出页面播放显示小窗口
+(void)showPlayingSmallWindowWith:(FMPlayingModel*)playingModel name:(NSString*)cateName title:(NSString*)title dbKey:(NSString*)dockey
{
    NSString * docid = playingModel.docid;
    AppDelegate * dele = [[UIApplication sharedApplication]delegate];
    if (!dele.smallWindow) {
        dele.smallWindow = [[AudioSmallWD alloc]initWithFrame:[[UIApplication sharedApplication] statusBarFrame]]; 
    }
    if (cateName && docid) {
        [dele.smallWindow showWindowWithMessage:[NSString stringWithFormat:@"正在播放: %@:%@",cateName,title]];
    }else if (cateName) {
        [dele.smallWindow showWindowWithMessage:[NSString stringWithFormat:@"正在播放: %@",cateName]];
    }else{
        [dele.smallWindow showWindowWithMessage:[NSString stringWithFormat:@"正在播放: %@",title]];
    }
    dele.smallWindow.docid = docid;
    dele.smallWindow.tname = cateName;
    dele.smallWindow.docidKey = dockey;
    dele.smallWindow.playingModel = playingModel;
    
    [[OnePlayer onePlayer]monitorProgressWith:dele.smallWindow.progress Slider:nil];
}

//显示小视窗
+(void)showPlayingSmallWindow
{
    AppDelegate * dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (dele.smallWindow && dele.smallWindow.hidden == YES) {
        [dele.smallWindow showWindow];
    }
}

//隐藏小视窗
+(void)hidenSmallWindow
{
    AppDelegate * dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (dele.smallWindow) {
        [dele.smallWindow hideWindow];
    }
}

//创建导航栏替换视图
-(void)setupNavigationViewToVC:(UIViewController*)viewController withTitleImg:(UIImage*)img andBGImg:(UIImage*)bg_img
{
    //    UIWindow * window = [[[UIApplication sharedApplication]delegate]window];
    
    if ([NSStringFromClass([viewController class]) isEqualToString:@"UINavigationController"]) {
        UINavigationController * NC = (UINavigationController*)viewController;
        
        CGFloat nc_height = NC.navigationBar.frame.size.height;
        
        UIImageView * ncImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH, nc_height+STATUS_HEIGHT)];
        ncImgView.backgroundColor = [UIColor redColor];
        ncImgView.image = bg_img;
        
        //创建清除缓存按钮
        [[ShareManger defoutManger]setupClearButtonToView:ncImgView];
        
        [NC.view addSubview:ncImgView];
        
        UIImageView * titleImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH/5, nc_height*2/3)];
        
        //        titleImgView.backgroundColor = [UIColor yellowColor];
        titleImgView.image = img;
        titleImgView.clipsToBounds = YES;
        titleImgView.center = CGPointMake(SELF_WIDTH/2, nc_height/2+STATUS_HEIGHT);
        
        [NC.view  addSubview:titleImgView];
    }else{
        CGFloat nc_height = viewController.navigationController.navigationBar.frame.size.height;
        
        //用于截获响应事件
        UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH, nc_height+STATUS_HEIGHT)];
        [viewController.view addSubview:bgView];
        
        UIImageView * ncImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH, nc_height+STATUS_HEIGHT)];
        ncImgView.backgroundColor = [UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1];
        ncImgView.image = bg_img;
        ncImgView.userInteractionEnabled = NO;
        
        viewController.navigationController.navigationBar.translucent = YES;
        UINavigationController * NC = (UINavigationController*)[viewController parentViewController];
        NC.navigationBarHidden = YES;
        [bgView addSubview:ncImgView];
        
        UIImageView * titleImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH/6, nc_height*2/3)];
        
        //        titleImgView.backgroundColor = [UIColor yellowColor];
        titleImgView.image = img;
        titleImgView.clipsToBounds = YES;
        titleImgView.contentMode = UIViewContentModeScaleAspectFit;
        titleImgView.userInteractionEnabled = NO;
        titleImgView.center = CGPointMake(SELF_WIDTH/2, nc_height/2+STATUS_HEIGHT);
        
        [bgView  addSubview:titleImgView];
        
        if (!_alertBlock) {
            self.alertBlock = ^{
                [ShareManger clearAlertShowByVC:viewController];
            };
        }
        
        //创建清除缓存按钮
        [self setupClearButtonToView:bgView];
    }
}

//设置缓存清除按钮
-(void)setupClearButtonToView:(UIView*)view
{
    UIButton * clearBT = [[UIButton alloc]initWithFrame:CGRectMake(SELF_WIDTH - 10 - SELF_WIDTH/15, STATUS_HEIGHT + SELF_WIDTH/50, SELF_WIDTH/15, SELF_WIDTH/15)];
    clearBT.clipsToBounds = YES;
    [clearBT setImage:[[UIImage imageNamed:@"qingchu"] imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    clearBT.alpha = 0.8;
    [clearBT addTarget:self action:@selector(clearDisk) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:clearBT];
}

//清除缓存按钮事件
-(void)clearDisk
{
    if (self.alertBlock) {
        self.alertBlock();
    }
}

+(void)clearAlertShowByVC:(UIViewController*)controller
{
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[SDImageCache sharedImageCache]clearDisk];
        [[SDImageCache sharedImageCache]clearMemory];
        
        //删除下载数据
        NSFileManager * fileManger = [NSFileManager defaultManager];
        NSArray * array = [DataBaseHandle getDataArrayWithTitleid:DownLoadKey];
        if (array.count != 0) {
            for (FMPlayingModel * playingModel in array) {
                NSString * docuPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
                NSString * path = [docuPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",playingModel.docid]];
                NSError * error = nil;
                if ([fileManger fileExistsAtPath:path]) {
                    [fileManger removeItemAtPath:path error:&error];
                }
                if (error) {
                    NSLog(@"删除下载数据失败.........");
                }
            }
        }
        
        if ([fileManger fileExistsAtPath:[self getPath]]) {
            NSError * error = nil;
            [fileManger removeItemAtPath:[self getPath] error:&error];
            if (error) {
                NSLog(@"删除下载记录失败.........");
            }
        }
        
        [DataBaseHandle deleteAllData];
        
        if ([OnePlayer onePlayer].isPlaying) {
            [[OnePlayer onePlayer]pause]; 
        }
    }];
    
    UIAlertAction * c_action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    
    
    NSString * fileSize = [ShareManger getFileSizeInString];
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"您确定清除共计%@缓存？",fileSize] preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:action];
    [alert addAction:c_action];
    
    [controller presentViewController:alert animated:YES completion:^{
        
    }];
}

//获取字节字符串格式
+(NSString*)getFileSizeInString
{
    NSUInteger size = [ShareManger getFileSizeAtPath:[DataBaseHandle databaseFilePath]];
    NSString * fileSize = size/(1024.0*1024.0)>=0.05?[NSString stringWithFormat:@"%.2fM",size/(1024.0*1024.0)]:@"0M";
    return fileSize;
}

//获取文件字节大小
+(NSUInteger)getFileSizeAtPath:(NSString*)path
{
    long long size = 0;
    
    NSFileManager * fileManger = [NSFileManager defaultManager];
    if ([fileManger fileExistsAtPath:path]) {
        size = [fileManger attributesOfItemAtPath:path error:nil].fileSize;
    }
    

    NSArray * array = [DataBaseHandle getDataArrayWithTitleid:DownLoadKey];
    if (array) {
        for (FMPlayingModel * playingModel in array) {
            NSString * path = playingModel.url_mp4;
            if ([fileManger fileExistsAtPath:path]) {
                size += [fileManger attributesOfItemAtPath:path error:nil].fileSize;
            }
        }
    }

    
    size += [[SDImageCache sharedImageCache]getSize];
    
    return (NSUInteger)size;
}

//解析新闻页面数据
+(void)jsonDataUrl:(NSString *)url Stringkey:(NSString *)str andByHandle:(Back)back
{
    //创建网址对象
    NSURL * kindUrl=[[NSURL alloc]initWithString:url];
    //创建请求方式对象
    NSURLRequest* request=[[NSURLRequest alloc]initWithURL:kindUrl cachePolicy:(NSURLRequestReloadIgnoringLocalCacheData) timeoutInterval:60.0];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (data==nil) {
            return ;
        }
        NSMutableArray * dataArray=[[NSMutableArray alloc ]init];
        //json解析数据
        NSDictionary * dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
//        NSLog(@"解析数据dic === %@",dic);
        
        NSArray * array=[dic objectForKey:str];
        
        for (int i=0; i<array.count; i++) {
            NSDictionary * dict=array[i];
            //有没有额外图片
            if (dict[@"imgextra"]!=nil) {
                //获得图片数组
                NSArray * imgArray=dict[@"imgextra"];
                //获取数组中图片的字典
                NSDictionary * imgDic1=imgArray[0];
                NSString * urlImage1=imgDic1[@"imgsrc"];
                //取出的图片网址添加到原来的字典中
                [dict setValue:urlImage1 forKey:@"imgsrc1"];
                
                NSDictionary * imgDic2=imgArray[1];
                NSString * urlImage2=imgDic2[@"imgsrc"];
                [dict setValue:urlImage2 forKey:@"imgsrc2"];
                DataModel * dataModel=[[DataModel alloc]init];
                [dataModel setValuesForKeysWithDictionary:dict];
                [dataArray addObject:dataModel];
            }else{
                //没有直接封装成model类
                DataModel * dataModel=[[DataModel alloc]init];
                [dataModel setValuesForKeysWithDictionary:dict];
                [dataArray addObject:dataModel];
            }
            
        }
        back(dataArray);
    }];
}

//加载新闻页面，添加标记
+(void)setMarkWithMark:(NSString*)mark
{
    AppDelegate * app = [UIApplication sharedApplication].delegate;
    [app.isMarkedDic setValue:mark forKey:mark];
}
//设置固定标记
+(void)setMark:(NSString*)mark
{
    AppDelegate * app = [UIApplication sharedApplication].delegate;
    [app.isMarkedDic setValue:mark forKey:@"dbMark"];
}
//获取固定标记
+(NSString*)getMark
{
    AppDelegate * app = [UIApplication sharedApplication].delegate;
    NSString * mar = [app.isMarkedDic valueForKey:@"dbMark"];
    return mar;
}

//判断标记是否存在
+(BOOL)isMarkedWithMark:(NSString*)mark
{
    AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    id ismark = [app.isMarkedDic objectForKey:mark];
    if (ismark) {
        return YES;
    }else{
        return NO;
    }
}

//存储音乐刷新页数
+(void)setRefreshPage:(NSInteger)page
{
    AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app.isMarkedDic setObject:@(page) forKey:@"FMRefreshpPage"];
}

//获取音乐刷新页数
+(NSInteger)getRefreshPage
{
    AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSInteger page = [[app.isMarkedDic objectForKey:@"FMRefreshpPage"]integerValue];
    return page;
}

//判断设备网络
-(void)judgeNetStatusAndAlert
{
    NSString * state = [ShareManger networkingStatusFromStatebar];
    
    if (![state isEqualToString:@"wifi"]) {
        if ([state isEqualToString:@"notReachable"]) {
            self.alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您当前的网络不给力！" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [_alert show];
            [self performSelector:@selector(hideAlert) withObject:nil afterDelay:1.5f];
        }else {
            self.alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"您当前使用的是%@网络！",state] delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [_alert show];
            [self performSelector:@selector(hideAlert) withObject:nil afterDelay:1.5f];
        }
    }
}

-(void)hideAlert
{
    [_alert dismissWithClickedButtonIndex:0 animated:YES];
}

+(NSString*)networkingStatusFromStatebar
{
    UIApplication * app = [UIApplication sharedApplication];
    
    NSArray * children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    
    int type = 0;
    for (id child in children) {
        if ([child isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            type = [[child valueForKeyPath:@"dataNetworkType"] intValue];
        }
    }
    
    NSString * stateStr = @"wifi";
    switch (type) {
        case 0:
            stateStr = @"notReachable";
            break;
        case 1:
            stateStr = @"2G";
            break;
        case 2:
            stateStr = @"3G";
            break;
        case 3:
            stateStr = @"4G";
            break;
        case 4:
            stateStr = @"LTE";
            break;
        case 5:
            stateStr = @"wifi";
            break;
        default:
            break;
    }
    return stateStr;
}

//显示占位进度
-(void)showProgressHUDToView:(UIView*)view overTimeByHandle:(HUDBlock)handle
{
    self.hud = [[MBProgressHUD alloc]initWithView:view];
    [view addSubview:_hud];
    
    _hud.mode = MBProgressHUDModeIndeterminate;
    
    [_hud show:YES];
    self.hudHide = NO;
    
    //超时自动处理
    if (_myTimer) {
        [_myTimer invalidate];
        _myTimer = nil;
    }
    _myTimer  = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(showNetworkBad) userInfo:nil repeats:NO];
    
    self.hudBlock = handle;
}

-(void)showNetworkBad
{
    if (!self.hudHide) {
        [self hideProgressHUD];
        
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您当前的网络不给力，请刷新页面！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
        if (_hudBlock) {
            _hudBlock();
        }
    }
}

//隐藏占位进度
-(void)hideProgressHUD
{
    if (_hud) {
        [_hud show:NO];
        [_hud hide:YES];
        [_hud removeFromSuperview];
        _hud = nil;
        self.hudHide = YES;
        
        [self.myTimer invalidate];
        _myTimer = nil;
    }
}

//添加占位图片
-(void)placeHoderViewToView:(UIView*)view
{
    CustomProgressView * placeView = [[CustomProgressView alloc]initWithFrame:view.frame];
    [view addSubview:placeView];
    [view bringSubviewToFront:placeView];
    
    self.hoderBlock = ^{
        [placeView removeFromSuperview];
    };
}

//移除占位图
-(void)removeHoderView
{
    if (_hoderBlock) {
        _hoderBlock();
    }
}

#pragma maek -------下载记录设置，沙盒永久存储
//设置记录
-(void)setDownloadMarkWith:(NSString*)mark
{
    [self.downloadDic setObject:mark forKey:mark];
    
    [self.downloadDic writeToFile:[ShareManger getPath] atomically:YES];
}

//判断记录是否存在
-(BOOL)isDownloadWith:(NSString*)mark
{
    id obj = [self.downloadDic objectForKey:mark];
    if (obj) {
        return YES;
    }else{
        return NO;
    }
}

//删除下载记录
-(void)deleteDownloadMarkWith:(NSString*)mark
{
    if ([self isDownloadWith:mark]) {
        [self.downloadDic removeObjectForKey:mark];
        [self.downloadDic writeToFile:[ShareManger getPath] atomically:YES];
    }
}

//删除所有下载记录
-(void)deleteAllDownloadMark
{
    [self.downloadDic removeAllObjects];
    [self.downloadDic writeToFile:[ShareManger getPath] atomically:YES];
}

+(NSString*)getPath
{
    NSString * catchPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString * path = [catchPath stringByAppendingPathComponent:@"downloadMark.text"];
    
    return path;
}

-(void)writeToPath
{
    [self.downloadDic writeToFile:[ShareManger getPath] atomically:YES];
}

-(NSMutableDictionary*)downloadDic
{
    if (!_downloadDic) {
        NSFileManager * fileManger = [NSFileManager defaultManager];
        if ([fileManger fileExistsAtPath:[ShareManger getPath]]) {
            
            _downloadDic = [NSMutableDictionary dictionaryWithContentsOfFile:[ShareManger getPath]];
            
        }else{
            _downloadDic = [@{} mutableCopy];
            [_downloadDic writeToFile:[ShareManger getPath] atomically:YES];
            
        }
    }
    return _downloadDic;
}

#pragma mark -------正在下载记录,临时存储
-(NSMutableDictionary*)downloadingDic
{
    if (!_downloadingDic) {
        _downloadingDic = [NSMutableDictionary dictionary];
    }
    return _downloadingDic;
}

//设置正在下载标记
-(void)setDownloadingMarkWith:(NSString*)mark
{
    if (nil != mark) {
        [self.downloadingDic setObject:mark forKey:mark];
    }
}

//判断正在下载标记是否存在
-(BOOL)isDownloadingWith:(NSString*)mark
{
    id mar = [self.downloadingDic objectForKey:mark];
    if (mar) {
        return YES;
    }else{
        return NO;
    }
}

//删除一个标记
-(void)deleteDownloadingMarkWith:(NSString*)mark
{
    if (nil != mark) {
        [self.downloadingDic removeObjectForKey:mark];
    }
}

//删除所有正在下载标记
-(void)deleteAllDownloadingMark
{
    [self.downloadingDic removeAllObjects];
}

//显示网络不好提示框
+(void)showConnectToNetFail
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"加载失败" message:@"你当前的网络不给力！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

@end
