//
//  SettingsViewViewController.swift
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
    // API behavior segment
    @IBOutlet private weak var apiBehaviourDataToggleButton: UIButton!
    @IBOutlet private weak var apiBehaviour: UIView!
    // Exit segment
    @IBOutlet private weak var exitToggleButton: UIButton!
    @IBOutlet private weak var exitSubview: UIView!
    @IBOutlet private weak var exitHintLabel: UILabel!
    @IBOutlet private weak var exitButton: UIButton!
    
    var appearanceDelegate: AppearanceSettingsDelegate?
    var settingsDelegate: SettingsDelegate?
    
    // MARK: - Status Variables
    private var shownSubviews: [UIView: Bool] = [:]
    private let interfaceLanguages = Languages.allCases
    private var changesWereMade = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if changesWereMade { settingsDelegate?.applyUpdatedSettings() }
    }
}

// MARK: - UI Configuration
extension SettingsVC {
    private func configureUI() {
        overrideUserInterfaceStyle = SettingsManager.interfaceTheme == 0 ? .light : .dark
        
        setupSubviews()
        updateTitle()
        updateLocalization()
        updateSwitchesState()
    }
    
    private func updateTitle() {
        self.title = NSLocalizedString("settings_title", comment: "")
        let titleColor: UIColor = SettingsManager.interfaceTheme == 0 ? .black : .white
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: titleColor
        ]
    }
    
    private func updateLocalization() {
        // User experience segment
        let userExperienceTitle = NSLocalizedString("user_experience", comment: "")
        userExperienceToggleButton.setTitle(userExperienceTitle, for: .normal)
        userExperienceToggleButton.setTitle(userExperienceTitle, for: .selected)
        showCensoredPostsLabel.text = NSLocalizedString("show_censored_posts", comment: "")
        showSpoilersLabel.text = NSLocalizedString("show_spoilers", comment: "")
        autoplayVideosLabel.text = NSLocalizedString("autoplay_videos", comment: "")
        
        // Appearance segment
        let appAppearanceTitle = NSLocalizedString("app_appearance", comment: "")
        appearanceToggleButton.setTitle(appAppearanceTitle, for: .normal)
        appearanceToggleButton.setTitle(appAppearanceTitle, for: .selected)
        appThemeLabel.text = NSLocalizedString("app_theme", comment: "")
        languageLabel.text = NSLocalizedString("app_language", comment: "")
        viewFullPostInfoLabel.text = NSLocalizedString("view_full_post_info", comment: "")
        
        // API behavior segment
        let apiBehaviourTitle = NSLocalizedString("api_behaviour", comment: "")
        apiBehaviourDataToggleButton.setTitle(apiBehaviourTitle, for: .normal)
        apiBehaviourDataToggleButton.setTitle(apiBehaviourTitle, for: .selected)

        // Exit segment
        let exitSegmentTitle = NSLocalizedString("exit", comment: "")
        exitToggleButton.setTitle(exitSegmentTitle, for: .normal)
        exitToggleButton.setTitle(exitSegmentTitle, for: .selected)
        exitHintLabel.text = NSLocalizedString("exit_hint", comment: "")
        let exitButtonTitle = NSLocalizedString("exit_yes", comment: "")
        exitButton.setTitle(exitButtonTitle, for: .normal)
    }
    
    private func updateSwitchesState() {
        censoreSwitch.isOn = SettingsManager.showCensoredPosts
        spoilerSwitch.isOn = SettingsManager.showSpoilerPosts
        autoplaySwitch.isOn = SettingsManager.allowVideoAutoplay
        themeSegmentControl.selectedSegmentIndex = SettingsManager.interfaceTheme
        languageSegmentControl.selectedSegmentIndex = getLanguageIndex()
        fullPostInfoSwitch.isOn = SettingsManager.showFullPostInfo
    }
    
    private func getLanguageIndex() -> Int {
        for (index, language) in interfaceLanguages.enumerated() {
            if SettingsManager.interfaceLanguage == language.rawValue.lowercased() {
                return index
            }
        }
        return 0
    }
}

