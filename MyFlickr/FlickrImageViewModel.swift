//
//  FlickrImageViewModel.swift
//  MyFlickr
//
//  Created by Pardhu G on 09/06/19.
//  Copyright © 2019 Pardhu G. All rights reserved.
//

import UIKit
protocol ViewModelDelegate: class {
    func startPagination() /* To indicate page scrolled to the bottom, so next round of API call must happen.  */
}
class FlickrImageViewModel : NSObject {
    
    weak var delegate: ViewModelDelegate?
    private let collectionView: UICollectionView
    private let cellIdentifier = "FlickrImageCollectionViewCell"
    private var photos: [FlickrImageModel] = []
    private let pendingOperations = PendingOperations()
    private let imageCache = NSCache<NSString, UIImage>()
    
    init(collectionView: UICollectionView) {
        
        self.collectionView = collectionView
        
        super.init()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0) /* To make room for the pagination message flash card that appears from the bottom, we are giving an inset 44 to the bottom, which is same as that paginationIndicatorView height */
        self.collectionView.reloadData()
    }
    
    func reload(with dataSource: [FlickrImageModel]) {
        
        photos += dataSource
        collectionView.reloadData()
        collectionView.isHidden = false
    }
    
    func clearList() {
        pendingOperations.downloadQueue.cancelAllOperations()
        collectionView.isHidden = true
        photos = [FlickrImageModel]()
        collectionView.reloadData()
    }
    
    private func startDownload(for photoData: FlickrImageModel, at indexPath: IndexPath) {
        
        guard pendingOperations.downloadsInProgress[indexPath] == nil,
            let url = photoData.link else {
                
                /* Checking for this particular indexPath, whether there is already an operation in downloadsInProgress or not. If so, ignore this request. */
                
                return
        }
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            
            /* Checking whether image is available in the cache. If yes, we will load from there only instead of going for the download process again. */
            
            /* In the next rounds of  API calls (that is after the user reaches the end of the scroll), I am calling the same url again, so it will return the same set of images. Because of cacheing, you can see many of the images in the subsequent calls are loading immediately, because that has already downloaded from the initial call */
            
            photoData.image = cachedImage
            self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
            self.collectionView.reloadItems(at: [indexPath])
            
        } else {
            
            let downloader = ImgurPhotosDownload(photoData) /* Creating an instance of ImageDownloader by using the designated initializer. */
            downloader.completionBlock = {
                if downloader.isCancelled {
                    return
                }
                
                /* This completion block will be executed when the operation is completed. The completion block is executed even if the operation is cancelled, so we must check this property before doing anything. We also have no guarantee of which thread the completion block is called on, so using a GCD to trigger a reload of the table view on the main thread. */
                
                DispatchQueue.main.async {
                    self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                    self.collectionView.reloadItems(at: [indexPath])
                    if let downloadedImage = downloader.photoObject.image {
                        self.imageCache.setObject(downloadedImage, forKey: url.absoluteString as NSString)
                    }
                }
            }
            
            /* Creating the operation to downloadsInProgress to help keep track of things. and adding the operation to the download queue. So we will trigger these operations to start running. */
            pendingOperations.downloadsInProgress[indexPath] = downloader
            pendingOperations.downloadQueue.addOperation(downloader)
        }
    }
}

extension FlickrImageViewModel: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let detailImageView = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "DetailedImageView") as? FlickrImageDetailViewController {
            let photoData = photos[indexPath.item]
            detailImageView.imageSelected = photoData.image ?? UIImage()
            if let parent = self.delegate as? FlickrImageSearchViewController {
                parent.navigationController?.pushViewController(detailImageView, animated:true)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? FlickrImageCollectionViewCell {
            
            if indexPath.item < photos.count {
                
                let photoData = photos[indexPath.item]
                cell.configureCellWith(photoData: photoData)
                
                /* If the photo object's state is .new, we kick off a start download operation and if it is failed, we will change the UI of the cell accordingly. And if the state is already downloaded, in the configureCellWith(photoData:) of ImageListCollectionViewCell, the cell will receive the downloaded image */
                
                switch (photoData.state) {
                case .failed:
                    cell.errorLoading()
                case .new:
                    startDownload(for: photoData, at: indexPath)
                case .downloaded:
                    print("Download complete")
                }
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
}

extension FlickrImageViewModel: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = UIScreen.main.bounds.size.width/3
        let padding: CGFloat = 8
        let titleHeight: CGFloat = 20
        let cellHeight: CGFloat = cellWidth + (3*padding) + titleHeight
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension FlickrImageViewModel: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        /* Calculating whether the collection view has reached the end of the scroll or not. If yes, we will kick off the next round of image search API call */
        
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            self.delegate?.startPagination()
        }
    }
    
}
