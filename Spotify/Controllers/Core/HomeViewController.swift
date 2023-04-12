//
//  ViewController.swift
//  Spotify
//
//  Created by Nancy Hernandez Yanez on 10-04-23.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings))
            
    }
    
    @objc func didTapSettings() {
        let vc = SettingsViewController()
        vc.title = "Settings"
        /*let vc = ProfileViewController()
        vc.title = "Profile"*/
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

}