// MARK: - Elements Configuration
extension SettingsVC {
    private func setupSubviews() {
        shownSubviews = [
            userExperienceSubview: false,
            appearanceSubview: false,
            apiBehaviour: false,
            exitSubview: false
        ]
        
        for subview in shownSubviews.keys {
            subview.isHidden = true
            subview.alpha = 0
            subview.layer.cornerRadius = 5
        }
    }
    
    private func updateSubviews(except view: UIView) {
        for subview in shownSubviews {
            subview.key.isUserInteractionEnabled = false
            if subview.value && subview.key != view {
                subview.key.toggleView()
                shownSubviews[subview.key]?.toggle()
            }
        }
    }
}

// MARK: - User Experience Actions
extension SettingsVC {
    @IBAction func userExperienceToggleButtonTapped(_ sender: Any) {
        updateSubviews(except: userExperienceSubview)
        userExperienceSubview.toggleView()
        shownSubviews[userExperienceSubview]?.toggle()
    }
    
    @IBAction func censoreSwitchToggled(_ sender: Any) {
        SettingsManager.showCensoredPosts = censoreSwitch.isOn
        if !changesWereMade { changesWereMade.toggle() }
    }
    
    @IBAction func spoilerSwitchToggled(_ sender: Any) {
        SettingsManager.showSpoilerPosts = spoilerSwitch.isOn
        if !changesWereMade { changesWereMade.toggle() }
    }
    
    @IBAction func autoplaySliderToggled(_ sender: Any) {
        SettingsManager.allowVideoAutoplay = autoplaySwitch.isOn
        if !changesWereMade { changesWereMade.toggle() }
    }
}

// MARK: - Appearance Actions
extension SettingsVC {
    @IBAction func appearanceButtonTapped(_ sender: Any) {
        updateSubviews(except: appearanceSubview)
        appearanceSubview.toggleView()
        shownSubviews[appearanceSubview]?.toggle()
    }
    
    @IBAction func themeControlToggled(_ sender: Any) {
        SettingsManager.interfaceTheme = themeSegmentControl.selectedSegmentIndex
        overrideUserInterfaceStyle = themeSegmentControl.selectedSegmentIndex == 0 ? .light : .dark
        appearanceDelegate?.didToggleTheme()
    }
    
    @IBAction func languageControlToggled(_ sender: Any) {
        SettingsManager.interfaceLanguage = interfaceLanguages[languageSegmentControl.selectedSegmentIndex].rawValue.lowercased()
        appearanceDelegate?.didToggleLanguage()
    }
    
    @IBAction func fullPostInfoSliderToggled(_ sender: Any) {
        SettingsManager.showFullPostInfo = fullPostInfoSwitch.isOn
        if !changesWereMade { changesWereMade.toggle() }
    }
}

// MARK: - API Behaviour Actions
extension SettingsVC {
    @IBAction func apiBehaviourButtonTapped(_ sender: Any) {
        updateSubviews(except: apiBehaviour)
        apiBehaviour.toggleView()
        shownSubviews[apiBehaviour]?.toggle()
    }
}

// MARK: - Exit Actions
extension SettingsVC {
    @IBAction func exitToggleButtonTapped(_ sender: Any) {
        updateSubviews(except: exitSubview)
        exitSubview.toggleView()
        shownSubviews[exitSubview] = true
    }
    
    @IBAction func exitButtonTapped(_ sender: Any) {
        exit(0)
    }
}

// UIView custom toggle realization
private extension UIView {
    func toggleView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.isHidden.toggle()
            self.alpha = self.alpha == 1 ? 0 : 1
        })
        isUserInteractionEnabled = alpha == 1
    }
}

public protocol SettingsDelegate: AnyObject {
    func applyUpdatedSettings()
}

public protocol AppearanceSettingsDelegate: AnyObject {
    func didToggleTheme()
    func didToggleLanguage()
}
