//
//  SourceSelectorViewController.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 10.07.2024.
//

import UIKit
import MemeApiHandler
import CommonUtils

class SourceSelectorVC: UIViewController {

    // Outlets
    private var filtersLabel: UILabel!
    private var subredditLabel: UILabel!
    private var optionsLabel: UILabel!
    
    // Variables
    private let subreddits = Subreddits.allCases
    private let options = Options.allCases
    private let filters = Filters.allCases
   
    struct UIParameters {
        static let selectorInset: CGFloat = 16
        static let scrollItemSpacing: CGFloat = 10
        static let scrollItemHeight: CGFloat = 30
        static let maxVisibleScrollItems = 5
        static let selectorWidth: CGFloat = 150 + (2 * selectorInset)
        static var selectorHeight: CGFloat = 0
        static var subredditScrollViewHeight: CGFloat = 0
        static var optionScrollViewHeight: CGFloat = 0
    }
    
    var delegate: SourceSelectionDelegate?
    weak var appearanceDelegate: AppearanceSettingsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        applyCurrentTheme()
    }
    
    private func configureUI() {
        calculateUIParameters()
        configureAppearance()
        configureElements()
    }
    
    private func applyCurrentTheme() {
        overrideUserInterfaceStyle = SettingsManager.interfaceTheme == 0 ? .light : .dark
    }
}

// MARK: - UI Configuration
extension SourceSelectorVC {
    private func calculateUIParameters() {
        calculateScrollViewSizes()
        calculateSelectorHeight()
    }
    
    private func calculateScrollViewSizes() {
        // Subreddits
        UIParameters.subredditScrollViewHeight = CGFloat(min(subreddits.count, UIParameters.maxVisibleScrollItems)) * (UIParameters.scrollItemHeight + UIParameters.scrollItemSpacing)
        // Options
        UIParameters.optionScrollViewHeight = CGFloat(min(options.count, UIParameters.maxVisibleScrollItems)) * (UIParameters.scrollItemHeight + UIParameters.scrollItemSpacing)
    } 
    
    private func calculateSelectorHeight() {
        UIParameters.selectorHeight = UIParameters.subredditScrollViewHeight + UIParameters.optionScrollViewHeight + 150
    }
    
    private func configureAppearance() {
        view.backgroundColor = UIColor.selectorBackground
        modalPresentationStyle = .popover
        preferredContentSize = CGSize(width: UIParameters.selectorWidth, height: UIParameters.selectorHeight)
    }
   
    // MARK: - Elements setup
    private func configureElements() {
        let mainStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.distribution = .fill
            stackView.spacing = 10
            return stackView
        }()
        
        filtersLabel = {
            let label = UILabel()
            label.text = NSLocalizedString("filter_by", comment: "")
            label.font = UIFont.boldSystemFont(ofSize: 16)
            return label
        }()
        
        let segmentFilterControl: UISegmentedControl = {
            let items = Filters.allCases.map { $0.rawValue }
            let control = UISegmentedControl(items: items)
            for (index, filter) in filters.enumerated() {
                if filter.rawValue == MemeApiManager.getFilter() {
                    control.selectedSegmentIndex = index
                }
            }
            control.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
            return control
        }()
        
        let separatorLine: UIView = {
            let separator = UIView()
            separator.backgroundColor = .lightGray
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
            return separator
        }()
       
        // Subreddits
        subredditLabel = {
            let label = UILabel()
            label.text = NSLocalizedString("saved_subreddits", comment: "")
            label.font = UIFont.boldSystemFont(ofSize: 16)
            return label
        }()
        
