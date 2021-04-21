//
//  SearchVC.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/28/21.
//

import UIKit
import WebKit

class SearchVC: UIViewController {
    
    private let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    private let downloadButton = UIButton(type: .system)
    private let loadingView = UIActivityIndicatorView()
    private var currentDownloadURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureWebview()
        configureLoadingView()
    }
    
    private func configureView() {
        view.backgroundColor = Colors.whiteColor
        navigationItem.title = Constants.youtubeURL
        
        downloadButton.isEnabled = false
        downloadButton.setImage(UIImage(), for: .normal)
        downloadButton.addTarget(self, action: #selector(downloadButtonPressed), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: downloadButton)
    }
    
    private func configureLoadingView() {
        downloadButton.addSubview(loadingView)
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.color = Colors.darkPurpleColor
        loadingView.hidesWhenStopped = true
        NSLayoutConstraint.activate([
            loadingView.widthAnchor.constraint(equalTo: downloadButton.widthAnchor),
            loadingView.heightAnchor.constraint(equalTo: downloadButton.heightAnchor),
            loadingView.centerYAnchor.constraint(equalTo: downloadButton.centerYAnchor),
            loadingView.centerXAnchor.constraint(equalTo: downloadButton.centerXAnchor),
        ])
    }
    
    
    private func configureWebview() {
        view.addSubview(webView)
        if let url = URL(string: Constants.youtubeURL) {
            webView.load(URLRequest(url: url))
        }
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.addObserver(self, forKeyPath: "URL", options: [.new, .old], context: nil)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    @objc private func downloadButtonPressed() {
        guard let downloadURL = currentDownloadURL else { return }
        guard let youtubeURL = webView.url?.absoluteString else { return }
        NetworkManager.shared.downloadSong(for: youtubeURL, with: downloadURL) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.presentAlertOnMainThread(title: "Something went wrong", message: error.rawValue)
            } else {
                DispatchQueue.main.async {
                    self.downloadButton.isEnabled = false
                    self.downloadButton.setImage(UIImage(), for: .normal)
                    let ac = UIAlertController(title: "Your song is being downloaded!", message: "Hang tight while your song is being downloaded! Soon it will be avaiable to play!", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
    }
}

extension SearchVC: WKUIDelegate, WKNavigationDelegate {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
        change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        loadingView.startAnimating()
        downloadButton.isEnabled = false
        downloadButton.setImage(UIImage(), for: .normal)
        guard let url = webView.url else { return }
        navigationItem.title = url.absoluteString
        NetworkManager.shared.canDownload(video: url.absoluteString) { [weak self] downloadURL in
            guard let self = self else { return }
            guard let downloadURL = downloadURL else {
                return DispatchQueue.main.async { self.loadingView.stopAnimating() }
            }
            guard let url = URL(string: downloadURL) else { return }
            DispatchQueue.main.async {
                self.currentDownloadURL = url
                self.loadingView.stopAnimating()
                self.downloadButton.isEnabled = true
                self.downloadButton.setImage(UIImage.downloadIcon, for: .normal)
            }
        }
    }
}
