//
//  SettingsViewController.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 10.07.2024.
//

import UIKit
import CommonUtils

class SettingsVC: UIViewController {
    
    // MARK: - Outlets
    // General
    @IBOutlet private weak var settingsStackView: UIStackView!
    // User experience segment
    @IBOutlet private weak var userExperienceToggleButton: UIButton!
    @IBOutlet private weak var userExperienceSubview: UIView!
    @IBOutlet private weak var showCensoredPostsLabel: UILabel!
    @IBOutlet private weak var showSpoilersLabel: UILabel!
    @IBOutlet private weak var autoplayVideosLabel: UILabel!
    @IBOutlet private weak var censoreSwitch: UISwitch!
    @IBOutlet private weak var spoilerSwitch: UISwitch!
    @IBOutlet private weak var autoplaySwitch: UISwitch!
    // Appearance segment
    @IBOutlet private weak var appearanceToggleButton: UIButton!
    @IBOutlet private weak var appearanceSubview: UIView!
    @IBOutlet private weak var appThemeLabel: UILabel!
    @IBOutlet private weak var languageLabel: UILabel!
    @IBOutlet private weak var viewFullPostInfoLabel: UILabel!
    @IBOutlet private weak var themeSegmentControl: UISegmentedControl!
    @IBOutlet private weak var languageSegmentControl: UISegmentedControl!
    @IBOutlet private weak var fullPostInfoSwitch: UISwitch!
    // API segment
    @IBOutlet private weak var apiDataToggleButton: UIButton!
    @IBOutlet private weak var apiSubview: UIView!
    @IBOutlet private weak var subredditsScrollView: UIScrollView!
    @IBOutlet private weak var addSubredditButton: UIButton!
    @IBOutlet private weak var clearSubredditsButton: UIButton!
    //Database segment
    @IBOutlet private weak var databaseToggleButton: UIButton!
    @IBOutlet private weak var databaseSubview: UIView!
    @IBOutlet private weak var limitLabel: UILabel!
    @IBOutlet private weak var limitPopupButton: UIButton!
    
    @IBOutlet private weak var downloadLabel: UILabel!
    @IBOutlet private weak var downloadButton: UIButton!
    @IBOutlet private weak var eraseLabel: UILabel!
    @IBOutlet private weak var eraseButton: UIButton!
    // Exit segment
    @IBOutlet private weak var exitToggleButton: UIButton!
    @IBOutlet private weak var exitSubview: UIView!
    @IBOutlet private weak var exitHintLabel: UILabel!
    @IBOutlet private weak var exitButton: UIButton!
    
    // MARK: - Delegates
    var appearanceDelegate: AppearanceSettingsDelegate?
    var settingsDelegate: SettingsDelegate?
    weak var sourceDelegate: SourceSelectionDelegate?
    
    // MARK: - State
    private var shownSubviews: [UIView: Bool] = [:]
    private let interfaceLanguages = Languages.allCases
    private var changesWereMade = false
    
    private var savedSubreddits: [String] {
        get { UserDefaults.standard.stringArray(forKey: "savedSubreddits") ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: "savedSubreddits") }
    }
    private let limitOptions = [0, 50, 100, 500]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if changesWereMade {
            settingsDelegate?.applyUpdatedSettings()
        }
    }
}

// MARK: - UI Configuration
extension SettingsVC {
    private func configureUI() {
        // theme
        overrideUserInterfaceStyle = SettingsManager.interfaceTheme == 0 ? .light : .dark
        
        // subviews
        setupSubviews()
        updateTitle()
        updateLocalization()
        updateSwitchesState()
        
        // dynamic parts
        configureApiBehaviourUI()
        configureDatabaseUI()
    }
    
