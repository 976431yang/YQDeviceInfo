//
//  YQDeviceInfo.h
//  YQDeviceInfoDevelop
//
//  Created by problemchild on 2017/11/15.
//  Copyright © 2017年 freakyyang. All rights reserved.
//

#import"YQDeviceInfo.h"

#import <UIKit/UIDevice.h>

#import"sys/utsname.h"
#import "mach/mach.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation YQDeviceInfo

#pragma mark - Version
+ (NSString *)getIOSVersion {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)getAppVersion {
    NSString *app_version = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    return app_version;
}

+ (NSString *)getAppBuild {
    NSString *app_build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return app_build;
}

+ (NSString *)getAppDisplayName {
    NSString *name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    return name;
}

#pragma mark - BettaryLevel
+ (CGFloat)getBettaryLevel {
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    return (double)[[UIDevice currentDevice] batteryLevel];
}

#pragma mark - Memory
+ (CGFloat)getUsedMemoryInMB {
    vm_size_t memory = usedMemory();
    return memory / 1000.0 / 1000.0;
}
vm_size_t usedMemory(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
}

#pragma mark - CPU
+ (CGFloat)getCpuUsage {
    float cpu = cpu_usage();
    return (double)cpu * 0.01;
}

float cpu_usage() {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

#pragma mark - Wifi
+ (NSString  *)getWifiName {
    NSString *ssid = nil;
    NSArray *ifs = (__bridge   id)CNCopySupportedInterfaces();
    for (NSString *ifname in ifs) {
        NSDictionary *info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
        if (info[@"SSID"])
        {
            ssid = info[@"SSID"];
        }
    }
    return ssid;
}

#pragma mark - Device

+ (YQDevice *)device {
    return [YQDevice sharedInstance];
}

+ (NSString *)getDeviceName{
    return [self device].name;
}

@end


#define YQModel(a,b,c) [YQDeviceModel modelWithName:a modeStr:b year:c]

@interface YQDeviceModel : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * modeStr;
@property (nonatomic, assign) int year;
+ (YQDeviceModel *)createWithModelStr:(NSString *)modelStr;

@end



@interface YQDevice()

@property (nonatomic, strong) YQDeviceModel * modelObject;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, assign) int year;
/// 原始型号
@property (nonatomic, strong) NSString * model;

@end

@implementation YQDevice

+ (YQDevice *)sharedInstance {
    static YQDevice *device = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        device = [[YQDevice alloc] init];
    });
    return device;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (NSString *)model {
    if (!_model) {
        struct utsname systemInfo;
        uname(&systemInfo);
        // 获取设备标识Identifier
        NSString *platform = [NSString stringWithCString:systemInfo.machine                                     encoding:NSUTF8StringEncoding];
        _model = platform;
    }
    return _model;
}

- (YQDeviceModel *)modelObject {
    if (!_modelObject) {
        _modelObject = [YQDeviceModel createWithModelStr:self.model];
    }
    return _modelObject;
}

- (NSString *)name {
    return self.modelObject.name;
}

- (int)year {
    return self.modelObject.year;
}

@end

// MARK: - 机型对照表

@implementation YQDeviceModel

+ (YQDeviceModel *)modelWithName:(NSString *)name
                         modeStr:(NSString *)modeStr
                            year:(int)year {
    YQDeviceModel * model = [YQDeviceModel new];
    model.name = name;
    model.year = year;
    model.modeStr = modeStr;
    return model;
}

+ (YQDeviceModel *)createWithModelStr:(NSString *)modelStr {
    
    NSArray<YQDeviceModel *> *allModes = [YQDeviceModel allModes];
    
    for (int i = 0; i < allModes.count; i++) {
        YQDeviceModel * model = allModes[i];
        if ([model.modeStr isEqualToString:modelStr]) {
            return model;
        }
    }
    
    if ([modelStr containsString:@"i386"] ||
        [modelStr containsString:@"x86_64"] ||
        [modelStr containsString:@"arm"]) {
        return YQModel(@"Simulator", modelStr, 0);
    }
    
    NSString * unknowName = [NSString stringWithFormat:@"unknow(%@)",modelStr];
    return YQModel(unknowName, modelStr, 0);
}

