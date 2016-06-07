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
    
    @IBAction func clickedDownload(sender: AnyObject) {
        downloadMovie(torrentURL.text!, torrentMagnetLink: torrentMagnetLink.text!)
    }
    
}