    private func updateTitle() {
        title = NSLocalizedString("settings_title", comment: "")
        let color: UIColor = SettingsManager.interfaceTheme == 0 ? .black : .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: color]
    }
    
    private func updateLocalization() {
        // User experience
        let uxTitle = NSLocalizedString("user_experience", comment: "")
        userExperienceToggleButton.setTitle(uxTitle, for: .normal)
        showCensoredPostsLabel.text = NSLocalizedString("show_censored_posts", comment: "")
        showSpoilersLabel.text      = NSLocalizedString("show_spoilers", comment: "")
        autoplayVideosLabel.text    = NSLocalizedString("autoplay_videos", comment: "")
        
        // Appearance
        let appearanceTitle = NSLocalizedString("app_appearance", comment: "")
        appearanceToggleButton.setTitle(appearanceTitle, for: .normal)
        appThemeLabel.text         = NSLocalizedString("app_theme", comment: "")
        languageLabel.text         = NSLocalizedString("app_language", comment: "")
        viewFullPostInfoLabel.text = NSLocalizedString("view_full_post_info", comment: "")
        
        // API
        let apiTitle = NSLocalizedString("api_behaviour", comment: "")
        apiDataToggleButton.setTitle(apiTitle, for: .normal)
        
        // Database
        limitLabel.text      = NSLocalizedString("limit_saved_posts", comment: "")
        downloadLabel.text   = NSLocalizedString("manual_local_download", comment: "")
        eraseLabel.text      = NSLocalizedString("clear_all_saved_data", comment: "")
        downloadButton.setTitle(NSLocalizedString("start", comment: ""), for: .normal)
        eraseButton.setTitle(NSLocalizedString("erase", comment: ""), for: .normal)
        
        // Exit
        let exitTitle = NSLocalizedString("exit", comment: "")
        exitToggleButton.setTitle(exitTitle, for: .normal)
        exitHintLabel.text = NSLocalizedString("exit_hint", comment: "")
        exitButton.setTitle(NSLocalizedString("exit_yes", comment: ""), for: .normal)
    }
    
    private func updateSwitchesState() {
        censoreSwitch.isOn     = SettingsManager.showCensoredPosts
        spoilerSwitch.isOn     = SettingsManager.showSpoilerPosts
        autoplaySwitch.isOn    = SettingsManager.allowVideoAutoplay
        themeSegmentControl.selectedSegmentIndex    = SettingsManager.interfaceTheme
        languageSegmentControl.selectedSegmentIndex = interfaceLanguages.firstIndex {
            SettingsManager.interfaceLanguage == $0.rawValue.lowercased()
        } ?? 0
        fullPostInfoSwitch.isOn = SettingsManager.showFullPostInfo
    }
}

// MARK: - Subviews Setup
extension SettingsVC {
    private func setupSubviews() {
        shownSubviews = [
            userExperienceSubview: false,
            appearanceSubview:     false,
            apiSubview:            false,
            databaseSubview:       false,
            exitSubview:           false
        ]
        shownSubviews.keys.forEach {
            $0.isHidden = true
            $0.alpha    = 0
            $0.layer.cornerRadius = 8
        }
    }
    
    private func updateSubviews(except view: UIView) {
        for (subview, isShown) in shownSubviews {
            subview.isUserInteractionEnabled = false
            if isShown && subview != view {
                subview.toggleViewAnimated()
                shownSubviews[subview]?.toggle()
            }
        }
    }
}

// MARK: - User Experience Actions
extension SettingsVC {
    @IBAction private func userExperienceToggleButtonTapped(_ sender: Any) {
        updateSubviews(except: userExperienceSubview)
        userExperienceSubview.toggleViewAnimated()
        shownSubviews[userExperienceSubview]?.toggle()
    }
    @IBAction private func censoreSwitchToggled(_ sender: Any) {
        SettingsManager.showCensoredPosts = censoreSwitch.isOn
        changesWereMade = true
    }
    @IBAction private func spoilerSwitchToggled(_ sender: Any) {
        SettingsManager.showSpoilerPosts = spoilerSwitch.isOn
        changesWereMade = true
    }
    @IBAction private func autoplaySliderToggled(_ sender: Any) {
        SettingsManager.allowVideoAutoplay = autoplaySwitch.isOn
        changesWereMade = true
    }
}

