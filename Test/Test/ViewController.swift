import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        label.text = NSLocalizedString("text", comment: "")
    }
}
