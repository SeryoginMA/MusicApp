//
//  AlbumListViewController.swift
//  MusicAppForHedgehog
//
//  Created by Михаил Серёгин on 14.08.2021.
//

import UIKit


class AlbumListViewController: UIViewController, UISearchBarDelegate{
    
//    let urlString = "https://itunes.apple.com/search?term=all&entity=album"
    
    var results: [Result] = []
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var albumCollection: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        self.albumCollection.register(UINib(nibName: "AlbumCell", bundle: nil),forCellWithReuseIdentifier: "AlbumCell")
        self.albumCollection.dataSource = self
        self.albumCollection.delegate = self
        fetchPhotos(query: "all")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text{
            results = []
            albumCollection?.reloadData()
            fetchPhotos(query: text)
        }
    }
    
    func showAlert(){
        
        let alert = UIAlertController(title: "No result", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler:nil))
        self.present(alert, animated: true)
    }
    
    func fetchPhotos(query: String){
        activityIndicator.startAnimating()

        var query = query
        
        if query.contains(" "){
            query = replaceSpaces(text: query)
        }
        
        let urlString = "https://itunes.apple.com/search?term=\(query)&entity=album"
        guard let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do{
                let jsonResult = try JSONDecoder().decode(APIResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self?.results = jsonResult.results
                    self?.results = (self?.results.sorted(by:  {$0.collectionName < $1.collectionName}))!
                    if self?.results.count != 0{
                        self?.albumCollection?.reloadData()
                    }else{
                        self?.showAlert()
                    }
                    self?.activityIndicator.stopAnimating()
                }
            }
            catch {
                self?.showAlert()
                print(error)
            }
        }
        task.resume()
    }
    
    func replaceSpaces(text: String) -> String{
        let textWithPlus = text
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }
            .joined(separator: "+")
        return textWithPlus
    }
}

extension AlbumListViewController:UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func goToAlbumInformation(albumID: Int){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let secondViewController = storyboard.instantiateViewController(identifier: "AlbumInformationViewController") as? AlbumInformationViewController else { return }
                secondViewController.albumID = albumID
                
                show(secondViewController, sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = results[indexPath.item].collectionId
        goToAlbumInformation(albumID: id)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = albumCollection.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as? AlbumCell else {
            return UICollectionViewCell()
        }
        let result = results[indexPath.item]
        let imageUrl = result.artworkUrl100
        let artistName = result.artistName
        let albumName = result.collectionName
        cell.albumNameLabel.text = albumName
        cell.artistNameLabel.text = artistName
        cell.configure(with: imageUrl)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width/2-5, height: UIScreen.main.bounds.width/2+20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
