//
//  Constants.swift
//  PixelCity
//
//  Created by Valentinas Mirosnicenko on 5/1/18.
//  Copyright © 2018 Valentinas Mirosnicenko. All rights reserved.
//

import Foundation


let API_KEY = "b5512604dec20be7bc9e2c0df74958ee"
let SECRET = "1aabf3b3ae09522f"

// https://farm1.staticflickr.com/464/18584211154_cf9a7908aa_k_d.jpg

func flickerUrl(withAnotation annotation: DroppablePin, numberOfPhotos number: Int) -> String {
    
    let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=5&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
   
    return url
}


