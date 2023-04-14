//
//  ViewController.swift
//  Spotify
//
//  Created by Nancy Hernandez Yanez on 10-04-23.
//

import UIKit

enum BrowseSectionType {
    case newReleases //0
    case featuredPlaylists //1
    case recommendedTracks //2
}

class HomeViewController: UIViewController {

    private var collectionView: UICollectionView!
    
    
    private let spinner : UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Browse"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings)
        )
        
        configureCollectionView()
        view.addSubview(spinner)
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
                    return self.createSectionLayout(section: sectionIndex)
                }
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
    }
    
    
    private func fetchData() {
        //Featured Playlists
        //Recommended Tracks
        //New Releases
        APICaller.shared.getRecommendedGenres { result in
            switch result {
            case .success(let model):
                let genres = model.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = genres.randomElement() {
                        seeds.insert(random)
                    }
                }
                APICaller.shared.getRecommendations(genres: seeds) { _ in
                    
                }
            case .failure(let error): break
            }
        }
    }
    
    @objc func didTapSettings() {
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

}

//MARK: - Collection View
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if indexPath.section == 0 {
            cell.backgroundColor = .systemGreen
        }
        else if indexPath.section == 1 {
            cell.backgroundColor = .systemPink
        }
        else if indexPath.section == 2 {
            cell.backgroundColor = .systemBlue
        }
        return cell
    }
    
    private func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        switch section {
        case 0:
            //Item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(1.0))
            let item = NSCollectionLayoutItem(
                layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //Vertica Group in Horizontal Group
            //TODO: - Revisar como reemplazar el método deprecado: vertical/horizontal(layoutSize, subitem:  count: )
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(390))
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count:3)
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: verticalGroup, count:1)
            //Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            
            return section
        case 1:
            //Item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(200),
                heightDimension: .absolute(200))
            let item = NSCollectionLayoutItem(
                layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //Group
            //TODO: - Revisar como reemplazar el método deprecado: vertical/horizontal(layoutSize, subitem:  count: )
            let groupSizeVertical = NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400))
            let groupSizeHorizontal = NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400))
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSizeVertical, subitem: item, count:2)
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSizeHorizontal, subitem: verticalGroup, count:1)
            //Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            return section
        case 2:
            //Item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(
                layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //Vertical Group in Horizontal Group
            //TODO: - Revisar como reemplazar el método deprecado: vertical/horizontal(layoutSize, subitem:  count: )
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))

            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count:1)
            //Section
            let section = NSCollectionLayoutSection(group: group)
            return section
        default:
            //Item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(1.0))
            let item = NSCollectionLayoutItem(
                layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //Group
            //TODO: - Revisar como reemplazar el método deprecado: vertical/horizontal(layoutSize, subitem:  count: )
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(390))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count:1)
            //Section
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }

}
