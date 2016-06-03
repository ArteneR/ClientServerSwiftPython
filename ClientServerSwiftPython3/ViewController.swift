//
//  ViewController.swift
//  ClientServerSwiftPython3
//
//  Created by Tener ArteneR on 5/17/16.
//  Copyright © 2016 Tener ArteneR. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSStreamDelegate {

    
    //Button
    var buttonConnect : UIButton!
    
    //Label
    var label : UILabel!
    var labelConnection : UILabel!
    
    //Socket server
    let addr = "192.168.0.106"
    let port = 9876
    
    //Network variables
    var inStream : NSInputStream?
    var outStream: NSOutputStream?
    
    //Data received
    var buffer = [UInt8](count: 200, repeatedValue: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ButtonSetup()
        
        LabelSetup()
    }
    
    //Button Functions
    func ButtonSetup() {
        buttonConnect = UIButton(frame: CGRectMake(20, 50, 300, 30))
        buttonConnect.setTitle("Connect to server", forState: UIControlState.Normal)
        buttonConnect.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        buttonConnect.setTitleColor(UIColor.cyanColor(), forState: UIControlState.Highlighted)
        buttonConnect.addTarget(self, action: #selector(ViewController.btnConnectPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(buttonConnect)
        
        let buttoniPhone = UIButton(frame: CGRectMake(20, 100, 300, 30))
        buttoniPhone.setTitle("Send \"This is iPhone\"", forState: UIControlState.Normal)
        buttoniPhone.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        buttoniPhone.setTitleColor(UIColor.cyanColor(), forState: UIControlState.Highlighted)
        buttoniPhone.addTarget(self, action: #selector(ViewController.btniPhonePressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(buttoniPhone)
        
        let buttonQuit = UIButton(frame: CGRectMake(20, 150, 300, 30))
        buttonQuit.setTitle("Send \"Quit\"", forState: UIControlState.Normal)
        buttonQuit.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        buttonQuit.setTitleColor(UIColor.cyanColor(), forState: UIControlState.Highlighted)
        buttonQuit.addTarget(self, action: #selector(ViewController.btnQuitPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(buttonQuit)
    }
    
    func btnConnectPressed(sender: UIButton) {
        NetworkEnable()
        
        buttonConnect.alpha = 0.3
        buttonConnect.enabled = false
        buttonConnect.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
    }
    func btniPhonePressed(sender: UIButton) {
        let data : NSData = "This is iPhone".dataUsingEncoding(NSUTF8StringEncoding)!
        outStream?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }
    func btnQuitPressed(sender: UIButton) {
        let data : NSData = "Quit".dataUsingEncoding(NSUTF8StringEncoding)!
        outStream?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }
    //Label setup function
    func LabelSetup() {
        label = UILabel(frame: CGRectMake(0,0,300,150))
        label.center = CGPointMake(view.center.x, view.center.y+100)
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 0 //Multi-lines
        label.font = UIFont(name: "Helvetica-Bold", size: 20)
        view.addSubview(label)
        
        labelConnection = UILabel(frame: CGRectMake(0,0,300,30))
        labelConnection.center = view.center
        labelConnection.textAlignment = NSTextAlignment.Center
        labelConnection.text = "Please connect to server"
        view.addSubview(labelConnection)
    }
    
    //Network functions
    func NetworkEnable() {
        
        print("NetworkEnable")
        NSStream.getStreamsToHostWithName(addr, port: port, inputStream: &inStream, outputStream: &outStream)
        
        inStream?.delegate = self
        outStream?.delegate = self
        
        inStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        outStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        inStream?.open()
        outStream?.open()
        
        buffer = [UInt8](count: 200, repeatedValue: 0)
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
        switch eventCode {
        case NSStreamEvent.EndEncountered:
            print("EndEncountered")
            labelConnection.text = "Connection stopped by server"
            inStream?.close()
            inStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            outStream?.close()
            print("Stop outStream currentRunLoop")
            outStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            buttonConnect.alpha = 1
            buttonConnect.enabled = true
        case NSStreamEvent.ErrorOccurred:
            print("ErrorOccurred")
            
            inStream?.close()
            inStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            outStream?.close()
            outStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            labelConnection.text = "Failed to connect to server"
            buttonConnect.alpha = 1
            buttonConnect.enabled = true
            label.text = ""
        case NSStreamEvent.HasBytesAvailable:
            print("HasBytesAvailable")
            
            if aStream == inStream {
                inStream!.read(&buffer, maxLength: buffer.count)
                let bufferStr = NSString(bytes: &buffer, length: buffer.count, encoding: NSUTF8StringEncoding)
                label.text = bufferStr! as String
                print(bufferStr!)
            }
            
        case NSStreamEvent.HasSpaceAvailable:
            print("HasSpaceAvailable")
        case NSStreamEvent.None:
            print("None")
        case NSStreamEvent.OpenCompleted:
            print("OpenCompleted")
            labelConnection.text = "Connected to server"
        default:
            print("Unknown")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

