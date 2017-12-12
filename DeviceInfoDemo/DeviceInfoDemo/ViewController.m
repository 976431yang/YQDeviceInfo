//
//  ViewController.m
//  DeviceInfoDemo
//
//  Created by problemchild on 2017/12/11.
//  Copyright © 2017年 freakyyang. All rights reserved.
//

#import "ViewController.h"

#import <YQDeviceInfo/YQDeviceInfo.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *deviceLab;
@property (weak, nonatomic) IBOutlet UILabel *osLab;
@property (weak, nonatomic) IBOutlet UILabel *batteryLab;
@property (weak, nonatomic) IBOutlet UILabel *cpuLab;
@property (weak, nonatomic) IBOutlet UILabel *memLab;
@property (weak, nonatomic) IBOutlet UILabel *versionLab;
@property (weak, nonatomic) IBOutlet UILabel *buildLab;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateShowing) userInfo:nil repeats:YES];
    
    /*
    NSString *modelSimple = [YQDeviceInfo getDeviceNameWithDetail:NO];
    // "iPhone 7"
    NSLog(@"%@",modelSimple);
    
    NSString *modelFull = [YQDeviceInfo getDeviceNameWithDetail:YES];
    // "iPhone 7 美版、台版"
    NSLog(@"%@",modelFull);
    
    NSString *iOSVersion = [YQDeviceInfo getIOSVersion];
    // "iOSVersion : 11.1.2"
    NSLog(@"iOSVersion : %@",iOSVersion);
    
    NSString *AppVersion = [YQDeviceInfo getAppVersion];
    // "AppVersion : 1.0"
    NSLog(@"AppVersion : %@",AppVersion);
    
    NSString *AppBuild = [YQDeviceInfo getAppBuild];
    // "AppBuild : 1"
    NSLog(@"AppBuild : %@",AppBuild);
    
    CGFloat bettaryLevel = [YQDeviceInfo getBettaryLevel];
    // "bettary : 25%"
    NSLog(@"bettary : %.0f%%",bettaryLevel*100);
    
    CGFloat memoryUse = [YQDeviceInfo getUsedMemoryInMB];
    // "memory use : 24.8 mb"
    NSLog(@"memory use : %f mb",memoryUse);
    
    CGFloat cpuUse = [YQDeviceInfo getCpuUsage];
    // "cpu use : 12.56%";
    NSLog(@"cpu use : %.2f%%",cpuUse);
    */
}

- (void)updateShowing{
    self.deviceLab.text = [NSString stringWithFormat:@"Device:%@",[YQDeviceInfo getDeviceNameWithDetail:YES]];
    self.osLab.text = [NSString stringWithFormat:@"iOS:%@",[YQDeviceInfo getIOSVersion]];
    self.versionLab.text = [NSString stringWithFormat:@"AppVersion:%@",[YQDeviceInfo getAppVersion]];
    self.buildLab.text = [NSString stringWithFormat:@"AppBuild:%@",[YQDeviceInfo getAppBuild]];
    self.batteryLab.text = [NSString stringWithFormat:@"Battery:%.2f%%",[YQDeviceInfo getBettaryLevel]*100];
    self.cpuLab.text = [NSString stringWithFormat:@"CPU:%.2f%%",[YQDeviceInfo getCpuUsage]*100];
    self.memLab.text = [NSString stringWithFormat:@"Mem:%.2f mb",[YQDeviceInfo getUsedMemoryInMB]];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    long long x=0;
    for (int i=0; i<9999999; i++) {
        x = x*i;
    }
    NSLog(@"%lld",x);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
