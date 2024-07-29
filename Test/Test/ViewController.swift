import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var modebutton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func modeButtonTapped(_ sender: UIButton) {
        let selectorVC = SelectorVC()
        selectorVC.modalPresentationStyle = .popover
        selectorVC.preferredContentSize = CGSize(width: 200, height: 200)
        
        let navController = UINavigationController(rootViewController: selectorVC)
        navController.modalPresentationStyle = .popover
        if let popoverController = navController.popoverPresentationController {
            popoverController.delegate = self
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = .up
        }
        
        present(navController, animated: true, completion: nil)
    }
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIDevice.current.userInterfaceIdiom == .pad ? .popover : .none
    }
}
