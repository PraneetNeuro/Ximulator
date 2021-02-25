//
//  ContentView.swift
//  Ximulator
//
//  Created by Praneet S and Meghana Khuntia
//  Copyright © 2020 Praneet S. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var devices:[String] = []
    @State var networks:[String] = ["wifi","3g","4g"]
    @State var selection = ""
    @State var path = ""
    @State var hours = "9"
    @State var minutes = "41"
    @State var network = "wifi"
    @State var batteryModes:[String] = ["charging","charged","discharging"]
    @State var battery = "charged"
    @State var batteryLevel:Double = 10
    @State var clipboard = "Pasteboard: "
    
    func shell(args: [String], executableURL: URL){
        let result = Process()
        result.executableURL = executableURL
        result.arguments = args
        try! result.run()
    }
    
    func screenshot(){
        //xcrun simctl io booted screenshot screen.png
        //xcrun simctl addmedia booted ~/Desktop/simctl_list.gif
        let executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        shell(args: ["simctl","io","booted","screenshot","~/Desktop/screenshot.png"], executableURL: executableURL)
    }
    
    func getDeviceID() -> String {
        let uuid = self.selection.split(separator: " ").reversed()[1]
        return String(uuid).replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
    }
    
    func updateTime(){
        //xcrun simctl status_bar "iPhone 11" override --time 9:41
        let executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        shell(args: ["simctl","status_bar","\(getDeviceID())","override","--time","\(hours):\(minutes)"], executableURL: executableURL)
    }
    
    func updateBattery(){
        //xcrun simctl status_bar "iPhone 11" override --time 9:41
        let executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        shell(args: ["simctl","status_bar","\(getDeviceID())","override","--batteryState","\(battery)"], executableURL: executableURL)
    }
    
    func updateBatteryLevel(){
        //xcrun simctl status_bar "iPhone 11" override --time 9:41
        let executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        shell(args: ["simctl","status_bar","\(getDeviceID())","override","--batteryLevel","\(Int(batteryLevel))"], executableURL: executableURL)
    }
    
    func updateDataNetwork(){
        //xcrun simctl status_bar "iPhone 11" override --time 9:41
        let executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        shell(args: ["simctl","status_bar","\(getDeviceID())","override","--dataNetwork","\(network)"], executableURL: executableURL)
    }
    
    func shutdown(){
        let executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        shell(args: ["simctl","shutdown","\(getDeviceID())"], executableURL: executableURL)
        self.loadSims()
    }
    
    func addMedia(path:String){
        //xcrun simctl addmedia booted ~/Desktop/simctl_list.gif
        let executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        shell(args: ["simctl","addmedia","booted", path], executableURL: executableURL)
    }
    
    func installApp(path:String){
        //xcrun simctl addmedia booted ~/Desktop/simctl_list.gif
        let executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        shell(args: ["simctl","install","booted", path], executableURL: executableURL)
    }
    
    func process(res:[Substring]) -> [String] {
        var temp:[String] = []
        for element in res {
            if element.contains("-") && !element.contains("/Applications") && !element.contains("Unavailable") && !element.contains("runtime"){
                temp.append("\(element)")
            }
        }
        return temp
    }
    
    func loadSims(){
        let executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        let out = Pipe()
        let result = Process()
        result.executableURL = executableURL
        result.arguments = ["simctl","list","-v","devices"]
        result.standardOutput = out
        try! result.run()
        let res = String(data: out.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?.split(separator: "\n")
        self.devices = self.process(res: res!)
    }
    
    var body: some View {
        
        VStack {
            
            VStack{
                
                HStack{
                    Image("iphone")
                        .resizable()
                        .frame(width: 77, height: 92, alignment: .center)
                    Text("Ximulator").font(.largeTitle)
                    Text("(Beta 1)").font(.system(size: 8))
                }
                
                Picker(selection: $selection, label: Text("Device List")) {
                    ForEach(devices,id: \.self){ item in
                        Text(item).tag(1)
                    }
                    
                }
                
                Button(action: {
                    let executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
                    let result = Process()
                    result.executableURL = executableURL
                    let UUID = self.selection.split(separator: " ").reversed()[1]
                    let ID = String(UUID).replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
                    result.arguments = ["simctl","boot","\(ID)"]
                    try! result.run()
                    try! Process.run(URL(fileURLWithPath: "/usr/bin/open"), arguments: ["-a","simulator"], terminationHandler: nil)
                }, label: {Text("Run simulator")})
                
                Button(action: {
                    self.screenshot()
                }, label: {Text("Take screenshot")}).disabled(selection == "" ? true : false)
            }
            
            HStack{
                TextField("Absolute path of the media file", text: $path)
                Button(action: {
                    self.addMedia(path: self.path)
                }, label: {Text("Add media")}).disabled(selection == "" ? true : false)
            }
            
            Button(action: {
                self.shutdown()
            }, label: {Text("shutdown simulator")}).disabled(selection == "" ? true : false)
            
            Text("Status bar customization")
                .padding(.top,5)
                .padding(.bottom,5)
            
            HStack{
                Text("Time")
                    .padding(.trailing,15)
                TextField("Hours", text: $hours)
                TextField("Minutes", text: $minutes)
                Button(action: {
                    self.updateTime()
                }, label: {Text("Update Time")}).disabled(selection == "" ? true : false)
            }
            
            HStack{
                Text("Data Network")
                    .padding(.trailing,15)
                Picker(selection: $network, label: Text("Device List")) {
                    ForEach(networks,id: \.self){ item in
                        Text(item).tag(1)
                    }
                }
                Button(action: {
                    self.updateDataNetwork()
                }, label: {Text("Update data network")}).disabled(selection == "" ? true : false)
                
                
            }
            
            HStack{
                Text("Battery stats")
                    .padding(.trailing,15)
                Picker(selection: $battery, label: Text("Mode")) {
                    ForEach(batteryModes,id: \.self){ item in
                        Text(item).tag(1)
                    }
                }
                Button(action: {
                    self.updateBattery()
                }, label: {Text("Update battery state")}).disabled(selection == "" ? true : false)
                
                
            }
            
            HStack{
                Text("Battery level")
                Slider(value: $batteryLevel, in: 0...100, step: 1.0, onEditingChanged: {_ in self.updateBatteryLevel()})
                    .frame(width: 250)
                    .disabled(selection == "" ? true : false)
            }
            
            Text("Install Application")
            HStack{
                TextField("Absolute path of the .app", text: $path)
                Button(action: {
                    self.installApp(path: self.path)
                }, label: {Text("Install")}).disabled(selection == "" ? true : false)
            }
            
        }.onAppear(perform: {self.loadSims()})
            .padding(25)
        
    }
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}

