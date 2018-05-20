//
//  MBSettingViewController.m
//  MBVideoPlayer
//
//  Created by chenda on 2018/5/14.
//  Copyright © 2018年 chenda. All rights reserved.
//

#import "MBSettingViewController.h"

#import "Masonry.h"

#import "MBFileManager.h"
#import "MBToastLabelView.h"
#import "MBNetworkManager.h"

@interface MBSettingViewController ()

@property (nonatomic) UIButton *clearCacheButton;
@property (nonatomic) UILabel *cacheSizeLabel;

@end

@implementation MBSettingViewController
#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateCacheSize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Accessors

#pragma mark - IBActions

#pragma mark - Public

#pragma mark - Private

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.clearCacheButton = [[UIButton alloc] init];
    self.clearCacheButton.backgroundColor = [UIColor redColor];
    [self.clearCacheButton setTitle:@"清除缓存" forState:UIControlStateNormal];
    [self.clearCacheButton addTarget:self action:@selector(clearCache) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.clearCacheButton];
    
    [self.clearCacheButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.width.mas_equalTo(40);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    
    self.cacheSizeLabel = [[UILabel alloc] init];
    
    [self.view addSubview:self.cacheSizeLabel];
    
    [self.cacheSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.clearCacheButton.mas_top).offset(-20);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

- (void)clearCache {
    if ([MBFileManager clearCache]) {
        [self updateCacheSize];
        [[MBNetworkManager shareInstance] clearDownloadingOffset]; //清除网络层保存的下载进度
        [self.view addSubview:[MBToastLabelView message:@"清除缓存成功" delaySecond:0.5]];
    }else {
        [self.view addSubview:[MBToastLabelView message:@"清除缓存失败" delaySecond:0.5]];
    }
}

- (void)updateCacheSize {
    long long cacheSize = [MBFileManager currentCacheSize];
    self.cacheSizeLabel.text =[NSString stringWithFormat:@"当前缓存大小：%lldM", cacheSize];
}

#pragma mark - Protocol conformance

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
