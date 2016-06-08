import UIKit


class DownloadMoviesController: UIViewController {
    
    @IBOutlet weak var torrentURL: UITextField!
    @IBOutlet weak var torrentMagnetLink: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Download Movies Controller!")
        
    }
    
    @IBAction func clickedBack(sender: AnyObject) {
        closeDownloadMoviesWindow()
    }
    
    @IBAction func clickedDownload(sender: UIButton) {
        self.torrentURL.resignFirstResponder()
        self.torrentMagnetLink.resignFirstResponder()
        downloadMovie(torrentURL.text!, torrentMagnetLink: torrentMagnetLink.text!)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
