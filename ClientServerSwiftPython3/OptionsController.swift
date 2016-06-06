
import UIKit


class OptionsController: UIViewController {

    @IBOutlet weak var server_ip: UITextField!
    @IBOutlet weak var server_port: UITextField!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Options Controller!")
        
    }
    
    @IBAction func pressedConfirmBtn(sender: AnyObject) {
        addrFromOptionsView = server_ip.text!
        portFromOptionsView = server_port.text!
    }

}