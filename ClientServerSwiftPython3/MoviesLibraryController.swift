import UIKit


class MoviesLibraryController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Movies Library Controller!")
        
    }
    
    
    @IBAction func closeBtnPressed(sender: AnyObject) {
        closeMovieWindow()
    
        
    }
    
    
    @IBAction func menuBtnPressed(sender: AnyObject) {
        openMenuWindow()
        
    }
    
    
    @IBAction func playPauseBtnPressed(sender: AnyObject) {
        playPauseMovie()
        
    }
    
    
}
