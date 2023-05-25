//
//  ViewController.swift
//  Spotify
//
//  Created by Nancy Hernandez Yanez on 10-04-23.
//

import UIKit

enum BrowseSectionType {
    case newReleases(viewModels: [NewReleasesCellViewModel]) //0
    case featuredPlaylists(viewModels: [FeaturedPlaylistCellViewModel])  //1
    case recommendedTracks(viewModels: [RecommendedTrackCellViewModel])  //2
    
    var title: String {
        switch self {
        case .newReleases:
            return "New Releases Albums"
        case .featuredPlaylists:
            return "Featured Playlists"
        case .recommendedTracks:
            return "Recommended"
        }
    }
}

class HomeViewController: UIViewController {
    
    private var newAlbums: [Album] = []
    private var playlists: [Playlist] = []
    private var tracks: [AudioTrack] = []

    private var collectionView: UICollectionView!
    
    private let spinner : UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var sections = [BrowseSectionType]()
    
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
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(
            TitleHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
    }
    
    
    private func fetchData() {
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
 
        var newReleases: NewReleasesResponse?
        var featuredPlaylist: FeaturedPlaylistsResponse?
        var recommendations: RecommendationsResponse?
        
        //New Releases
        APICaller.shared.getNewReleases { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model):
                newReleases = model
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        //Featured Playlists
        APICaller.shared.getFeaturedPlaylists { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model):
               featuredPlaylist = model
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        //Recommended Tracks
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
                
                APICaller.shared.getRecommendations(genres: seeds) { recommendedResult in
                    defer {
                        group.leave()
                    }
                    switch recommendedResult {
                    case .success(let model):
                        recommendations = model
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        group.notify(queue: .main){
            guard let newAlbums = newReleases?.albums.items,
                  let playlists = featuredPlaylist?.playlists.items,
                  let tracks = recommendations?.tracks else {
                fatalError("Model are nil")
                return
            }
            self.configureModels(newAlbums: newAlbums, playlists: playlists, tracks: tracks)
        }
    }
    
    private func configureModels(
        newAlbums: [Album],
        playlists: [Playlist],
        tracks: [AudioTrack]
    ) {
        self.newAlbums = newAlbums
        self.playlists = playlists
        self.tracks = tracks
        
        sections.append(.newReleases(viewModels: newAlbums.compactMap({
            return NewReleasesCellViewModel(
                name: $0.name,
                artworkURL: URL(string: $0.images.first?.url ?? ""),
                numberOfTracks: $0.total_tracks,
                artistName: $0.artists.first?.name ?? "-"
            )
        })))
            sections.append(.featuredPlaylists(viewModels: playlists.compactMap({
                return FeaturedPlaylistCellViewModel(
                    name: $0.name,
                    artworkURL: URL(string: $0.images.first?.url ?? ""),
                    creatorName: $0.owner.display_name
                )
            })))
            
            sections.append(.recommendedTracks(viewModels: tracks.compactMap({
                return RecommendedTrackCellViewModel(
                    name: $0.name,
                    artist: $0.artists.first?.name ?? "-",
                    artworkURL: URL(string: $0.album?.images.first?.url ?? "")
                )
            })))
            
        collectionView.reloadData()
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
        let type = sections[section]
        switch type {
        case .newReleases(let viewModels):
            return viewModels.count
        case .featuredPlaylists(let viewModels):
            return viewModels.count
        case .recommendedTracks(let viewModels):
            return viewModels.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        switch type {
        case .newReleases(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewReleaseCollectionViewCell.identifier,
                for: indexPath
            ) as? NewReleaseCollectionViewCell else {
                return UICollectionViewCell()
            }
            //let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModels[indexPath.row])
            return cell
            
        case .featuredPlaylists(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier,
                for: indexPath
            ) as? FeaturedPlaylistCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
            
        case .recommendedTracks(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier,
                for: indexPath
            ) as? RecommendedTrackCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        }
        

    }
    //MARK: - Section Layout
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let section = sections[indexPath.section]
        switch section {
        case .featuredPlaylists:
            let playlist = playlists[indexPath.row]
            let vc = PlaylistViewController(playlist: playlist)
            vc.title = playlist.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .newReleases:
            let album = newAlbums[indexPath.row]
            let vc = AlbumViewController(album: album)
            vc.title = album.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .recommendedTracks:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TitleHeaderCollectionReusableView.identifier,
            for: indexPath
        ) as? TitleHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let section = indexPath.section
        let title = sections[section].title
        header.configure(with: title)
        return header
    }

    private func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        let supplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(50)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
        ]
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
            section.boundarySupplementaryItems = supplementaryViews
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
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400))
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count:2)
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: verticalGroup, count:1)
            //Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryViews
            return section
        case 2:
            //Item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(
                layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //VGroup
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))

            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count:1)
            //Section
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = supplementaryViews
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
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(390))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count:1)
            //Section
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = supplementaryViews
            return section
        }
    }

}
