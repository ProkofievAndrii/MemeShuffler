//
//  MemeTableVC.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 9.07.2024.
//

import UIKit
import AVKit
import CoreData
import MemeApiHandler
import CommonUtils
import Kingfisher

class MemeTableVC: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var modeSelectButton: UIButton!
    @IBOutlet private weak var settingsButton: UIButton!

    struct Const {
        static let cellReuseId            = "memeCell"
        static let settingsSegueID        = "settingsSegue"
        static let memeSegueID            = "memeSegue"
        static let defaultCellHeight: CGFloat = 200
        static let navigationButtonsWidth: CGFloat = 80
    }

    private let imageDownloader = ImageDownloader.default

    private var memes: [Meme] = []
    private var cellHeights: [IndexPath: CGFloat] = [:]

    private var isLoading           = false
    private var isShowingFavorites  = false
    private var isShowingDownloaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsManager.defaultLoadingQuantity = 40
        configureUI()
        configureGestures()
        loadMemes()
    }
}

// MARK: - UI Configuration
extension MemeTableVC {
    private func configureUI() {
        applyCurrentTheme()
        configureNavigationbar()
        configureTableView()
    }

    private func applyCurrentTheme() {
        overrideUserInterfaceStyle = SettingsManager.interfaceTheme == 0 ? .light : .dark
    }

    private func configureNavigationbar() {
        let subs = UserDefaults.standard.stringArray(forKey: "savedSubreddits") ?? []
        title = !subs.isEmpty ? "r/\(SettingsManager.defaultSubreddit)" : "No source"
        let titleColor: UIColor = SettingsManager.interfaceTheme == 0 ? .black : .white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: titleColor
        ]
        modeSelectButton.setImage(UIImage(systemName: "list.bullet.clipboard.fill"), for: .normal)
        settingsButton.setImage(UIImage(systemName: "gearshape.2.fill"), for: .normal)
        NSLayoutConstraint.activate([
            modeSelectButton.widthAnchor.constraint(equalToConstant: Const.navigationButtonsWidth),
            settingsButton.widthAnchor.constraint(equalToConstant: Const.navigationButtonsWidth)
        ])
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.backgroundColor = .systemGray6
        tableView.separatorStyle  = .none
        tableView.register(MemeViewCell.self, forCellReuseIdentifier: Const.cellReuseId)
    }
}

// MARK: - Gestures configuration
extension MemeTableVC {
    private func configureGestures() {
        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        longPress.minimumPressDuration = 0.5
        tableView.addGestureRecognizer(longPress)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point),
              indexPath.row < memes.count
        else { return }

        let meme = memes[indexPath.row]
        let fav  = CoreDataManager.shared.isFavorite(id: meme.id)

        if fav {
            CoreDataManager.shared.unfavorite(id: meme.id)
            provideFeedback(on: indexPath, added: false)
        } else {
            guard let urlStr = meme.urlString, let downloadURL = URL(string: urlStr) else { return }
            let fallbackWidth = Double(tableView.frame.width)

            URLSession.shared.dataTask(with: downloadURL) { data, _, _ in
                guard let data = data else { return }
                let type   = meme.postHint == "hosted:video"
                             ? "video"
                             : (downloadURL.pathExtension.lowercased() == "gif" ? "gif" : "image")
                let width  = meme.width  > 0 ? meme.width  : fallbackWidth
                let height = meme.height > 0 ? meme.height : Double(Const.defaultCellHeight)

                CoreDataManager.shared.favorite(
                    meme:      meme,
                    mediaData: data,
                    mediaType: type,
                    width:     width,
                    height:    height
                )
                DispatchQueue.main.async {
                    self.provideFeedback(on: indexPath, added: true)
                }
            }.resume()
        }
    }

    private func provideFeedback(on indexPath: IndexPath, added: Bool) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let color    = added ? UIColor.systemGreen : UIColor.systemRed
        let original = cell.contentView.backgroundColor
        cell.contentView.backgroundColor = color.withAlphaComponent(0.3)
        UIView.animate(withDuration: 0.6) {
            cell.contentView.backgroundColor = original
        }
    }
}

