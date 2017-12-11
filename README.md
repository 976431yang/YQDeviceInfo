# YQDeviceInfo
iOS Device Infomation,like model,ios version,battery level,cpu,memory
##### iOS端 获取设备信息的简单封装

-直接拖到工程中使用

### Example Code:
##### 设备型号：
```objective-c
	NSString *modelSimple = [YQDeviceInfo getDeviceNameWithDetail:NO];
    // "iPhone 7"
    NSLog(@"%@",modelSimple);
    
    NSString *modelFull = [YQDeviceInfo getDeviceNameWithDetail:YES];
    // "iPhone 7 美版、台版"
    NSLog(@"%@",modelFull);
```

##### 系统版本：
```objective-c
    NSString *iOSVersion = [YQDeviceInfo getIOSVersion];
    // "iOSVersion : 11.1.2"
    NSLog(@"iOSVersion : %@",iOSVersion);
```


##### App版本 & Build：
```objective-c
    NSString *AppVersion = [YQDeviceInfo getAppVersion];
    // "AppVersion : 1.0"
    NSLog(@"AppVersion : %@",AppVersion);
    
    NSString *AppBuild = [YQDeviceInfo getAppBuild];
    // "AppBuild : 1"
    NSLog(@"AppBuild : %@",AppBuild);
```

##### 电量：
```objective-c
    CGFloat bettaryLevel = [YQDeviceInfo getBettaryLevel];
    // "bettary : 25%"
    NSLog(@"bettary : %.0f%%",bettaryLevel*100);
```

##### 运行内存：
```objective-c
    CGFloat memoryUse = [YQDeviceInfo getUsedMemoryInMB];
    // "memory use : 24.8 mb"
    NSLog(@"memory use : %f mb",memoryUse);
```

##### CPU：
```objective-c
    CGFloat cpuUse = [YQDeviceInfo getCpuUsage];
    // "cpu use : 12.56%";
    NSLog(@"cpu use : %.2f%%",cpuUse);
```
