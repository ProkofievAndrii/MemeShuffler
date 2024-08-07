//
//  MemeTableVC.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 9.07.2024.
//

import UIKit
import AVKit
import Kingfisher
import MemeApiHandler
import CommonUtils

class MemeTableVC: UIViewController {

    // Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var modeSelectButton: UIButton!
    @IBOutlet private weak var settingsButton: UIButton!

    // Const values
    struct Const {
        // Navigation
        static let cellReuseId = "memeCell"
        static let settingsSegueID = "settingsSegue"
        static let memeSegueID = "memeSegue"
        // UI scaling
        static let defaultCellHeight: CGFloat = 200
        static let navigationButtonsWidth: CGFloat = 80
    }

    // Variables
    private var memes: [Meme] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private var cellHeights: [IndexPath: CGFloat] = [:] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }
    
    private var isLoading = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsManager.defaultSubreddit = "memes"
        SettingsManager.defaultLoadingQuantity = 20
        configureUI()
        loadMemes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideUserInterfaceStyle = SettingsManager.interfaceTheme == 0 ? .light : .dark
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: - API Manager Request
extension MemeTableVC {
    private func loadMemes() {
        configureApiParameters()
        executeRequest()
    }
    
    private func configureApiParameters() {
        MemeApiManager.setQuantity(MemeApiManager.getQuantity())
        MemeApiManager.setSubredditName(MemeApiManager.getSubredditName())
    }

    private func executeRequest() {
        isLoading = true
        MemeApiManager.loadMemesCompilation { [weak self] memes in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let memes = memes {
                    self.memes.append(contentsOf: memes)
                }
                self.isLoading = false
            }
        }
    }
    
    private func resetApiState() {
        MemeApiManager.setInitial(true)
        MemeApiManager.setAfter(nil)
        memes.removeAll()
        cellHeights.removeAll()
    }
    
    private func updatedMemeRequest() {
        resetApiState()
        loadMemes()
    }
    
    private func optionalMemeRequest(_ option: String) {
        resetApiState()
    }
}

extension MemeTableVC: SelectionDelegate {
    func didSelectSubreddit(_ subreddit: String) {
        MemeApiManager.setSubredditName(subreddit)
        self.title = "r/\(subreddit)"
        updatedMemeRequest()
    }
    
    func didSelectOption(_ option: String) {
        self.title = "\(option)"
        print(option)
    }
    
    func didSelectFilter(_ filter: String) {
        MemeApiManager.setFilter(filter)
        updatedMemeRequest()
    }
}

// MARK: - UI Configuration
extension MemeTableVC {
    private func configureUI() {
        configureNavigationbar()
        configureTableView()
    }

    private func configureNavigationbar() {
        self.title = "r/\(SettingsManager.defaultSubreddit)"
        modeSelectButton.setImage(UIImage(systemName: "list.bullet.clipboard.fill"), for: .normal)
        settingsButton.setImage(UIImage(systemName: "gearshape.2.fill"), for: .normal)
        
        //Setting similar button width
        NSLayoutConstraint.activate([
            modeSelectButton.widthAnchor.constraint(equalToConstant: Const.navigationButtonsWidth),
            settingsButton.widthAnchor.constraint(equalToConstant: Const.navigationButtonsWidth)
        ])
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.systemGray6
        tableView.separatorStyle = .none
        tableView.register(MemeViewCell.self, forCellReuseIdentifier: Const.cellReuseId)
    }
}

// MARK: - Table Delegate
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
            loadMemes()
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let memeCell = cell as? MemeViewCell
        let meme = memes[indexPath.row]
        if meme.urlString != nil {
            if meme.postHint == "hosted:video", let redditVideo = meme.secureMedia?.redditVideo {
                let videoUrl = redditVideo.fallbackUrl
                memeCell?.setupWithVideo(url: videoUrl)
            } else if meme.postHint == "image" {
                let url = URL(string: meme.urlString ?? "")
                memeCell?.setupWithImage(url: url!)
            }
        } else {
            memeCell?.setupDefault()
        }
    }
}

// MARK: - Table Data Source
extension MemeTableVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.cellReuseId, for: indexPath) as! MemeViewCell
        let meme = memes[indexPath.row]
        let urlString = meme.urlString
        if let url = URL(string: urlString ?? String()) {
            switch meme.postHint {
            case "image":
                adjustCellUsingImage(cell: cell, indexPath: indexPath, url: url)
                cell.setupWithImage(url: url)
            case "hosted:video":
                guard let redditVideo = meme.secureMedia?.redditVideo else {
                    cell.setupDefault()
                    return cell
                }
                adjustCellUsingVideo(cell: cell, indexPath: indexPath, url: url, using: redditVideo)
                let videoUrl = URL(string: meme.urlString ?? "")
                cell.setupWithVideo(url: videoUrl!)
            default:
                cell.setupDefault()
            }
        } else {
            cell.setupDefault()
        }
        return cell
    }
}

// MARK: - Utils
extension MemeTableVC {
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

    private func adjustCellUsingVideo(cell: MemeViewCell, indexPath: IndexPath, url: URL, using mediaInfo: RedditVideo) {
        let width = CGFloat(mediaInfo.width)
        let height = CGFloat(mediaInfo.height)
        let resolution = (width, height)
        self.adjustCellHeight(cell: cell, indexPath: indexPath, using: resolution)
    }

    private func adjustCellHeight(cell: MemeViewCell, indexPath: IndexPath, using resolution: (width: CGFloat, height: CGFloat)) {
        let aspectRatio = resolution.height / resolution.width
        let adjustedCellHeight = cell.frame.width * aspectRatio
        self.cellHeights[indexPath] = adjustedCellHeight
    }
}

// MARK: - Navigation
extension MemeTableVC {
    @IBAction func selectorModeButtonTapped(_ sender: UIButton) {
        let selectorVC = SourceSelectorVC()
        selectorVC.delegate = self
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

    @IBAction func settingsButtonTapped(_ sender: UIButton) {
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

// MARK: - Popover VC presentation
extension MemeTableVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIDevice.current.userInterfaceIdiom == .pad ? .popover : .none
    }
}