        let subredditScrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            return scrollView
        }()
        
        let subredditStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = UIParameters.scrollItemSpacing
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.backgroundColor = UIColor.scrollViewBackground
            stackView.layer.cornerRadius = 5
            return stackView
        }()
       
        for subreddit in subreddits {
            let button = UIButton(type: .system)
            button.setTitle(subreddit.rawValue, for: .normal)
            button.contentHorizontalAlignment = .left
            button.addTarget(self, action: #selector(subredditButtonTapped(_:)), for: .touchUpInside)
            subredditStackView.addArrangedSubview(button)
        }
        
        subredditScrollView.addSubview(subredditStackView)
        
        // Options
        optionsLabel = {
            let label = UILabel()
            label.text = NSLocalizedString("other_options", comment: "")
            label.font = UIFont.boldSystemFont(ofSize: 16)
            return label
        }()
    
        let optionsScrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            return scrollView
        }()
        
        let optionsStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = UIParameters.scrollItemSpacing
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.backgroundColor = UIColor.scrollViewBackground
            stackView.layer.cornerRadius = 5
            return stackView
        }()
        
        for option in options {
            let button = UIButton(type: .system)
            button.setTitle(option.rawValue, for: .normal)
            button.contentHorizontalAlignment = .left
            button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
            optionsStackView.addArrangedSubview(button)
        }
        
        optionsScrollView.addSubview(optionsStackView)
        
        // MARK: - Selector composition
        let viewsToAdd = [
            filtersLabel,
            segmentFilterControl,
            separatorLine,
            subredditLabel,
            subredditScrollView,
            optionsLabel,
            optionsScrollView
        ]
        
        for view in viewsToAdd {
            mainStackView.addArrangedSubview(view ?? UIView())
        }
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIParameters.selectorInset),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIParameters.selectorInset),
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: UIParameters.selectorInset * 1.5),
            mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -UIParameters.selectorInset),
            
            optionsScrollView.heightAnchor.constraint(lessThanOrEqualToConstant: UIParameters.optionScrollViewHeight),
            optionsScrollView.widthAnchor.constraint(equalToConstant: UIParameters.selectorWidth - (UIParameters.selectorInset * 2)),
            subredditScrollView.heightAnchor.constraint(lessThanOrEqualToConstant: UIParameters.subredditScrollViewHeight),
            subredditScrollView.widthAnchor.constraint(equalToConstant: UIParameters.selectorWidth - (UIParameters.selectorInset * 2)),
            
            subredditStackView.leadingAnchor.constraint(equalTo: subredditScrollView.leadingAnchor),
            subredditStackView.trailingAnchor.constraint(equalTo: subredditScrollView.trailingAnchor),
            subredditStackView.topAnchor.constraint(equalTo: subredditScrollView.topAnchor),
            subredditStackView.bottomAnchor.constraint(equalTo: subredditScrollView.bottomAnchor),
            subredditStackView.widthAnchor.constraint(equalTo: subredditScrollView.widthAnchor),
            
            optionsStackView.leadingAnchor.constraint(equalTo: optionsScrollView.leadingAnchor),
            optionsStackView.trailingAnchor.constraint(equalTo: optionsScrollView.trailingAnchor),
            optionsStackView.topAnchor.constraint(equalTo: optionsScrollView.topAnchor),
            optionsStackView.bottomAnchor.constraint(equalTo: optionsScrollView.bottomAnchor),
            optionsStackView.widthAnchor.constraint(equalTo: optionsScrollView.widthAnchor)
        ])
    }
}

// MARK: - Actions
extension SourceSelectorVC {
    @objc private func subredditButtonTapped(_ sender: UIButton) {
        guard let subredditName = sender.titleLabel?.text else { return }
        delegate?.didSelectSubreddit(subredditName)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func optionButtonTapped(_ sender: UIButton) {
        guard let optionName = sender.titleLabel?.text else { return }
        delegate?.didSelectOption(optionName)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let filterIndex = sender.selectedSegmentIndex
        let filter = Filters.allCases[filterIndex]
        delegate?.didSelectFilter(filter.rawValue)
    }
}

// MARK: - SettingsSelectionDelegate
extension SourceSelectorVC: AppearanceSettingsDelegate {
    func didToggleTheme() {
        applyCurrentTheme()
    }

    func didToggleLanguage() {
        filtersLabel.text = NSLocalizedString("filter_by", comment: "")
        subredditLabel.text = NSLocalizedString("saved_subreddits", comment: "")
        optionsLabel.text = NSLocalizedString("other_options", comment: "")
    }
}

protocol SourceSelectionDelegate: AnyObject {
    func didSelectSubreddit(_ subreddit: String)
    func didSelectOption(_ option: String)
    func didSelectFilter(_ filter: String)
}