// MARK: - API Manager Request
extension MemeTableVC {
    private func loadMemes() {
        isShowingFavorites   = false
        isShowingDownloaded  = false
        configureApiParameters()
        let subs = UserDefaults.standard.stringArray(forKey: "savedSubreddits") ?? []
        guard !subs.isEmpty else { return }
        executeRequest()
    }

    private func configureApiParameters() {
        MemeApiManager.setQuantity(MemeApiManager.getQuantity())
        MemeApiManager.setSubredditName(MemeApiManager.getSubredditName())
    }

    private func executeRequest() {
        isLoading = true
        MemeApiManager.loadMemesCompilation { [weak self] newMemes in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let arr = newMemes {
                    self.memes.append(contentsOf: arr)
                    self.tableView.reloadData()
                }
                self.isLoading = false
            }
        }
    }

    private func updatedMemeRequest() {
        imageDownloader.cancelAll()
        MemeApiManager.setInitial(true)
        MemeApiManager.setAfter(nil)
        memes.removeAll()
        cellHeights.removeAll()
        tableView.reloadData()
        loadMemes()
    }
}

// MARK: - Source Selection Delegate
extension MemeTableVC: SourceSelectionDelegate {
    func didSelectSubreddit(_ subreddit: String) {
        imageDownloader.cancelAll()
        isShowingFavorites   = false
        isShowingDownloaded  = false
        
        let defaults = UserDefaults.standard
        var subs = defaults.stringArray(forKey: "savedSubreddits") ?? []
        if !subs.contains(subreddit) {
            subs.insert(subreddit, at: 0)
            defaults.set(subs, forKey: "savedSubreddits")
        }
        
        MemeApiManager.setSubredditName(subreddit)
        title = "r/\(subreddit)"
        updatedMemeRequest()
    }

    func didSelectOption(_ option: String) {
        imageDownloader.cancelAll()
        switch option {
        case Options.favoritePosts.rawValue:
            isShowingFavorites   = true
            isShowingDownloaded  = false
            title                = option
            let favPosts         = CoreDataManager.shared.fetchFavoritePosts()
            memes = favPosts.map { post in
                Meme(
                    id:        post.id ?? "",
                    title:     post.title,
                    urlString: post.urlString,
                    width:     post.width,
                    height:    post.height
                )
            }
            cellHeights.removeAll()
            tableView.reloadData()

        case Options.savedLocally.rawValue:
            isShowingFavorites   = false
            isShowingDownloaded  = true
            title                = option
            let dlPosts = CoreDataManager.shared.fetchDownloadedPosts()
            memes = dlPosts.map { post in
                Meme(
                    id:        post.id ?? "",
                    title:     post.title,
                    urlString: post.urlString,
                    width:     post.width,
                    height:    post.height
                )
            }
            cellHeights.removeAll()
            tableView.reloadData()

        default:
            updatedMemeRequest()
        }
    }

    func didSelectFilter(_ filter: String) {
        imageDownloader.cancelAll()
        isShowingFavorites  = false
        isShowingDownloaded = false
        MemeApiManager.setFilter(filter)
        updatedMemeRequest()
    }
}

// MARK: - Settings & Appearance Delegates
extension MemeTableVC: SettingsDelegate {
    func applyUpdatedSettings() {
        tableView.reloadData()
    }
}

extension MemeTableVC: AppearanceSettingsDelegate {
    func didToggleTheme() { applyCurrentTheme() }
    func didToggleLanguage() { }
}

