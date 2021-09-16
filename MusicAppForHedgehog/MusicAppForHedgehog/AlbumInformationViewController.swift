//
//  AlbumInformationViewController.swift
//  MusicAppForHedgehog
//
//  Created by Михаил Серёгин on 15.08.2021.
//

import UIKit



class AlbumInformationViewController: UIViewController {
    
    var albumID : Int = 0
    
    @IBOutlet weak var informationStackView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var results: [Result] = []
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var trackTableView: UITableView!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData(albumId: albumID)
    
        self.trackTableView.dataSource = self
        self.trackTableView.delegate = self
    }
    
    func pasteData(){
        informationStackView.isHidden = false
        let albumName = results[0].collectionName
        let artistName = results[0].artistName
        var releaseDate = results[0].releaseDate
        let country = results[0].country
        let primaryGenreName = results[0].primaryGenreName
        let range = releaseDate.index(releaseDate.startIndex, offsetBy: 4)..<releaseDate.endIndex
        releaseDate.removeSubrange(range)
        
        informationLabel.text = primaryGenreName + ", " + country + ", " + releaseDate
        albumNameLabel.text = albumName
        artistNameLabel.text = artistName
        configure(with: results[0].artworkUrl100)
    }
    
    func configure(with urlString: String){
        guard let url = URL(string: urlString) else{
            
            return
        }
        URLSession.shared.dataTask(with: url){ data, _, error in
            guard let data = data, error == nil else{
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.albumImageView.image = image
            }
        }.resume()
    }
    
    func loadData(albumId: Int){
        activityIndicator.startAnimating()
        let urlString = "https://itunes.apple.com/lookup?id=\(albumId)&entity=song"
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
                    self?.results.remove(at: 0)
                    self?.trackTableView?.reloadData()
                    self?.pasteData()
                    self?.activityIndicator.stopAnimating()
                }
                
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
}
extension AlbumInformationViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = trackTableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath)
        cell.textLabel?.text = results[indexPath.item].trackName
        cell.textLabel?.textColor = UIColor.white
       
        return cell
    }
    
    
}
