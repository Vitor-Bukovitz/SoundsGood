//
//  HomeVC.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/23/21.
//

import UIKit

class HomeVC: UIViewController {

    private var songs = [Song]()
    private let tableView = UITableView()
    private let playerBar = PlayerBarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = Colors.whiteColor
        configureTableVC()
        configurePlayerBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getLocalSongs()
    }
    
    private func configureTableVC() {
        view.addSubview(tableView)

        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)
        tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.reuseID)
    }
    
    private func configurePlayerBar() {
        view.addSubview(playerBar)
        
        playerBar.controller = self
        playerBar.delegate = self
        NetworkManager.shared.delegate = self
        NSLayoutConstraint.activate([
            playerBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            playerBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerBar.heightAnchor.constraint(equalToConstant: 64),
        ])
    }
        
    private func getLocalSongs() {
        LocalStorageManager.retrieveSongs { result in
            switch result {
            case .success(let songs):
                DispatchQueue.main.async {
                    self.songs = songs
                    self.tableView.reloadData()
                }
            case .failure(let error):
                self.presentAlertOnMainThread(title: "Something went wrong", message: error.rawValue)
            }
        }
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        songs.count
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
        let song = songs[indexPath.row]
        if song.status == .some(.downloaded) {
            SongManager.configurePlayer(songs: songs.filter { $0.status == .some(.downloaded) } )
            SongManager.playSong(index: indexPath.row)
            let destVC = PlayerVC()
            destVC.setSong(song: song)
            destVC.delegate = self
            let navController = UINavigationController(rootViewController: destVC)
            present(navController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let song = songs[indexPath.row]
            songs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            SongManager.deletePlayer()
            LocalStorageManager.updateWithSong(song: song, actionType: .remove) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.presentAlertOnMainThread(title: "Someting went wrong", message: error.rawValue)
                }
            }
        }
    }
}

extension HomeVC: PlayerVCDelegate, NetworkManagerDelegate {
    
    func didDismiss() {
        getLocalSongs()
    }
    
    func didDownloadedSong(for id: String) {
        let filteredSongs = songs.filter { $0.id == id }
        guard var song = filteredSongs.first else { return }
        song.status = SongStatus.downloaded
        LocalStorageManager.updateWithSong(song: song, actionType: .update) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.presentAlertOnMainThread(title: "Something went wrong", message: error.rawValue)
            } else {
                self.getLocalSongs()
            }
        }
    }
}
