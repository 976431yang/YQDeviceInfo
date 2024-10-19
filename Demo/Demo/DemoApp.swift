//
//  DemoApp.swift
//  Demo
//
//  Created by 杨奇 on 2024/10/19.
//

import SwiftUI

class ViewModel: ObservableObject {
    
    @Published var deviceName = YQDeviceInfo.getDeviceName()
    @Published var iOSVersion = YQDeviceInfo.getIOSVersion()
    @Published var appVersion = YQDeviceInfo.getAppVersion()
    @Published var appBuild = YQDeviceInfo.getAppBuild()
    
    @Published var battery = YQDeviceInfo.getBettaryLevel()
    @Published var mem = YQDeviceInfo.getUsedMemoryInMB()
    @Published var cpu = YQDeviceInfo.getCpuUsage()
    @Published var wifi = YQDeviceInfo.getWifiName()
    
    func update() {
        battery = YQDeviceInfo.getBettaryLevel()
        mem = YQDeviceInfo.getUsedMemoryInMB()
        cpu = YQDeviceInfo.getCpuUsage()
        wifi = YQDeviceInfo.getWifiName()
    }
    
    func startUpdate() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.update()
        }
    }
    
    init () {
        startUpdate()
    }
}



@main
struct DemoApp: App {
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some Scene {
        
        WindowGroup {
            ContentView().environmentObject(viewModel)
        }
    }
}
