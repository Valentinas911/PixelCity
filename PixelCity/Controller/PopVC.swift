//
//  PopVC.swift
//  PixelCity
//
//  Created by Valentinas Mirosnicenko on 5/1/18.
//  Copyright © 2018 Valentinas Mirosnicenko. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet private weak var imageView: UIImageView!
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDoubeTap()
        
        if image != nil {
            imageView.image = image
        }
        
    }
    
    fileprivate func addDoubeTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
        
    }
    
    @objc fileprivate func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    func initData(forImage image: UIImage) {
        self.image = image
    }

}
