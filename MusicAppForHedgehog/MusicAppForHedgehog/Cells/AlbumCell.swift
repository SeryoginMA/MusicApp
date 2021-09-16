//
//  AlbumCell.swift
//  MusicAppForHedgehog
//
//  Created by Михаил Серёгин on 15.08.2021.
//

import UIKit

class AlbumCell: UICollectionViewCell {

    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    
    @IBOutlet weak var artistNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func prepareForReuse() {
        albumImage.image = nil
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
                self.albumImage.image = image
            }
        }.resume()
    }
}

