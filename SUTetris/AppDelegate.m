//
//  AppDelegate.m
//  SUTetris
//
//  Created by SU on 2017/3/31.
//  Copyright © 2017年 LEC. All rights reserved.
//

#import "AppDelegate.h"
#import "TetrisViewController.h"

// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
// 如果需要使用idfa功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>

#import "AFNetworking.h"
#import "DHGuidePageHUD.h"
#import "WebViewController.h"
@interface AppDelegate ()<JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[TetrisViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    
#pragma mark - 极光推送
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    
    // Optional
    // 获取IDFA
    // 如需使用IDFA功能请添加此代码并在初始化方法的advertisingIdentifier参数中填写对应值
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    [JPUSHService setupWithOption:launchOptions appKey:@"1c1919afd4636e88e760cff5"
                          channel:@"appstore"
                 apsForProduction:1];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:@"https://appid-ioss.xx-app.com/frontApi/getAboutUs?appid=36916388" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {

    }
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

             if ([[responseObject objectForKey:@"isshowwap"] integerValue] == 1) {
                 WebViewController * web = [[WebViewController alloc] init];
                 web.url = [responseObject objectForKey:@"wapurl"];
                 if ([web.url isEqualToString:@""]) {
                     web.url = @"http://www.369.com";
                 }
                 [self.window setRootViewController:web];

                 [self qidong];

             }
             NSLog(@"这里打印请求成功要做的事");

         }

         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {

             NSLog(@"%@",error);  //这里打印错误信息

         }];
    
  
    
    
#pragma mark - 极光推送end
    
    
    return YES;
}
#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}


- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

-(void)qidong{
    
    UIImageView * imagestart = [[UIImageView alloc] initWithFrame:self.window.frame];
    [imagestart setImage:[UIImage imageNamed:@"启动图.jpg"]];
    [self.window addSubview:imagestart];
    
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [imagestart removeFromSuperview];
        NSArray *imageNameArray = @[@"介绍",@"介绍页1",@"介绍页2"];
        // 创建并添加引导页
        DHGuidePageHUD *guidePage = [[DHGuidePageHUD alloc] dh_initWithFrame:self.window.frame imageNameArray:imageNameArray buttonIsHidden:YES];
        [self.window addSubview:guidePage];

        // code to be executed on the main queue after delay
    });

    
    
    
    
}
@end
