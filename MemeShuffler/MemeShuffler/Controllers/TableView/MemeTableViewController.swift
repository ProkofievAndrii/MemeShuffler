//
//  ViewController.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 10.07.2024.
//

import UIKit
import MemeApiHandler

//MARK: - UITableViewController
class MemeTableViewController: UIViewController {

    //Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var sourceSelectorButton: UIBarButtonItem!
    @IBOutlet private weak var customizeButton: UIBarButtonItem!
    
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPhotos()
        configureUI()
    }
}

//MARK: - API Manager Request
extension MemeTableViewController {
    //Request endpoint
    private func loadPhotos() {
        configureApiParameters()
        execureRequest()
    }
    
    private func configureApiParameters() {
        MemeApiManager.setSubredditName(Subreddits.deadbydaylight.rawValue)
        MemeApiManager.setQuantity(20)
    }
    
    private func execureRequest() {
        MemeApiManager.loadMemesCompilation { memes in
            if let memes = memes {
                print("Successfully loaded memes: \(memes)")
            } else {
                print("Failed to load memes")
            }
        }
    }
}

//MARK: - UI Configuration
extension MemeTableViewController {
    private func configureUI() {
        configureNavigationbar()
        configureTableView()
    }
    
    private func configureNavigationbar() {
        sourceSelectorButton.title = "From: template"
        customizeButton.title = "Customize"
    }
    
    private func configureTableView() {
        //Table behavior
        tableView.dataSource = self
        tableView.delegate = self
        //Customizing table style
        tableView.backgroundColor = UIColor.systemGray6
        tableView.separatorStyle = .none
        //Registering custom Cell
        tableView.register(MemeViewCell.self, forCellReuseIdentifier: "memeCell")
    }
    
    //Image setup
    func configureMemeCell(_ cell: MemeViewCell, with content: String) -> MemeViewCell {
        return cell.configureDefault()
    }
}

//MARK: - Table Delegate
extension MemeTableViewController: UITableViewDelegate {
    
}

//MARK: - Table Data Source
extension MemeTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MemeApiManager.getQuantity()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "memeCell", for: indexPath) as! MemeViewCell
        cell = configureMemeCell(cell, with: "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
