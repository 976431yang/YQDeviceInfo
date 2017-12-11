//
//  YQDeviceInfo.h
//  YQDeviceInfoDevelop
//
//  Created by problemchild on 2017/11/15.
//  Copyright © 2017年 freakyyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YQDeviceInfo : NSObject

// like "11.1.2"
+ (NSString *)getIOSVersion;

// 0~1.0, '-1'means error
+ (CGFloat)getBettaryLevel;

// >0 (Mb)
+ (CGFloat)getUsedMemoryInMB;

// 0~1.0
+ (CGFloat)getCpuUsage;

// detail:NO  => "iPhone 7"
// detail:YES => "iPhone 7 美版、台版"
+ (NSString *)getDeviceNameWithDetail:(BOOL)detail;

@end
