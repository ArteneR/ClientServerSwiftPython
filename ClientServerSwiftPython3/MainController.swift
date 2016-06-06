
import UIKit

var addrFromOptionsView = String()
var portFromOptionsView = String()


class MainController: UIViewController, NSStreamDelegate {
    
    //Button
    var buttonConnect : UIButton!
    
    //Label
    var label : UILabel!
    var labelConnection : UILabel!
    
    //Socket server
    var addr: String = "192.168.0.106"
    var port: Int = 9050
    
    
    //Network variables
    var inStream : NSInputStream?
    var outStream: NSOutputStream?
    
    //Data received
    var buffer = [UInt8](count: 200, repeatedValue: 0)
    
    var marshaller = Marshallar()
    
    
    class Message {
        var operation: String = ""
        var direction: String = ""
        
        init(operation: String) {
            self.operation = operation
        }
        
        init(operation: String, direction: String) {
            self.operation = operation
            let trimmedDirection = String(direction.characters.filter{!"\n\r".characters.contains($0)})
            self.direction = trimmedDirection
        }
        
        func setDirection(direction: String) {
            self.direction = direction
        }
        
        func setOperation(operation: String) {
            self.operation = operation
        }
        
        func getDirection() -> String {
            return self.direction
        }
        
        func getOperation() -> String {
            return self.operation
        }
        
        func getMessage() -> String {
            if (direction.isEmpty) {
                return "\(operation):"
            }
            else {
                return "\(operation):\(direction)"
            }
        }
        
    }
    
    
    class Marshallar {
        
        func marshal(operation: String, parameter: String) -> String {
            return "\(operation):\(parameter)"
        }
        
        func unmarshal(packed_data: String) -> Message {
            var splittedData = packed_data.characters.split{$0 == ":"}.map(String.init)
            let op: String = splittedData[0]
            let param: String = splittedData[1]
            let trimmedParam = String(param.characters.filter{!"\n\r".characters.contains($0)})
            let message: Message = Message(operation: op, direction: trimmedParam)
            return message
        }
    
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Main Controller!")
        
        if (!addrFromOptionsView.isEmpty) {
            addr = addrFromOptionsView
        }
        if (!portFromOptionsView.isEmpty) {
            port = Int(portFromOptionsView)!
        }
        print("Address IP: \(addr)")
        print("Port: \(port)")
        
        NetworkEnable()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(MainController.handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(MainController.handleSwipes(_:)))
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(MainController.handleSwipes(_:)))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(MainController.handleSwipes(_:)))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        upSwipe.direction = .Up
        downSwipe.direction = .Down
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(upSwipe)
        view.addGestureRecognizer(downSwipe)
        
        
        let screenTap = UITapGestureRecognizer(target: self, action: #selector(MainController.handleScreenTap(_:)))
        view.addGestureRecognizer(screenTap)
        
        ButtonSetup()
        
        LabelSetup()

    }
    
    
    @IBAction func clickedBack(sender: AnyObject) {
        var data : NSData
        let messageToSend = Message(operation: "QUIT")
        data = messageToSend.getMessage().dataUsingEncoding(NSUTF8StringEncoding)!
        outStream?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }
    
    
    
    func handleSwipes(sender: UISwipeGestureRecognizer) {
        var data : NSData
        print("Swiping...");
        
        if (sender.direction == .Left) {
            print("Swiped left")
            let messageToSend = Message(operation: "SWIPE", direction: "LEFT")
            data = messageToSend.getMessage().dataUsingEncoding(NSUTF8StringEncoding)!
        }
        else if (sender.direction == .Right) {
            print("Swiped right")
            let messageToSend = Message(operation: "SWIPE", direction: "RIGHT")
            data = messageToSend.getMessage().dataUsingEncoding(NSUTF8StringEncoding)!
        }
        else if (sender.direction == .Up) {
            print("Swiped up")
            let messageToSend = Message(operation: "SWIPE", direction: "UP")
            data = messageToSend.getMessage().dataUsingEncoding(NSUTF8StringEncoding)!
        }
        else {
            print("Swiped down")
            let messageToSend = Message(operation: "SWIPE", direction: "DOWN")
            data = messageToSend.getMessage().dataUsingEncoding(NSUTF8StringEncoding)!
        }
        
        outStream?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }
    
    
    func handleScreenTap(sender: UISwipeGestureRecognizer) {
        print("Touched the screen")
        let messageToSend = Message(operation: "TOUCH_SCREEN")
        let data : NSData = messageToSend.getMessage().dataUsingEncoding(NSUTF8StringEncoding)!
        outStream?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }
    
    
    //Button Functions
    func ButtonSetup() {
        buttonConnect = UIButton(frame: CGRectMake(20, 50, 300, 30))
        buttonConnect.setTitle("Connect to server", forState: UIControlState.Normal)
        buttonConnect.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        buttonConnect.setTitleColor(UIColor.cyanColor(), forState: UIControlState.Highlighted)
        buttonConnect.addTarget(self, action: #selector(MainController.btnConnectPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(buttonConnect)
        
        let buttoniPhone = UIButton(frame: CGRectMake(20, 100, 300, 30))
        buttoniPhone.setTitle("Send \"This is iPhone\"", forState: UIControlState.Normal)
        buttoniPhone.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        buttoniPhone.setTitleColor(UIColor.cyanColor(), forState: UIControlState.Highlighted)
        buttoniPhone.addTarget(self, action: #selector(MainController.btniPhonePressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(buttoniPhone)
        
        let buttonQuit = UIButton(frame: CGRectMake(20, 150, 300, 30))
        buttonQuit.setTitle("Send \"Quit\"", forState: UIControlState.Normal)
        buttonQuit.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        buttonQuit.setTitleColor(UIColor.cyanColor(), forState: UIControlState.Highlighted)
        buttonQuit.addTarget(self, action: #selector(MainController.btnQuitPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
               
                
                let responseMessage : Message = marshaller.unmarshal(bufferStr as! String)
                print("operation: \(responseMessage.getOperation())")
                print("direction: \(responseMessage.getDirection())")
                
                let respOperation = responseMessage.getOperation()
                let respDirection = responseMessage.getDirection()
                
                if (respOperation == "SWITCH_TO_SCREEN") {
                    print("here1 \(respDirection)\(respDirection)")
                    
                    print("Opened new view controller")
                    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    let vc : UIViewController = storyboard.instantiateViewControllerWithIdentifier("MoviesLibraryController") as UIViewController
                    self.presentViewController(vc, animated: true, completion: nil)
                    print("Opened2 new view controller")
                }
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

        
        
        
        
        

    
    
    
}