//
//  SettingsViewViewController.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 10.07.2024.
//

import UIKit
import CommonUtils

class SettingsVC: UIViewController {
    
    //MARK: Outlets
    //General
    @IBOutlet private weak var settingsStackView: UIStackView!
    //User experience segment
    @IBOutlet private weak var userExperienceToggleButton: UIButton!
    @IBOutlet private weak var userExperienceSubview: UIView!
    @IBOutlet private weak var censoreSwitch: UISwitch!
    @IBOutlet private weak var spoilerSwitch: UISwitch!
    @IBOutlet private weak var autoplaySwitch: UISwitch!
    //Appearance segment
    @IBOutlet private weak var appearanceToggleButton: UIButton!
    @IBOutlet private weak var appearanceSubview: UIView!
    @IBOutlet private weak var themeSegmentControl: UISegmentedControl!
    @IBOutlet private weak var languageSegmentControl: UISegmentedControl!
    @IBOutlet private weak var fullPostInfoSwitch: UISwitch!
    //Api behaviour segment
    @IBOutlet private weak var apiBehaviourDataToggleButton: UIButton!
    @IBOutlet private weak var apiBehaviour: UIView!
    //Exit segment
    @IBOutlet private weak var exitToggleButton: UIButton!
    @IBOutlet private weak var exitSubview: UIView!
    @IBOutlet private weak var exitButton: UIButton!
    
    //MARK: Status variables
    //UIView with corresponding value, representing it being shown
    public var shownSubviews: Dictionary<UIView, Bool> = [:]
    public let interfaceLanguages = Languages.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        updateSwitchesState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        overrideUserInterfaceStyle = SettingsManager.interfaceTheme == 0 ? .light : .dark
    }
}

//MARK: - UI Configuration
extension SettingsVC {
    private func configureUI() {
        self.title = "Settings"
        setupSubviews()
    }
    
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
            if subview.value == true && subview.key != view {
                subview.key.toggleView()
                shownSubviews[subview.key]?.toggle()
            }
        }
    }
}

//MARK: - Elements configuration
extension SettingsVC {
    private func updateSwitchesState() {
        censoreSwitch.isOn = SettingsManager.showCensoredPosts
        spoilerSwitch.isOn = SettingsManager.showSpoilerPosts
        autoplaySwitch.isOn = SettingsManager.allowVideoAutoplay
        themeSegmentControl.selectedSegmentIndex = SettingsManager.interfaceTheme
        languageSegmentControl.selectedSegmentIndex = SettingsManager.interfaceLanguage
        fullPostInfoSwitch.isOn = SettingsManager.showFullPostInfo
    }
}

//MARK: - User Experience actions
extension SettingsVC {
    //Subviews
    @IBAction func UserExperienceToggleButtonTapped(_ sender: Any) {
        updateSubviews(except: userExperienceSubview)
        userExperienceSubview.toggleView()
        shownSubviews[userExperienceSubview]?.toggle()
    }
    
    @IBAction func censoreSwitchToggled(_ sender: Any) {
        SettingsManager.showCensoredPosts = censoreSwitch.isOn
    }
    
    @IBAction func spoilerSwitchToggled(_ sender: Any) {
        SettingsManager.showSpoilerPosts = spoilerSwitch.isOn
    }
    
    @IBAction func autoplaySliderToggled(_ sender: Any) {
        SettingsManager.allowVideoAutoplay = autoplaySwitch.isOn
    }
}

//MARK: - Appearance actions
extension SettingsVC {
    @IBAction func appearanceButtonTapped(_ sender: Any) {
        updateSubviews(except: appearanceSubview)
        appearanceSubview.toggleView()
        shownSubviews[appearanceSubview]?.toggle()
    }
    
    @IBAction func themeControlToggled(_ sender: Any) {
        SettingsManager.interfaceTheme = themeSegmentControl.selectedSegmentIndex
        overrideUserInterfaceStyle = themeSegmentControl.selectedSegmentIndex == 0 ? .light : .dark
    }
    
    @IBAction func languageControlToggled(_ sender: Any) {
        SettingsManager.interfaceLanguage = languageSegmentControl.selectedSegmentIndex
    }
    
    @IBAction func fullPostInfoSliderToggled(_ sender: Any) {
        SettingsManager.showFullPostInfo = fullPostInfoSwitch.isOn
    }
}

//MARK: - ApiBehaviour actions
extension SettingsVC {
    @IBAction func apiBehaviourButtonTapped(_ sender: Any) {
        updateSubviews(except: apiBehaviour)
        apiBehaviour.toggleView()
        shownSubviews[apiBehaviour]?.toggle()
    }
}

//MARK: - Exit actions
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

//UIView custom toggle realization
private extension UIView {
    func toggleView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.isHidden.toggle()
            self.alpha = self.alpha == CGFloat(1) ? 0 : 1
        })
        isUserInteractionEnabled = alpha == 1 ? true : false
    }
}
