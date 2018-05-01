//
//  PhotoCell.swift
//  PixelCity
//
//  Created by Valentinas Mirosnicenko on 5/1/18.
//  Copyright © 2018 Valentinas Mirosnicenko. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    
    var commonConstraints:[NSLayoutConstraint] = []
    
    override func awakeFromNib() {
//        super.awakeFromNib()
//        debugPrint("Cell is waking up")
//        setupView()
//        contentView.addSubview(imageView)
//        setupConstraints()
//        NSLayoutConstraint.activate(commonConstraints)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init(coder:) has not been implemented")
    }
    
    func configureImage(image: UIImage!) {
        debugPrint("Cell is waking up")
        setupView()
        contentView.addSubview(imageView)
        setupConstraints()
        NSLayoutConstraint.activate(commonConstraints)
        imageView.image = image
    }
    
    fileprivate func setupView() {
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func setupConstraints() {
        commonConstraints = [
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ]
    }
    

    
}
