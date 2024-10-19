//
//  ContentView.swift
//  Demo
//
//  Created by 杨奇 on 2024/10/19.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        HStack {
            VStack {
                Text("Device:").frame(width:100, alignment: .leading)
                Text("iOSVersion:").frame(width:100, alignment: .leading).frame(width:100, alignment: .leading)
                Text("appVersion:").frame(width:100, alignment: .leading)
                Text("appBuild:").frame(width:100, alignment: .leading)
                Text("battery:").frame(width:100, alignment: .leading)
                Text("mem:").frame(width:100, alignment: .leading)
                Text("cpu:").frame(width:100, alignment: .leading)
                Text("wifi:").frame(width:100, alignment: .leading)
            }
            .padding()
            VStack {
                Text(viewModel.deviceName ?? "unknow").frame(width:100, alignment: .leading)
                Text(viewModel.iOSVersion ?? "unknow").frame(width:100, alignment: .leading)
                Text(viewModel.appVersion ?? "unknow").frame(width:100, alignment: .leading)
                Text(viewModel.appBuild ?? "unknow").frame(width:100, alignment: .leading)
                Text("\(viewModel.battery)").frame(width:100, alignment: .leading)
                Text("\(viewModel.mem)").frame(width:100, alignment: .leading)
                Text("\(viewModel.cpu)").frame(width:100, alignment: .leading)
                Text(viewModel.wifi ?? "unknow").frame(width:100, alignment: .leading)
            }
            .padding()
        }
        
        Button(action: {
            useCPU()
        }) {
            Text("use cpu")
        }
    }
    
    func useCPU() {
        let queue = DispatchQueue.global(
            qos: DispatchQoS.QoSClass.background)
        queue.async {
            var num = 0;
            for _ in 0 ..< 10000 {
                let new = arc4random() % 10000;
                num += Int(new);
                print("num:\(num)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    @StateObject static var viewModel = ViewModel()

    static var previews: some View {
        ContentView().environmentObject(viewModel)
    }
}
