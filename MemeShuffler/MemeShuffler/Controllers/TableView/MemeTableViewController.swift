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
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPhotos()
        configureUI()
    }
}

//MARK: - API Manager Request
extension MemeTableViewController {
    private func loadPhotos() {
        MemeApiManager.loadMemesCompilation()
    }
}

//MARK: - UI Configuration
extension MemeTableViewController {
    private func configureUI() {
        configureNavigationbar()
        configureTableView()
    }
    
    private func configureNavigationbar() {
        
    }
    
    @objc private func showMenu() {
        let selectorMenuView = SelectorMenuView()
            
        self.view.addSubview(selectorMenuView)
    }
    
    private func configureTableView() {
        //Table behavior
        tableView.dataSource = self
        tableView.delegate = self
        //Registering custom Cell
        tableView.register(MemeTableViewCell.self, forCellReuseIdentifier: "Cell")
        //Customizing table style
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.systemGray6
    }
}

//MARK: - Table Delegate
extension MemeTableViewController: UITableViewDelegate {
    
}

//MARK: - Table Data Source
extension MemeTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MemeTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
