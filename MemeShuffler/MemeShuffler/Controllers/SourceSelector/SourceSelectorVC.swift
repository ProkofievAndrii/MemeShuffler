//
//  SourceSelectorViewController.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 10.07.2024.
//

import UIKit
import MemeApiHandler

class SourceSelectorVC: UIViewController {

    let subreddits = Subreddits.allCases
    let options: [String] = ["Random set", "Saved locally"]
    var delegate: SelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        modalPresentationStyle = .popover
        preferredContentSize = CGSize(width: 180, height: (subreddits.count * 40) + (options.count * 40) + 50)
        
        // Настройка основного StackView
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
        mainStackView.spacing = 10
        
        // Добавление заголовка для сабреддитов
        let subredditLabel = UILabel()
        subredditLabel.text = "Saved subreddits:"
        subredditLabel.font = UIFont.boldSystemFont(ofSize: 16)
        mainStackView.addArrangedSubview(subredditLabel)
        
        // Создание StackView для сабреддитов
        let subredditStackView = UIStackView()
        subredditStackView.axis = .vertical
        subredditStackView.alignment = .fill
        subredditStackView.distribution = .fillEqually
        subredditStackView.spacing = 5
        
        for subreddit in subreddits {
            let button = UIButton(type: .system)
            button.setTitle(subreddit.rawValue, for: .normal)
            button.contentHorizontalAlignment = .left
            button.addTarget(self, action: #selector(subredditButtonTapped(_:)), for: .touchUpInside)
            subredditStackView.addArrangedSubview(button)
        }
        
        mainStackView.addArrangedSubview(subredditStackView)
        
        // Добавление заголовка для других опций
        let otherOptionsLabel = UILabel()
        otherOptionsLabel.text = "Other options:"
        otherOptionsLabel.font = UIFont.boldSystemFont(ofSize: 16)
        mainStackView.addArrangedSubview(otherOptionsLabel)
        
        // Создание StackView для других опций
        let otherOptionsStackView = UIStackView()
        otherOptionsStackView.axis = .vertical
        otherOptionsStackView.alignment = .fill
        otherOptionsStackView.distribution = .fillEqually
        otherOptionsStackView.spacing = 5
        
        for option in options {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.contentHorizontalAlignment = .left
            button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
            otherOptionsStackView.addArrangedSubview(button)
        }
        
        mainStackView.addArrangedSubview(otherOptionsStackView)
        
        // Настройка Auto Layout для основного StackView
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func subredditButtonTapped(_ sender: UIButton) {
        guard let subreddit = sender.titleLabel?.text else { return }
        delegate?.didSelectSubreddit(subreddit)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func optionButtonTapped(_ sender: UIButton) {
        guard let option = sender.titleLabel?.text else { return }
        delegate?.didSelectOption(option)
        dismiss(animated: true, completion: nil)
    }
}

protocol SelectionDelegate: AnyObject {
    func didSelectSubreddit(_ subreddit: String)
    func didSelectOption(_ option: String)
}
