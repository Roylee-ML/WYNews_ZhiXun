//
//  AppDelegate.h
//  WYNews
//
//  Created by lanou3g on 15/5/28.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "RootTabBarViewController.h"
#import "AudioSmallWD.h"
#import "FMPlayListViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,strong) AudioSmallWD * smallWindow;
@property (nonatomic,strong) NSMutableDictionary * isMarkedDic; //记录存储新闻页面添加controller的个数
@property (nonatomic,assign) UIBackgroundTaskIdentifier bgTaskId;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

