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
+ (NSString *)getDeviceNameWithDetail:(BOOL)detail {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    NSString *deviceSimpleString = @"";
    NSString *deviceDetailString = @"";
    
    if ([deviceString isEqualToString:@"iPhone3,1"]){deviceSimpleString = @"iPhone 4" ;};
    if ([deviceString isEqualToString:@"iPhone3,2"]){deviceSimpleString = @"iPhone 4" ;};
    if ([deviceString isEqualToString:@"iPhone3,3"]){deviceSimpleString = @"iPhone 4" ;};
    if ([deviceString isEqualToString:@"iPhone4,1"]){deviceSimpleString = @"iPhone 4S" ;};
    if ([deviceString isEqualToString:@"iPhone5,1"]){deviceSimpleString = @"iPhone 5" ;};
    if ([deviceString isEqualToString:@"iPhone5,2"]){deviceSimpleString = @"iPhone 5" ;      deviceDetailString = @"(GSM+CDMA)";};
    if ([deviceString isEqualToString:@"iPhone5,3"]){deviceSimpleString = @"iPhone 5c" ;     deviceDetailString = @"(GSM)";};
    if ([deviceString isEqualToString:@"iPhone5,4"]){deviceSimpleString = @"iPhone 5c" ;     deviceDetailString = @"(GSM+CDMA)";};
    if ([deviceString isEqualToString:@"iPhone6,1"]){deviceSimpleString = @"iPhone 5s" ;     deviceDetailString = @"(GSM)";};
    if ([deviceString isEqualToString:@"iPhone6,2"]){deviceSimpleString = @"iPhone 5s" ;     deviceDetailString = @"(GSM+CDMA)";};
    if ([deviceString isEqualToString:@"iPhone7,1"]){deviceSimpleString = @"iPhone 6 Plus" ; deviceDetailString = @"";};
    if ([deviceString isEqualToString:@"iPhone7,2"]){deviceSimpleString = @"iPhone 6" ;      deviceDetailString = @"";};
    if ([deviceString isEqualToString:@"iPhone8,1"]){deviceSimpleString = @"iPhone 6s" ;     deviceDetailString = @"";};
    if ([deviceString isEqualToString:@"iPhone8,2"]){deviceSimpleString = @"iPhone 6s Plus" ; deviceDetailString = @"";};
    if ([deviceString isEqualToString:@"iPhone8,4"]){deviceSimpleString = @"iPhone SE" ;     deviceDetailString = @"";};
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceString isEqualToString:@"iPhone9,1"]){deviceSimpleString = @"iPhone 7" ;      deviceDetailString = @"国行、日版、港行";};
    if ([deviceString isEqualToString:@"iPhone9,2"]){deviceSimpleString = @"iPhone 7 Plus" ; deviceDetailString = @"港行、国行";};
    if ([deviceString isEqualToString:@"iPhone9,3"]){deviceSimpleString = @"iPhone 7" ;      deviceDetailString = @"美版、台版";};
    if ([deviceString isEqualToString:@"iPhone9,4"]){deviceSimpleString = @"iPhone 7 Plus" ; deviceDetailString = @"美版、台版";};
    if ([deviceString isEqualToString:@"iPhone10,1"]){deviceSimpleString = @"iPhone 8" ;     deviceDetailString = @"国行(A1863)、日行(A1906)";};
    if ([deviceString isEqualToString:@"iPhone10,4"]){deviceSimpleString = @"iPhone 8" ;     deviceDetailString = @"美版(Global/A1905)";};
    if ([deviceString isEqualToString:@"iPhone10,2"]){deviceSimpleString = @"iPhone 8 Plus" ; deviceDetailString = @"国行(A1864)、日行(A1898)";};
    if ([deviceString isEqualToString:@"iPhone10,5"]){deviceSimpleString = @"iPhone 8 Plus" ; deviceDetailString = @"美版(Global/A1897)";};
    if ([deviceString isEqualToString:@"iPhone10,3"]){deviceSimpleString = @"iPhone X" ;     deviceDetailString = @"国行(A1865)、日行(A1902)";};
    if ([deviceString isEqualToString:@"iPhone10,6"]){deviceSimpleString = @"iPhone X" ;     deviceDetailString = @"美版(Global/A1901)";};
    
    if ([deviceString isEqualToString:@"iPod1,1"]){deviceSimpleString = @"iPod Touch 1G" ;};
    if ([deviceString isEqualToString:@"iPod2,1"]){deviceSimpleString = @"iPod Touch 2G" ;};
    if ([deviceString isEqualToString:@"iPod3,1"]){deviceSimpleString = @"iPod Touch 3G" ;};
    if ([deviceString isEqualToString:@"iPod4,1"]){deviceSimpleString = @"iPod Touch 4G" ;};
    if ([deviceString isEqualToString:@"iPod5,1"]){deviceSimpleString = @"iPod Touch (5 Gen)" ;};
    
    if ([deviceString isEqualToString:@"iPad1,1"]){deviceSimpleString = @"iPad";}
    if ([deviceString isEqualToString:@"iPad1,2"]){deviceSimpleString = @"iPad";             deviceDetailString = @"(3G)";}
    if ([deviceString isEqualToString:@"iPad2,1"]){deviceSimpleString = @"iPad 2";           deviceDetailString = @"(WiFi)";}
    if ([deviceString isEqualToString:@"iPad2,2"]){deviceSimpleString = @"iPad 2";}
    if ([deviceString isEqualToString:@"iPad2,3"]){deviceSimpleString = @"iPad 2";           deviceDetailString = @"(CDMA)";}
    if ([deviceString isEqualToString:@"iPad2,4"]){deviceSimpleString = @"iPad 2";}
    if ([deviceString isEqualToString:@"iPad2,5"]){deviceSimpleString = @"iPad Mini";        deviceDetailString = @"(WiFi)";}
    if ([deviceString isEqualToString:@"iPad2,6"]){deviceSimpleString = @"iPad Mini";}
    if ([deviceString isEqualToString:@"iPad2,7"]){deviceSimpleString = @"iPad Mini";        deviceDetailString = @"(GSM+CDMA)";}
    if ([deviceString isEqualToString:@"iPad3,1"]){deviceSimpleString = @"iPad 3";           deviceDetailString = @"(WiFi)";}
    if ([deviceString isEqualToString:@"iPad3,2"]){deviceSimpleString = @"iPad 3";           deviceDetailString = @"(GSM+CDMA)";}
    if ([deviceString isEqualToString:@"iPad3,3"]){deviceSimpleString = @"iPad 3";}
    if ([deviceString isEqualToString:@"iPad3,4"]){deviceSimpleString = @"iPad 4";           deviceDetailString = @"(WiFi)";}
    if ([deviceString isEqualToString:@"iPad3,5"]){deviceSimpleString = @"iPad 4";}
    if ([deviceString isEqualToString:@"iPad3,6"]){deviceSimpleString = @"iPad 4";           deviceDetailString = @"(GSM+CDMA)";}
    if ([deviceString isEqualToString:@"iPad4,1"]){deviceSimpleString = @"iPad Air";         deviceDetailString = @"(WiFi)";}
    if ([deviceString isEqualToString:@"iPad4,2"]){deviceSimpleString = @"iPad Air";         deviceDetailString = @"(Cellular)";}
    if ([deviceString isEqualToString:@"iPad4,4"]){deviceSimpleString = @"iPad Mini 2";      deviceDetailString = @"(WiFi)";}
    if ([deviceString isEqualToString:@"iPad4,5"]){deviceSimpleString = @"iPad Mini 2";      deviceDetailString = @"(Cellular)";}
    if ([deviceString isEqualToString:@"iPad4,6"]){deviceSimpleString = @"iPad Mini 2";}
    if ([deviceString isEqualToString:@"iPad4,7"]){deviceSimpleString = @"iPad Mini 3";}
    if ([deviceString isEqualToString:@"iPad4,8"]){deviceSimpleString = @"iPad Mini 3";}
    if ([deviceString isEqualToString:@"iPad4,9"]){deviceSimpleString = @"iPad Mini 3";}
    if ([deviceString isEqualToString:@"iPad5,1"]){deviceSimpleString = @"iPad Mini 4";      deviceDetailString = @"(WiFi)";}
    if ([deviceString isEqualToString:@"iPad5,2"]){deviceSimpleString = @"iPad Mini 4";      deviceDetailString = @"(LTE)";}
    if ([deviceString isEqualToString:@"iPad5,3"]){deviceSimpleString = @"iPad Air 2";}
    if ([deviceString isEqualToString:@"iPad5,4"]){deviceSimpleString = @"iPad Air 2";}
    if ([deviceString isEqualToString:@"iPad6,3"]){deviceSimpleString = @"iPad Pro 9.7";}
    if ([deviceString isEqualToString:@"iPad6,4"]){deviceSimpleString = @"iPad Pro 9.7";}
    if ([deviceString isEqualToString:@"iPad6,7"]){deviceSimpleString = @"iPad Pro 12.9";}
    if ([deviceString isEqualToString:@"iPad6,8"]){deviceSimpleString = @"iPad Pro 12.9";}
    if ([deviceString isEqualToString:@"iPad6,11"]){deviceSimpleString = @"iPad 5";          deviceDetailString = @"(WiFi)";}
    if ([deviceString isEqualToString:@"iPad6,12"]){deviceSimpleString = @"iPad 5";          deviceDetailString = @"(Cellular)";}
    if ([deviceString isEqualToString:@"iPad7,1"]){deviceSimpleString = @"iPad Pro 12.9 2nd gen";deviceDetailString = @"(WiFi)";}
    if ([deviceString isEqualToString:@"iPad7,2"]){deviceSimpleString = @"iPad Pro 12.9 2nd gen";deviceDetailString = @"(Cellular)";}
    if ([deviceString isEqualToString:@"iPad7,3"]){deviceSimpleString = @"iPad Pro 10.5";    deviceDetailString = @"(WiFi)";}
    if ([deviceString isEqualToString:@"iPad7,4"]){deviceSimpleString = @"iPad Pro 10.5";    deviceDetailString = @"(Cellular)";}
    
    if ([deviceString isEqualToString:@"AppleTV2,1"]){deviceSimpleString = @"Apple TV 2" ;}
    if ([deviceString isEqualToString:@"AppleTV3,1"]){deviceSimpleString = @"Apple TV 3" ;}
    if ([deviceString isEqualToString:@"AppleTV3,2"]){deviceSimpleString = @"Apple TV 3" ;}
    if ([deviceString isEqualToString:@"AppleTV5,3"]){deviceSimpleString = @"Apple TV 4" ;}
    
    if ([deviceString isEqualToString:@"i386"]){deviceSimpleString = @"Simulator" ;};
    if ([deviceString isEqualToString:@"x86_64"]){deviceSimpleString = @"Simulator" ;};
    
    if(detail && deviceDetailString.length>=1 && deviceSimpleString.length>=1){
        return [NSString stringWithFormat:@"%@ %@",deviceSimpleString,deviceDetailString];
    }else if(deviceSimpleString.length>=1){
        return deviceSimpleString;
    }else{
        return deviceString;
    }
}


@end
