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
        
        tableView = UITableView()
        self.view.addSubview(tableView) //REMINDER: Add subview BEFORE snp make
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
}

