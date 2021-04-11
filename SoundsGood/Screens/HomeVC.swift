//
//  HomeVC.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/23/21.
//

import UIKit

class HomeVC: UIViewController {

    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = Colors.whiteColor
        configureTableVC()
        configureSearchController()
    }
    
    private func configureTableVC() {
        view.addSubview(tableView)

        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.reuseID)
        tableView.rowHeight = 60
    }
    
    private func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for a song"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }

}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SongCell.reuseID) as? SongCell else {
            return UITableViewCell()
        }
        return cell
    }
}

extension HomeVC: UISearchResultsUpdating, UISearchBarDelegate {

    func updateSearchResults(for searchController: UISearchController) {
//        guard let filter = searchController.searchBar.text else { return }
//        isSearching = true
//        if filter.isEmpty {
//            updateData(on: self.followers)
//        } else {
//            filteredFollowers = followers.filter { $0.login.lowercased().contains(filter.lowercased()) }
//            updateData(on: filteredFollowers)
//        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        isSearching = false
//        updateData(on: self.followers)
    }
}
