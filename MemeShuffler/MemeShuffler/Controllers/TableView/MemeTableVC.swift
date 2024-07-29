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
        static let cellReuseId = "memeCell"
        static let settingsSegueID = "settingsSegue"
        static let memeSegueID = "memeSegue"
        static let defaultCellHeight: CGFloat = 200
    }

    // Variables
    private var memes: [Meme] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private var cellHeights: [IndexPath: CGFloat] = [:]
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsManager.defaultSubreddit = "HentaiBeast"
        SettingsManager.defaultLoadingQuantity = 20
        configureUI()
        loadMemes()
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

    private func updateMemes(with subreddit: String) {
        MemeApiManager.setSubredditName(subreddit)
        MemeApiManager.setInitial(true)
        MemeApiManager.setAfter(nil)
        memes.removeAll()
        cellHeights.removeAll()
        loadMemes()
    }

    private func executeRequest() {
        isLoading = true
        MemeApiManager.loadMemesCompilation { memes in
            if let memes = memes {
                self.memes.append(contentsOf: memes)
            }
            self.isLoading = false
        }
    }
}

extension MemeTableVC: SelectionDelegate {
    func didSelectSubreddit(_ subreddit: String) {
        updateMemes(with: subreddit)
    }

    func didSelectOption(_ option: String) {
        // Handle options selection
    }
}

// MARK: - UI Configuration
extension MemeTableVC {
    private func configureUI() {
        configureNavigationbar()
        configureTableView()
    }

    private func configureNavigationbar() {
        modeSelectButton.titleLabel?.text = "Selector"
        settingsButton.titleLabel?.text = "Customize"
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
        if let memeCell = cell as? MemeViewCell, let meme = memes[indexPath.row] as? Meme {
            if let urlString = meme.urlString, let url = URL(string: urlString) {
                if meme.postHint == "hosted:video", let redditVideo = meme.secureMedia?.redditVideo {
                    let videoUrl = redditVideo.fallbackUrl
                    memeCell.setupWithVideo(url: videoUrl)
                }
            }
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
                // Prepare for lazy loading of video
                cell.prepareForVideo()
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
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
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