// MARK: - Appearance Actions
extension SettingsVC {
    @IBAction private func appearanceButtonTapped(_ sender: Any) {
        updateSubviews(except: appearanceSubview)
        appearanceSubview.toggleViewAnimated()
        shownSubviews[appearanceSubview]?.toggle()
    }
    @IBAction private func themeControlToggled(_ sender: Any) {
        SettingsManager.interfaceTheme = themeSegmentControl.selectedSegmentIndex
        overrideUserInterfaceStyle = (themeSegmentControl.selectedSegmentIndex == 0 ? .light : .dark)
        appearanceDelegate?.didToggleTheme()
    }
    @IBAction private func languageControlToggled(_ sender: Any) {
        SettingsManager.interfaceLanguage = interfaceLanguages[languageSegmentControl.selectedSegmentIndex].rawValue.lowercased()
        appearanceDelegate?.didToggleLanguage()
    }
    @IBAction private func fullPostInfoSliderToggled(_ sender: Any) {
        SettingsManager.showFullPostInfo = fullPostInfoSwitch.isOn
        changesWereMade = true
    }
}

// MARK: - API Behaviour Actions
extension SettingsVC {
    @IBAction private func apiBehaviourButtonTapped(_ sender: Any) {
        updateSubviews(except: apiSubview)
        apiSubview.toggleViewAnimated()
        shownSubviews[apiSubview]?.toggle()
    }
    
    func configureApiBehaviourUI() {
        subredditsScrollView.subviews.forEach { $0.removeFromSuperview() }
        let contentStack = UIStackView()
        contentStack.axis      = .vertical
        contentStack.alignment = .fill
        contentStack.spacing   = 8
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        subredditsScrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: subredditsScrollView.contentLayoutGuide.topAnchor, constant: 8),
            contentStack.bottomAnchor.constraint(equalTo: subredditsScrollView.contentLayoutGuide.bottomAnchor, constant: -8),
            contentStack.leadingAnchor.constraint(equalTo: subredditsScrollView.contentLayoutGuide.leadingAnchor, constant: 8),
            contentStack.trailingAnchor.constraint(equalTo: subredditsScrollView.contentLayoutGuide.trailingAnchor, constant: -8),
            contentStack.widthAnchor.constraint(equalTo: subredditsScrollView.frameLayoutGuide.widthAnchor, constant: -16)
        ])
        
        for name in savedSubreddits {
            let card = UIView()
            card.backgroundColor = .secondarySystemBackground
            card.layer.cornerRadius = 8
            card.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = "r/\(name)"
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = .label
            label.translatesAutoresizingMaskIntoConstraints = false
            
            card.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
                label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
                label.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
                label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8),
                card.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
            ])
            
            contentStack.addArrangedSubview(card)
        }
        
        if savedSubreddits.isEmpty {
            let placeholder = UILabel()
            placeholder.text = NSLocalizedString("no_saved_subreddits", comment: "")
            placeholder.font = .italicSystemFont(ofSize: 14)
            placeholder.textColor = .tertiaryLabel
            placeholder.textAlignment = .center
            contentStack.addArrangedSubview(placeholder)
        }
    }
    
    @IBAction private func addSubredditButtonTapped(_ sender: Any) {
        let ac = UIAlertController(
            title: NSLocalizedString("add_subreddit", comment: ""),
            message: nil,
            preferredStyle: .alert
        )
        ac.addTextField { $0.placeholder = "r/..." }
        ac.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
        ac.addAction(UIAlertAction(title: NSLocalizedString("add", comment: ""), style: .default) { _ in
            guard let txt = ac.textFields?.first?.text?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                  !txt.isEmpty else { return }
            
            if self.savedSubreddits.contains(txt) {
                let err = UIAlertController(
                    title: NSLocalizedString("error", comment: ""),
                    message: NSLocalizedString("subreddit_exists", comment: ""),
                    preferredStyle: .alert
                )
                err.addAction(.init(title: NSLocalizedString("ok", comment: ""), style: .default))
                self.present(err, animated: true)
                return
            }
            let url = URL(string: "https://www.reddit.com/r/\(txt)/about.json")!
            URLSession.shared.dataTask(with: url) { _, resp, _ in
                if let http = resp as? HTTPURLResponse, http.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.savedSubreddits.append(txt)
                        self.configureApiBehaviourUI()
                    }
                } else {
                    DispatchQueue.main.async {
                        let err = UIAlertController(
                            title: NSLocalizedString("error", comment: ""),
                            message: NSLocalizedString("subreddit_not_found", comment: ""),
                            preferredStyle: .alert
                        )
                        err.addAction(.init(title: NSLocalizedString("ok", comment: ""), style: .default))
                        self.present(err, animated: true)
                    }
                }
            }.resume()
        })
        present(ac, animated: true)
    }
    
    @IBAction private func clearSubredditsButtonTapped(_ sender: Any) {
        savedSubreddits.removeAll()
        configureApiBehaviourUI()
    }
}

