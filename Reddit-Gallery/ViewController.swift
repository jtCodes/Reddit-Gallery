//
//  ViewController.swift
//  Reddit-Gallery
//
//  Created by J Tan on 10/27/18.
//  Copyright © 2018 J Tan. All rights reserved.
//

import UIKit
import Alamofire

let reqUrl = "https://www.reddit.com/r/videos/hot.json?"

class ViewController: UIViewController {
    
    var tableView: UITableView!
    var mediaTable: MediaTable!
    
    var posts: [Post]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = themeDict["cell"] //blend table if seperator 
        
        tableView = UITableView(frame: view.frame, style: UITableView.Style.grouped)
        self.view.addSubview(tableView) //REMINDER: Add subview BEFORE snp make
        
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = themeDict["table"]
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
        statusBarView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        
        tableView.snp.makeConstraints { make in
            make.width.equalTo(self.view.snp.width)
            make.top.equalTo(self.view.snp.top)
            make.bottom.equalTo(self.view.snp.bottom)
        }
        
        fetchPosts(url: reqUrl, completion: {response in
            print(response[0])
            self.mediaTable = MediaTable(self.tableView, response[0] as! [Post])
            self.mediaTable.tableView.reloadData()
        })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
