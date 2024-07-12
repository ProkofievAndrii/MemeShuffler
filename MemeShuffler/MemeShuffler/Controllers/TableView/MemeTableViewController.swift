//
//  ViewController.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 10.07.2024.
//

import UIKit
import MemeApiHandler
import Kingfisher

//MARK: - UITableViewController
class MemeTableViewController: UIViewController {

    //Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var sourceSelectorButton: UIBarButtonItem!
    @IBOutlet private weak var customizeButton: UIBarButtonItem!
    
    //Data
    private var memes: [Meme] = []
    private var defaultCellHeight: CGFloat = 200
    private var cellHeights: [IndexPath: CGFloat] = [:]
    private var isLoading = false
    private var currentPage = 1
    
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
        execureRequest(page: currentPage)
    }
    
    private func configureApiParameters() {
        MemeApiManager.setSubredditName(Subreddits.deadbydaylight.rawValue)
        MemeApiManager.setQuantity(20)
    }
    
    private func execureRequest(page: Int) {
            isLoading = true
            MemeApiManager.loadMemesCompilation { memes in
                if let memes = memes {
                    if page == 1 {
                        self.memes = memes
                    } else {
                        self.memes.append(contentsOf: memes)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    self.isLoading = false
                } else {
                    self.isLoading = false
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
        sourceSelectorButton.title = "r/placegolder"
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
}

//MARK: - Table Delegate
extension MemeTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = cellHeights[indexPath] {
            return height
        }
        return 200
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let height = scrollView.frame.size.height
            
            if offsetY > contentHeight - height - (1 * defaultCellHeight) {
                guard !isLoading else { return }
                currentPage += 1
                loadPhotos()
            }
        }
}

//MARK: - Table Data Source
extension MemeTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memeCell", for: indexPath) as! MemeViewCell
        //Getting corresponding meme
        let meme = memes[indexPath.row]
        
        if let url = URL(string: meme.url) {
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let value):
                    let image = value.image
                    let aspectRatio = image.size.height / image.size.width
                    let adjustedCellHeight = cell.frame.width * aspectRatio
                    self.cellHeights[indexPath] = adjustedCellHeight
                    DispatchQueue.main.async {
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                    }
                case .failure(let error):
                    print("Error loading image: \(error)")
                }
            }
            cell.configureWith(url: meme.url)
        } else {
            cell.configureDefault()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
