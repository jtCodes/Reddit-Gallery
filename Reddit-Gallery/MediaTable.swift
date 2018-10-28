//
//  MediaTable.swift
//  Reddit-Gallery
//
//  Created by J Tan on 10/27/18.
//  Copyright © 2018 J Tan. All rights reserved.
//

import UIKit
import Foundation
import Kingfisher
import SnapKit

protocol MediaTableDelegate: class {
    func reusableTableDidSelect(threadNo: Int)
    func urlTapped(url: URL)
    func moreButtonTapped(selectedPost: Post)
}

class MediaTable: NSObject, UITableViewDataSource, UITableViewDelegate{
    var delegate: MediaTableDelegate?
    
    let saturation = CGFloat(0.70)
    let lightness = CGFloat(1)

    var postArray = [Post]()
    var tableView: UITableView
    
    init(_ tv: UITableView, _ data: [Post]) {
        
        postArray = data
        tableView = tv

        tableView.tableFooterView = UIView(frame: .zero)
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) //top,left,bottom,right
        tableView.separatorColor = .clear
        
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MediaTableCell.self, forCellReuseIdentifier: "imageCell")
    }
    
    // MARK: - Tableview Setup
    // End of scrolling optimization
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let imageCell = tableView.dequeueReusableCell(withIdentifier: "imageCell") as! MediaTableCell
        imageCell.backgroundColor = .white
        let thumbUrl = postArray[indexPath.row].fallBackThumb
        imageCell.postImage.kf.setImage(with: URL(string: thumbUrl), completionHandler: {
            (image, error, cacheType, imageUrl) in
//            if image != nil {
//                let newCellHeight = self.getAspectRatioAccordingToiPhones(cellImageFrame: imageCell.frame.size, downloadedImage: image!)
//                imageCell.postImage.snp.makeConstraints({make in
//                    make.height.equalTo(newCellHeight)
//                })
//                imageCell.layoutIfNeeded()
//            }
        })
        return imageCell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let newViewController = MediaPageViewController()
            newViewController.postMediaItems = postArray
            newViewController.currentIndex = indexPath.row
            newViewController.modalPresentationStyle = .overCurrentContext
            UIApplication.shared.keyWindow?.windowLevel = UIWindow.Level.statusBar
            topController.present(newViewController, animated: true, completion: nil)
        }
    }
    
    func getAspectRatioAccordingToiPhones(cellImageFrame:CGSize,downloadedImage: UIImage)->CGFloat {
        let widthOffset = downloadedImage.size.width - cellImageFrame.width
        let widthOffsetPercentage = (widthOffset*100)/downloadedImage.size.width
        let heightOffset = (widthOffsetPercentage * downloadedImage.size.height)/100
        let effectiveHeight = downloadedImage.size.height - heightOffset
        return(effectiveHeight)
    }
}

extension UITableView {
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections - 1) - 1,
                section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func scrollToTop() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}


