import UIKit
import MemeApiHandler
import Kingfisher
import AVKit

//MARK: - UITableViewController
class MemeTableVC: UIViewController {

    //Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var modeSelectButton: UIBarButtonItem!
    @IBOutlet private weak var settingsButton: UIBarButtonItem!
    
    //Const values
    struct Const {
        //For in-app navigation
        static let cellReuseId = "memeCell"
        static let settingsSegueID = "settingsSegue"
        //For cell configuration
        static let defaultCellHeight: CGFloat = 200
    }
    
    //Variables
    private var memes: [Meme] = []
    private var cellHeights: [IndexPath: CGFloat] = [:]
    private var isLoading = false
    
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPhotos()
        configureUI()
    }
}

//MARK: - API Manager Request
extension MemeTableVC {
    //Request endpoint
    private func loadPhotos() {
        configureApiParameters()
        execureRequest()
    }
    
    private func configureApiParameters() {
        MemeApiManager.setSubredditName(Subreddits.deadbydaylight.rawValue)
        MemeApiManager.setQuantity(10)
    }
    
    private func execureRequest() {
        isLoading = true
        MemeApiManager.loadMemesCompilation { memes in
            if let memes = memes {
                self.memes.append(contentsOf: memes)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            self.isLoading = false
        }
    }
}

//MARK: - UI Configuration
extension MemeTableVC {
    private func configureUI() {
        configureNavigationbar()
        configureTableView()
    }
    
    private func configureNavigationbar() {
        modeSelectButton.title = "Selector"
        settingsButton.title = "Customize"
    }
    
    private func configureTableView() {
        //Table behavior
        tableView.dataSource = self
        tableView.delegate = self
        //Customizing table style
        tableView.backgroundColor = UIColor.systemGray6
        tableView.separatorStyle = .none
        //Registering custom Cell
        tableView.register(MemeViewCell.self, forCellReuseIdentifier: Const.cellReuseId)
    }
}

//MARK: - Table Delegate
extension MemeTableVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = cellHeights[indexPath] {
            return height
        }
        return Const.defaultCellHeight
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - (1 * Const.defaultCellHeight) {
            guard !isLoading else { return }
            loadPhotos()
        }
    }
}

//MARK: - Table Data Source
extension MemeTableVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.cellReuseId, for: indexPath) as! MemeViewCell
        //Getting corresponding meme
        let meme = memes[indexPath.row]
        let urlString = meme.urlString
        if let url = URL(string: urlString ?? String()) {
            switch meme.postHint {
            case "image":
                adjustCellUsingImage(cell: cell, indexPath: indexPath, url: url)
                cell.setupWithImage(url: url)
            case "hosted:video":
                if meme.secureMedia != nil && meme.secureMedia?.redditVideo != nil {
                    let videoUrl = (meme.secureMedia?.redditVideo?.fallbackUrl)!
                    adjustCellUsingVideo(cell: cell, indexPath: indexPath, url: videoUrl, using: (meme.secureMedia?.redditVideo)!)
                    cell.setupWithVideo(url: videoUrl)
                } else {
                    cell.setupDefault()
                }
            default:
                cell.setupDefault()
            }
        } else {
            cell.setupDefault()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

//MARK: - Utils
extension MemeTableVC {
    //Getting desired image using Kingfisher
    private func adjustCellUsingImage(cell: MemeViewCell, indexPath: IndexPath, url: URL) {
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                let image = value.image
                let width = image.size.width
                let height = image.size.height
                let resolution = (width, height)
                self.adjustCellHeight(cell: cell, indexPath: indexPath, using: resolution)
            case .failure(let error):
                print("Error loading image: \(error.localizedDescription)")
            }
        }
    }
    
    //Getting image using preview generator
    private func adjustCellUsingVideo(cell: MemeViewCell, indexPath: IndexPath, url: URL, using mediaInfo: RedditVideo) {
        let width = CGFloat(mediaInfo.width)
        let height = CGFloat(mediaInfo.height)
        let resolution = (width, height)
        self.adjustCellHeight(cell: cell, indexPath: indexPath, using: resolution)
    }
    
    //Using image, received via both methods above, we update cell height via image resolution aspect
    private func adjustCellHeight(cell: MemeViewCell, indexPath: IndexPath, using resolution: (width: CGFloat, height: CGFloat)) {
        let aspectRatio = resolution.height / resolution.width
        let adjustedCellHeight = cell.frame.width * aspectRatio
        self.cellHeights[indexPath] = adjustedCellHeight
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
}

//MARK: - Navigation
extension MemeTableVC {

    @IBAction func modeSelectorButtonPressed(_ sender: Any) {
        // Handle mode selector button press
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: Const.settingsSegueID, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Const.settingsSegueID:
            let _ = segue.destination as! SettingsVC
        default: break
        }
    }
}
