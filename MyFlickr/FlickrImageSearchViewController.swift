//
//  ViewController.swift
//  MyFlickr
//
//  Created by Pardhu G on 09/06/19.
//  Copyright © 2019 Pardhu G. All rights reserved.
//

import UIKit

class FlickrImageSearchViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet var outletObjects: FlickrImageCollectionOutlet!
    
    private var collectionViewDriver: FlickrImageViewModel! /* Where all the processes related to table view is happening */
   
    private lazy var searchText = ""
    private lazy var paginationOngoing = false /* When the user reaches the bottom, pagination starts and if he tries to scroll again, to avoid multiple API calls, we are setting this flag */
    private lazy var paginationIndicatorHeight: CGFloat = 44
    var pageNumber = 1
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        collectionViewDriver = FlickrImageViewModel(collectionView: outletObjects.collectionView)
        collectionViewDriver.delegate = self
        outletObjects.searchBar.inputAccessoryView = createInputAccessoryView() /* To place a done button on top of keyboard, which helps us to dismiss the keyboard */
        outletObjects.searchBar.becomeFirstResponder()
    }
    
    private func createInputAccessoryView () -> UIToolbar {
        
        let toolbarAccessoryView = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
        toolbarAccessoryView.barStyle = .default
        toolbarAccessoryView.tintColor = UIColor.blue
        let flexSpace = UIBarButtonItem(barButtonSystemItem:.flexibleSpace, target:nil, action:nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem:.done, target:self, action:#selector(FlickrImageSearchViewController.doneTouched))
        toolbarAccessoryView.setItems([flexSpace, doneButton], animated: false)
        
        return toolbarAccessoryView
    }
    
    @objc func doneTouched() {
        outletObjects.searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        /* When the clear all button in text field is clicked, I am changing back the UI as like the initial one, when app loaded for the frist time */
        if searchText.count==0 {
            self.searchText = ""
            collectionViewDriver.clearList()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text {
            self.searchText = searchText
            pageNumber = 1
            fetchImages(pageNumber: pageNumber, imageSearchParameter: searchText)
        }
    }
    var photos: [FlickrImageModel] = []
    func fetchImages (pageNumber:Int, imageSearchParameter: String) {
        
        guard imageSearchParameter.count>0 else {
            return
        }
        
        let requestUrlString = "\(Constants.baseURLString)&api_key=\(Constants.apiKey)&page=\(pageNumber)&text=\(imageSearchParameter)"
        let url = NSURL(string: requestUrlString)
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let getData = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            if let data = data {
                do {
                    guard let datasourceDictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                        return
                    }
                    
                    let photosArray = datasourceDictionary["photos"] as? [String:Any]
                    if let photoArray = photosArray!["photo"] as? [[String:Any]] {
                        self.photos.removeAll()
                        for photo in photoArray {
                            let photoObj = FlickrImageModel(dataSource: photo)
                            self.photos.append(photoObj)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        if self.photos.count>0 {
                            
                            if self.paginationOngoing { /* If this call was from the infinte scroll process, we need to dismiss the message displayed at the bottom and stop the activity indicator inside it */
                                self.paginationOngoing = false
                                self.presentPaginationIndicator(false)
                            }
                            self.collectionViewDriver.reload(with: self.photos)
                            
                        } else {
                            self.collectionViewDriver.clearList()
                            self.showAlert(title: "No results found", message: "Try again with another search")
                        }
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        self.showAlert()
                    }
                }
            }
            
            if error != nil {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.showAlert()
                }
            }
        }
        
        getData.resume()
    }
    
    
    private func showAlert(title: String? = nil, message: String? = nil) {
        
        let alertController = UIAlertController(title: title ?? "Sorry",
                                                message: message ?? "There was an error in fetching images",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func presentPaginationIndicator(_ show: Bool) {
        
        guard searchText.count>0 else {
            return
        }
        /* To prsent and dismiss (with animation), the paginationIndicatorView, which shows the message of ongoing API call */
        
        if show {
            
            outletObjects.paginationIndicatorView.isHidden = false
            outletObjects.paginationIndicator.startAnimating()
            outletObjects.paginationIndicatorBottom.constant = 0
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
            
        } else {
            
            outletObjects.paginationIndicatorBottom.constant = -paginationIndicatorHeight
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
                self.outletObjects.paginationIndicator.stopAnimating()
                self.outletObjects.paginationIndicatorView.isHidden = true
            }
        }
    }
}

extension FlickrImageSearchViewController: ViewModelDelegate {
    
    func startPagination() {
        
        if !paginationOngoing {
            paginationOngoing = true
            self.presentPaginationIndicator(true)
            pageNumber += 1
            fetchImages(pageNumber: pageNumber, imageSearchParameter: searchText)
        }
    }
}

