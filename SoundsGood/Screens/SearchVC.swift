//
//  SearchVC.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/28/21.
//

import UIKit
import MediaPlayer

class SearchVC: UIViewController {
    
    let tableView = UITableView()
    var songs = [Song]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = Colors.whiteColor
        configureSearchController()
        configureTableVC()
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
    
    
    private func updateData(songs: [Song]) {
        SongManager.configurePlayer(songs: songs)
        DispatchQueue.main.async {
            self.songs = songs
            self.tableView.reloadData()
        }
    }

}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SongCell.reuseID) as? SongCell else {
            return UITableViewCell()
        }
        let song = songs[indexPath.row]
        cell.set(song: song)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SongManager.playSong(index: indexPath.row)
        let song = songs[indexPath.row]
        let destVC = PlayerVC()
        destVC.setSong(song: song)
        let navControlelr = UINavigationController(rootViewController: destVC)
        present(navControlelr, animated: true)
    }
}

extension SearchVC: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        isSearching = false
//        updateData(on: self.followers)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let filter = searchBar.text, !filter.isEmpty else { return }
        NetworkManager.shared.searchSong(song: filter) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let songs):
                self.updateData(songs: songs)
            case .failure(let error):
                self.presentAlertOnMainThread(title: "Something went wrong", message: error.rawValue)
            }
        }
    }
}