// MARK: - Navigation (Selector & Settings)
extension MemeTableVC {
    @IBAction func selectorModeButtonTapped(_ sender: UIButton) {
        let selectorVC = SourceSelectorVC()
        selectorVC.delegate = self
        selectorVC.appearanceDelegate = self
        let nav = UINavigationController(rootViewController: selectorVC)
        nav.modalPresentationStyle = .popover
        if let pop = nav.popoverPresentationController {
            pop.delegate = self
            pop.sourceView = sender
            pop.sourceRect = CGRect(x: sender.bounds.midX,
                                     y: sender.bounds.maxY,
                                     width: 0, height: 0)
            pop.permittedArrowDirections = .up
        }
        present(nav, animated: true)
    }

    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: Const.settingsSegueID, sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Const.settingsSegueID,
           let settingsVC = segue.destination as? SettingsVC {
            settingsVC.appearanceDelegate = self
            settingsVC.settingsDelegate   = self
        }
    }
}

// MARK: - Table Delegate & DataSource
extension MemeTableVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if isShowingFavorites || isShowingDownloaded {
            let meme = memes[indexPath.row]
            guard meme.width > 0 else { return Const.defaultCellHeight }
            let ratio = CGFloat(meme.height / meme.width)
            return tableView.frame.width * ratio
        }
        return cellHeights[indexPath] ?? Const.defaultCellHeight
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isLoading, !isShowingFavorites, !isShowingDownloaded else { return }
        let offsetY       = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let viewHeight    = scrollView.frame.size.height
        if offsetY > contentHeight - viewHeight - Const.defaultCellHeight {
            loadMemes()
        }
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
                   -> UISwipeActionsConfiguration?
    {
        let share = UIContextualAction(
            style: .normal,
            title: NSLocalizedString("share", comment: "")
        ) { [weak self] _, view, completion in
            guard let self = self else { return }
            let meme = self.memes[indexPath.row]
            if let urlStr = meme.urlString, let url = URL(string: urlStr) {
                let vc = UIActivityViewController(
                    activityItems: [url],
                    applicationActivities: nil
                )
                vc.popoverPresentationController?.sourceView = view
                self.present(vc, animated: true)
                completion(true)
            } else {
                completion(false)
            }
        }
        return UISwipeActionsConfiguration(actions: [share])
    }
}

extension MemeTableVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Const.cellReuseId,
            for: indexPath
        ) as! MemeViewCell
        let meme = memes[indexPath.row]

        // Offline (Favorites/Downloaded)
        if isShowingFavorites || isShowingDownloaded {
            if let post = CoreDataManager.shared.fetchPost(withId: meme.id),
               let data = post.mediaData,
               let type = post.mediaType
            {
                cell.setupWithLocalMedia(data, type: type)
                adjustCellHeight(
                    cell:      cell,
                    indexPath: indexPath,
                    using:     (CGFloat(post.width), CGFloat(post.height))
                )
            } else {
                cell.setupDefault()
            }
            return cell
        }

        // Online
        if let urlStr = meme.urlString, let url = URL(string: urlStr) {
            switch meme.postHint {
            case "image":
                KingfisherManager.shared.retrieveImage(with: url) { [weak self] res in
                    guard let self = self, case .success(let v) = res else { return }
                    let dims = (v.image.size.width, v.image.size.height)
                    self.adjustCellHeight(
                        cell:      cell,
                        indexPath: indexPath,
                        using:     dims
                    )
                }
                cell.setupWithImage(url: url)

            case "hosted:video":
                if let media = meme.secureMedia?.redditVideo {
                    let dims = (CGFloat(media.width), CGFloat(media.height))
                    adjustCellHeight(cell: cell,
                                     indexPath: indexPath,
                                     using: dims)
                    cell.setupWithVideo(url: media.fallbackUrl)
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
}

// MARK: - Utils
extension MemeTableVC {
    private func adjustCellHeight(
        cell: MemeViewCell?,
        indexPath: IndexPath,
        using resolution: (width: CGFloat, height: CGFloat)
    ) {
        let ratio     = resolution.height / resolution.width
        let newHeight = tableView.frame.width * ratio
        memes[indexPath.row].width  = Double(resolution.width)
        memes[indexPath.row].height = Double(resolution.height)
        cellHeights[indexPath]      = newHeight

        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
}

// MARK: - Popover Presentation Delegate
extension MemeTableVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return UIDevice.current.userInterfaceIdiom == .pad ? .popover : .none
    }
}
