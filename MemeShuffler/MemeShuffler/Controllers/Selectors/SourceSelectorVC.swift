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
    
    private let subreddits = Subreddits.allCases
    private let options = Options.allCases
    private let filters = Filters.allCases
    var delegate: SelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}

//MARK: - UI Configuration
extension SourceSelectorVC {
    private func configureUI() {
        configureAppearance()
        configureElements()
    }
    
    private func configureAppearance() {
        view.backgroundColor = UIColor(named: "SelectorBackground")
        modalPresentationStyle = .popover
        preferredContentSize = CGSize(width: 180, height: (subreddits.count * 40) + (options.count * 40) + 90)
    }
   
    //MARK: - Elements setup
    private func configureElements() {
        let mainStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.distribution = .fill
            stackView.spacing = 10
            return stackView
        }()
        
        let segmentFilterLabel: UILabel = {
            let label = UILabel()
            label.text = "Filter by:"
            label.font = UIFont.boldSystemFont(ofSize: 16)
            return label
        }()
        
        let segmentFilterControl: UISegmentedControl = {
            let items = Filters.allCases.map { $0.rawValue }
            let control = UISegmentedControl(items: items)
            control.selectedSegmentIndex = 0
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
       
        let subredditLabel: UILabel = {
            let label = UILabel()
            label.text = "Saved subreddits:"
            label.font = UIFont.boldSystemFont(ofSize: 16)
            return label
        }()
        
        let subredditStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 5
            return stackView
        }()
       
        for subreddit in subreddits {
            let button = UIButton(type: .system)
            button.setTitle(subreddit.rawValue, for: .normal)
            button.contentHorizontalAlignment = .left
            button.addTarget(self, action: #selector(subredditButtonTapped(_:)), for: .touchUpInside)
            subredditStackView.addArrangedSubview(button)
        }
        
        let otherOptionsLabel: UILabel = {
            let label = UILabel()
            label.text = "Other options:"
            label.font = UIFont.boldSystemFont(ofSize: 16)
            return label
        }()
        
        let otherOptionsStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 5
            return stackView
        }()
        
        for option in options {
            let button = UIButton(type: .system)
            button.setTitle(option.rawValue, for: .normal)
            button.contentHorizontalAlignment = .left
            button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
            otherOptionsStackView.addArrangedSubview(button)
        }
        
        //MARK: - Selector composition
        let viewsToAdd = [
            segmentFilterLabel,
            segmentFilterControl,
            separatorLine,
            subredditLabel,
            subredditStackView,
            otherOptionsLabel,
            otherOptionsStackView
        ]
        
        for view in viewsToAdd {
            mainStackView.addArrangedSubview(view)
        }
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        
        //Adding spacing for StackView content
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
}

//MARK: - Actions
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

protocol SelectionDelegate: AnyObject {
    func didSelectSubreddit(_ subreddit: String)
    func didSelectOption(_ option: String)
    func didSelectFilter(_ filter: String)
}
