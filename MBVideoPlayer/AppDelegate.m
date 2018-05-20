//
//  AppDelegate.m
//  MBVideoPlayer
//
//  Created by chenda on 2018/5/8.
//  Copyright © 2018年 chenda. All rights reserved.
//

#import "AppDelegate.h"
#import "CYLTabBarController.h"

#import "ViewController.h"
#import "MBSettingViewController.h"


@interface AppDelegate ()

@property (nonatomic) CYLTabBarController *tabBarController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setupViewControllers]; //配置UITabBarViewController
    
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    [self.window setRootViewController:self.tabBarController];
    [self.window makeKeyAndVisible];
    
    [self customizeTabBar]; //自定义tabBar的样式

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setupViewControllers {
    ViewController *firstViewController = [[ViewController alloc] init];
    MBSettingViewController *secondViewController = [[MBSettingViewController alloc] init];
    
    self.tabBarController = [[CYLTabBarController alloc] init];
    
    [self customizeTabBarForController:self.tabBarController];
    
    [self.tabBarController setViewControllers:@[firstViewController, secondViewController]];
}

- (void)customizeTabBarForController:(CYLTabBarController *)tabBarController {
    NSDictionary *dic1 = @{CYLTabBarItemTitle: @"首页", CYLTabBarItemImage: @"vide_douyin", CYLTabBarItemSelectedImage: @"video_douyin_selected"};
    NSDictionary *dic2 = @{CYLTabBarItemTitle: @"设置", CYLTabBarItemImage: @"video_setting", CYLTabBarItemSelectedImage: @"video_setting_selected"};
    
    NSArray *tabBarItemsAttributes = @[dic1, dic2];
    tabBarController.tabBarItemsAttributes = tabBarItemsAttributes;
}

- (UIImage*)createImageWithColor:(UIColor*)color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)customizeTabBar {
    [[UITabBar appearance] setBackgroundImage:[self createImageWithColor:[UIColor clearColor]]];
    
    NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
    normalAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
    
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSForegroundColorAttributeName] = [UIColor blackColor];
    
    UITabBarItem *tabBar = [UITabBarItem appearance];
    [tabBar setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    [tabBar setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
}

@end
