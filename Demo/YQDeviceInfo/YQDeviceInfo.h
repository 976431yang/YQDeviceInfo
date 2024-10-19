//
//  YQDeviceInfo.h
//  YQDeviceInfoDevelop
//
//  Created by problemchild on 2017/11/15.
//  Copyright © 2017年 freakyyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YQDevice;

@interface YQDeviceInfo : NSObject

// like "iPhone 16 Pro Max"
+ (NSString *)getDeviceName;

// like "11.1.2"
+ (NSString *)getIOSVersion;

// like "1.0"
+ (NSString *)getAppVersion;

// like "1"
+ (NSString *)getAppBuild;

// like "****Demo"
+ (NSString *)getAppDisplayName;

// 0~1.0, '-1'means error
+ (CGFloat)getBettaryLevel;

// >0 (Mb)
+ (CGFloat)getUsedMemoryInMB;

// 0~1.0
+ (CGFloat)getCpuUsage;

// nil => No Wifi
+ (NSString  *)getWifiName;

+ (YQDevice *)device;

@end

@interface YQDevice: NSObject

+ (YQDevice *)sharedInstance;

/// 常规名称
@property (nonatomic, strong, readonly) NSString * name;

/// 年份
@property (nonatomic, assign, readonly) int year;

/// 原始型号，需要查对照表https://www.theiphonewiki.com/wiki/Models
/// 比如 常规名称iPhone8对应原始型号 (iPhone10,1)(iPhone10,4)
@property (nonatomic, strong, readonly) NSString * model;

@end
