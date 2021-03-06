//
//  MapVC.swift
//  PixelCity
//
//  Created by Valentinas Mirosnicenko on 5/1/18.
//  Copyright © 2018 Valentinas Mirosnicenko. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    // Outlets
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var collectionContainer: UIView!
    @IBOutlet private weak var collectionContainerHeightConstraint: NSLayoutConstraint!
    
    private var spinner: UIActivityIndicatorView?
    private var progressLabel: UILabel?
    private var collectionView: UICollectionView?
    private var flowLayout = UICollectionViewFlowLayout()
    
    // Variables
    private var locationManager = CLLocationManager()
    private let authorizationStatus = CLLocationManager.authorizationStatus()
    private let regionRadius: Double = 1000
    private var screenSize = UIScreen.main.bounds
    private var imageUrlArray = [String]()
    private var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        configureLocationServices()
        addTap()
        addSwipe()
        
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        
        registerForPreviewing(with: self, sourceView: collectionView!)
        collectionContainer.addSubview(collectionView!)
        
    }
    
    fileprivate func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        mapView.addGestureRecognizer(tap)
    }
    
    fileprivate func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        swipe.delegate = self
        collectionContainer.addGestureRecognizer(swipe)
    }
    
    fileprivate func animateViewUp() {
        
        collectionContainerHeightConstraint.constant = 300
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc fileprivate func animateViewDown() {
        
        cancelAllSessions()
        collectionContainerHeightConstraint.constant = 1
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    fileprivate func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width/2) - ((spinner?.frame.width)!/2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    fileprivate func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    fileprivate func addProgressLabel() {
        progressLabel = UILabel()
        let width:CGFloat = screenSize.width-40
        progressLabel?.frame = CGRect(x: (screenSize.width/2) - (width/2), y: 175, width: width, height: 40)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 18.0)
        progressLabel?.textColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        progressLabel?.textAlignment = .center
        progressLabel?.text = "Download in Progress..."
        collectionView?.addSubview(progressLabel!)
        
    }
    
    fileprivate func removeProgressLabel() {
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
    }

    @IBAction fileprivate func locationButtonPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
    fileprivate func retrieveUrls(forAnnotation annotation:DroppablePin, completion: @escaping (_ status: Bool) -> ()) {
        
        Alamofire.request(flickerUrl(withAnotation: annotation, numberOfPhotos: 40)).responseJSON { (response) in
            
            guard let json = response.result.value as? Dictionary<String, AnyObject> else {
                debugPrint("Failed turned into json")
                return
            }
            
            debugPrint(json)
            
            guard let photosDictionary = json["photos"] as? Dictionary<String, AnyObject> else {
                debugPrint("failed to get photosDictionary")
                return
            }
            
            guard let photosDictionaryArray = photosDictionary["photo"] as? [Dictionary<String, AnyObject>] else {
                debugPrint("Failed to receive any photos")
                return
            }
            
            for photo in photosDictionaryArray {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imageUrlArray.append(postUrl)
            }
            
            completion(true)
        }
    }
    
    fileprivate func retrieveImages(completion: @escaping (_ status: Bool) -> ()) {
        for url in imageUrlArray {
            Alamofire.request(url).responseImage { (response) in
                guard let image = response.result.value else { return }
                self.imageArray.append(image)
                self.progressLabel?.text = "\(self.imageArray.count)/40 Images Downloaded..."
                
                if self.imageArray.count == self.imageUrlArray.count {
                    completion(true)
                }
                
            }
        }
        
    }
    
    fileprivate func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius*2, regionRadius*2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return MKAnnotationView()
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9647058824, green: 0.6509803922, blue: 0.137254902, alpha: 1)
        pinAnnotation.animatesDrop = true
        
        return pinAnnotation
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        cancelAllSessions()
        removePin()
        removeSpinner()
        removeProgressLabel()
        
        imageUrlArray = []
        imageArray = []
        collectionView?.reloadData()
        
        animateViewUp()
        addSpinner()
        addProgressLabel()
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius*2, regionRadius*2)
        mapView.setRegion(coordinateRegion, animated: true)
        
        retrieveUrls(forAnnotation: annotation) { (success) in
            if success {
                
                self.retrieveImages(completion: { (success) in
                    if success {
                        self.removeSpinner()
                        self.removeProgressLabel()
                        
                        debugPrint("Finished! Reloading collection view")
                        self.collectionView?.reloadData()
                    }
                })
                
            }
        }
        
        print(touchPoint, touchCoordinate)
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
}

extension MapVC: CLLocationManagerDelegate {
    
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            centerMapOnUserLocation()
            mapView.showsUserLocation = true
        }
    }
    
    
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        debugPrint("Selected",indexPath.item)
        
        guard let popVc = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return }
        popVc.initData(forImage: imageArray[indexPath.item])
        present(popVc, animated: true, completion: nil)
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell {
            cell.configureImage(image: imageArray[indexPath.item])
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionContainer.frame.width / 8
        let height = collectionContainer.frame.height / 5
        
        
        return CGSize(width: width, height: height)
    }
    
    
}

extension MapVC: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) as? PhotoCell else { return nil }
        guard let popVc = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return nil }
        popVc.initData(forImage: imageArray[indexPath.item])
        previewingContext.sourceRect = cell.contentView.frame
        return popVc
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    
}