+ (NSArray<YQDeviceModel *> *)allModes {
    // 参照：https://theapplewiki.com/wiki/Models#iPhone
    return @[
        // iPhone
        YQModel(@"iPhone", @"iPhone1,1", 2007),
        YQModel(@"iPhone 3G", @"iPhone1,2", 2008),
        YQModel(@"iPhone 3GS", @"iPhone2,1", 2009),
        
        YQModel(@"iPhone 4", @"iPhone3,1", 2010),
        YQModel(@"iPhone 4", @"iPhone3,2", 2010),
        YQModel(@"iPhone 4", @"iPhone3,3", 2010),
        
        YQModel(@"iPhone 4S", @"iPhone4,1", 2011),
        
        YQModel(@"iPhone 5", @"iPhone5,1", 2012),
        YQModel(@"iPhone 5", @"iPhone5,2", 2012),
        
        YQModel(@"iPhone 5c", @"iPhone5,3", 2013),
        YQModel(@"iPhone 5c", @"iPhone5,4", 2013),
        
        YQModel(@"iPhone 5s", @"iPhone6,1", 2013),
        YQModel(@"iPhone 5s", @"iPhone6,2", 2013),
        
        YQModel(@"iPhone 6", @"iPhone7,2", 2014),
        YQModel(@"iPhone 6 Plus", @"iPhone7,1", 2014),
        YQModel(@"iPhone 6s", @"iPhone8,1", 2015),
        YQModel(@"iPhone 6s Plus", @"iPhone8,2", 2015),
        YQModel(@"iPhone SE (1st)", @"iPhone8,4", 2016),
        
        YQModel(@"iPhone 7", @"iPhone9,1", 2016),
        YQModel(@"iPhone 7", @"iPhone9,3", 2016),
        
        YQModel(@"iPhone 7 Plus", @"iPhone9,2", 2016),
        YQModel(@"iPhone 7 Plus", @"iPhone9,4", 2016),
        
        YQModel(@"iPhone 8", @"iPhone10,1", 2017),
        YQModel(@"iPhone 8", @"iPhone10,4", 2017),
        
        YQModel(@"iPhone 8 Plus", @"iPhone10,2", 2017),
        YQModel(@"iPhone 8 Plus", @"iPhone10,5", 2017),
        
        YQModel(@"iPhone X", @"iPhone10,3", 2017),
        YQModel(@"iPhone X", @"iPhone10,6", 2017),
        
        YQModel(@"iPhone XR", @"iPhone11,8", 2018),
        YQModel(@"iPhone XS", @"iPhone11,2", 2018),
        
        YQModel(@"iPhone XS Max", @"iPhone11,6", 2018),
        YQModel(@"iPhone XS Max", @"iPhone11,4", 2018),
        
        YQModel(@"iPhone 11", @"iPhone12,1", 2019),
        YQModel(@"iPhone 11 Pro", @"iPhone12,3", 2019),
        YQModel(@"iPhone 11 Pro Max", @"iPhone12,5", 2019),
        
        YQModel(@"iPhone SE (2nd)", @"iPhone12,8", 2020),
        YQModel(@"iPhone 12 mini", @"iPhone13,1", 2020),
        YQModel(@"iPhone 12", @"iPhone13,2", 2020),
        YQModel(@"iPhone 12 Pro", @"iPhone13,3", 2020),
        YQModel(@"iPhone 12 Pro Max", @"iPhone13,4", 2020),
        
        YQModel(@"iPhone 13 mini", @"iPhone14,4", 2021),
        YQModel(@"iPhone 13", @"iPhone14,5", 2021),
        YQModel(@"iPhone 13 Pro", @"iPhone14,2", 2021),
        YQModel(@"iPhone 13 Pro Max", @"iPhone14,3", 2021),
        
        YQModel(@"iPhone SE (3rd)", @"iPhone14,6", 2022),
        YQModel(@"iPhone 14", @"iPhone14,7", 2022),
        YQModel(@"iPhone 14 Plus", @"iPhone14,8", 2022),
        YQModel(@"iPhone 14 Pro", @"iPhone15,2", 2022),
        YQModel(@"iPhone 14 Pro Max", @"iPhone15,3", 2022),
        
        YQModel(@"iPhone 15", @"iPhone15,4", 2023),
        YQModel(@"iPhone 15 Plus", @"iPhone15,5", 2023),
        YQModel(@"iPhone 15 Pro", @"iPhone16,1", 2023),
        YQModel(@"iPhone 15 Pro Max", @"iPhone16,2", 2023),
        
        YQModel(@"iPhone 16", @"iPhone17,3", 2024),
        YQModel(@"iPhone 16 Plus", @"iPhone17,4", 2024),
        YQModel(@"iPhone 16 Pro", @"iPhone17,1", 2024),
        YQModel(@"iPhone 16 Pro Max", @"iPhone17,2", 2024),
        
        // iPad
        YQModel(@"iPad", @"iPad1,1", 2010),
        
        YQModel(@"iPad 2", @"iPad2,1", 2011),
        YQModel(@"iPad 2", @"iPad2,2", 2011),
        YQModel(@"iPad 2", @"iPad2,3", 2011),
        YQModel(@"iPad 2", @"iPad2,4", 2011),
        
        YQModel(@"iPad (3rd)", @"iPad3,1", 2012),
        YQModel(@"iPad (3rd)", @"iPad3,2", 2012),
        YQModel(@"iPad (3rd)", @"iPad3,3", 2012),
        
        YQModel(@"iPad (4th)", @"iPad3,4", 2012),
        YQModel(@"iPad (4th)", @"iPad3,5", 2012),
        YQModel(@"iPad (4th)", @"iPad3,6", 2012),
        
        YQModel(@"iPad (5th)", @"iPad6,11", 2017),
        YQModel(@"iPad (5th)", @"iPad6,12", 2017),
        
        YQModel(@"iPad (6th)", @"iPad7,5", 2018),
        YQModel(@"iPad (6th)", @"iPad7,6", 2018),
        
        YQModel(@"iPad (7th)", @"iPad7,11", 2019),
        YQModel(@"iPad (7th)", @"iPad7,12", 2019),
        
        YQModel(@"iPad (8th)", @"iPad11,6", 2020),
        YQModel(@"iPad (8th)", @"iPad11,7", 2020),
        
        YQModel(@"iPad (9th)", @"iPad12,1", 2021),
        YQModel(@"iPad (9th)", @"iPad12,2", 2021),
        
        // iPad Air
        YQModel(@"iPad Air", @"iPad4,1", 2013),
        YQModel(@"iPad Air", @"iPad4,2", 2013),
        YQModel(@"iPad Air", @"iPad4,3", 2013),
        
        YQModel(@"iPad Air 2", @"iPad5,3", 2014),
        YQModel(@"iPad Air 2", @"iPad5,4", 2014),
        
        YQModel(@"iPad Air (3rd)", @"iPad11,3", 2019),
        YQModel(@"iPad Air (3rd)", @"iPad11,4", 2019),
        
        YQModel(@"iPad Air (4th)", @"iPad13,1", 2020),
        YQModel(@"iPad Air (4th)", @"iPad13,2", 2020),
        
        YQModel(@"iPad Air (5th)", @"iPad13,16", 2022),
        YQModel(@"iPad Air (5th)", @"iPad13,17", 2022),
        
        YQModel(@"iPad Air 11-inch (M2)", @"iPad14,8", 2024),
        YQModel(@"iPad Air 11-inch (M2)", @"iPad14,9", 2024),
        YQModel(@"iPad Air 13-inch (M2)", @"iPad14,10", 2024),
        YQModel(@"iPad Air 13-inch (M2)", @"iPad14,11", 2024),
        
        
        // iPad Pro
        YQModel(@"iPad Pro (12.9-inch)", @"iPad6,7", 2015),
        YQModel(@"iPad Pro (12.9-inch)", @"iPad6,8", 2015),
        
        YQModel(@"iPad Pro (9.7-inch)", @"iPad6,3", 2016),
        YQModel(@"iPad Pro (9.7-inch)", @"iPad6,4", 2016),
        
        YQModel(@"iPad Pro (12.9-inch) (2nd)", @"iPad7,1", 2017),
        YQModel(@"iPad Pro (12.9-inch) (2nd)", @"iPad7,2", 2017),
        
        YQModel(@"iPad Pro (10.5-inch)", @"iPad7,3", 2017),
        YQModel(@"iPad Pro (10.5-inch)", @"iPad7,4", 2017),
        
        YQModel(@"iPad Pro (11-inch)", @"iPad8,1", 2018),
        YQModel(@"iPad Pro (11-inch)", @"iPad8,2", 2018),
        YQModel(@"iPad Pro (11-inch)", @"iPad8,3", 2018),
        YQModel(@"iPad Pro (11-inch)", @"iPad8,4", 2018),
//        YQModel(@"iPad Pro (11-inch)", @"iPad8,3", 2018),
//        YQModel(@"iPad Pro (11-inch)", @"iPad8,4", 2018),
//        YQModel(@"iPad Pro (11-inch)", @"iPad8,3", 2018),
//        YQModel(@"iPad Pro (11-inch)", @"iPad8,4", 2018),
        
        YQModel(@"iPad Pro (12.9-inch) (3rd)", @"iPad8,5", 2018),
        YQModel(@"iPad Pro (12.9-inch) (3rd)", @"iPad8,6", 2018),
        YQModel(@"iPad Pro (12.9-inch) (3rd)", @"iPad8,7", 2018),
        YQModel(@"iPad Pro (12.9-inch) (3rd)", @"iPad8,8", 2018),
//        YQModel(@"iPad Pro (12.9-inch) (3rd)", @"iPad8,7", 2018),
//        YQModel(@"iPad Pro (12.9-inch) (3rd)", @"iPad8,8", 2018),
//        YQModel(@"iPad Pro (12.9-inch) (3rd)", @"iPad8,7", 2018),
//        YQModel(@"iPad Pro (12.9-inch) (3rd)", @"iPad8,8", 2018),
        
        YQModel(@"iPad Pro (11-inch) (2nd)", @"iPad8,9", 2020),
        YQModel(@"iPad Pro (11-inch) (2nd)", @"iPad8,10", 2020),
        
        YQModel(@"iPad Pro (12.9-inch) (4th)", @"iPad8,11", 2020),
        YQModel(@"iPad Pro (12.9-inch) (4th)", @"iPad8,12", 2020),
        
        YQModel(@"iPad Pro (11-inch) (3rd)", @"iPad13,4", 2021),
        YQModel(@"iPad Pro (11-inch) (3rd)", @"iPad13,5", 2021),
        YQModel(@"iPad Pro (11-inch) (3rd)", @"iPad13,6", 2021),
        YQModel(@"iPad Pro (11-inch) (3rd)", @"iPad13,7", 2021),
        
        YQModel(@"iPad Pro (12.9-inch) (5th)", @"iPad13,8", 2021),
        YQModel(@"iPad Pro (12.9-inch) (5th)", @"iPad13,9", 2021),
        YQModel(@"iPad Pro (12.9-inch) (5th)", @"iPad13,10", 2021),
        YQModel(@"iPad Pro (12.9-inch) (5th)", @"iPad13,11", 2021),
        
        //iPad Pro (11-inch) (4th generation) unknow
        //iPad Pro (12.9-inch) (6th generation) unknow
        
        YQModel(@"iPad Pro 11-inch (M4)", @"iPad16,3", 2024),
        YQModel(@"iPad Pro 11-inch (M4)", @"iPad16,4", 2024),
        YQModel(@"iPad Pro 13-inch (M4)", @"iPad16,5", 2024),
        YQModel(@"iPad Pro 13-inch (M4)", @"iPad16,6", 2024),
        
        
        
        // iPad Mini
        YQModel(@"iPad mini", @"iPad2,5", 2012),
        YQModel(@"iPad mini", @"iPad2,6", 2012),
        YQModel(@"iPad mini", @"iPad2,7", 2012),
        
        YQModel(@"iPad mini 2", @"iPad4,4", 2013),
        YQModel(@"iPad mini 2", @"iPad4,5", 2013),
        YQModel(@"iPad mini 2", @"iPad4,6", 2013),
        
        YQModel(@"iPad mini 3", @"iPad4,7", 2014),
        YQModel(@"iPad mini 3", @"iPad4,8", 2014),
        YQModel(@"iPad mini 3", @"iPad4,9", 2014),
        
        YQModel(@"iPad mini 4", @"iPad5,1", 2015),
        YQModel(@"iPad mini 4", @"iPad5,2", 2015),
        
        YQModel(@"iPad mini (5th)", @"iPad11,1", 2019),
        YQModel(@"iPad mini (5th)", @"iPad11,2", 2019),
        
        YQModel(@"iPad mini (6th)", @"iPad14,1", 2021),
        YQModel(@"iPad mini (6th)", @"iPad14,2", 2021),
        
        YQModel(@"iPad mini (A17 Pro)", @"iPad16,1", 2021),
        YQModel(@"iPad mini (A17 Pro)", @"iPad16,2", 2021),
        
        
        // iPod Touch
        YQModel(@"iPod touch", @"iPod1,1", 2007),
        YQModel(@"iPod touch (2nd)", @"iPod2,1", 2008),
        YQModel(@"iPod touch (3rd)", @"iPod3,1", 2009),
        YQModel(@"iPod touch (4th)", @"iPod4,1", 2010),
        YQModel(@"iPod touch (5th)", @"iPod5,1", 2012),
        YQModel(@"iPod touch (6th)", @"iPod7,1", 2015),
        YQModel(@"iPod touch (7th)", @"iPod9,1", 2019),
    ];
}

@end