// MARK: - Database Behaviour Actions
extension SettingsVC {
    @IBAction func databaseToggleButtonTapped(_ sender: Any) {
        updateSubviews(except: databaseSubview)
        databaseSubview.toggleViewAnimated()
        shownSubviews[databaseSubview]?.toggle()
    }
    
    func configureDatabaseUI() {
        limitPopupButton.setTitle("\(SettingsManager.localSaveLimit )", for: .normal)
    }
    
    @IBAction private func limitPopupButtonTapped(_ sender: UIButton) {
        let ac = UIAlertController(
            title: NSLocalizedString("limit_number_of_posts_saved_locally", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        for v in limitOptions {
            ac.addAction(.init(
                title: "\(v)",
                style: .default
            ) { _ in
                SettingsManager.localSaveLimit = v
                sender.setTitle("\(v)", for: .normal)
            })
        }
        ac.addAction(.init(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
        if let pop = ac.popoverPresentationController {
            pop.sourceView = sender
            pop.sourceRect = sender.bounds
        }
        present(ac, animated: true)
    }

    @IBAction private func downloadButtonTapped(_ sender: Any) {
        let limit = SettingsManager.localSaveLimit
        CoreDataManager.shared.deleteAllPosts()
        CoreDataManager.shared.preloadPosts(count: limit) { success in
            DispatchQueue.main.async {
                let msg = success
                    ? String(format: NSLocalizedString("downloaded_%d_posts", comment: ""), limit)
                    : NSLocalizedString("download_failed", comment: "")
                let alert = UIAlertController(
                    title: NSLocalizedString("offline_download", comment: ""),
                    message: msg,
                    preferredStyle: .alert
                )
                alert.addAction(.init(title: NSLocalizedString("ok", comment: ""),
                                      style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction private func eraseButtonTapped(_ sender: Any) {
        CoreDataManager.shared.deleteAllPosts()
        SettingsManager.localSaveLimit = 0
    }
}

// MARK: - Exit Actions
extension SettingsVC {
    @IBAction private func exitToggleButtonTapped(_ sender: Any) {
        updateSubviews(except: exitSubview)
        exitSubview.toggleViewAnimated()
        shownSubviews[exitSubview]?.toggle()
    }
    @IBAction private func exitButtonTapped(_ sender: Any) {
        exit(0)
    }
}

// UIView custom toggle & animation
private extension UIView {
    func toggleViewAnimated(duration: TimeInterval = 0.3) {
        if isHidden {
            alpha = 0
            transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            isHidden = false
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 1,
                options: .curveEaseInOut
            ) {
                self.transform = .identity
                self.alpha = 1
            } completion: { _ in
                self.isUserInteractionEnabled = true
            }
        } else {
            layer.removeAllAnimations()
            isHidden = true
            alpha = 0
            transform = .identity
            isUserInteractionEnabled = false
        }
    }
}

// MARK: - Protocols
public protocol SettingsDelegate: AnyObject {
    func applyUpdatedSettings()
}
public protocol AppearanceSettingsDelegate: AnyObject {
    func didToggleTheme()
    func didToggleLanguage()
}
