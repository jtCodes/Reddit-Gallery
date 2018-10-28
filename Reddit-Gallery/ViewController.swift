//
//  ViewController.swift
//  Reddit-Gallery
//
//  Created by J Tan on 10/27/18.
//  Copyright © 2018 J Tan. All rights reserved.
//

import UIKit
import Alamofire

let reqUrl = "https://www.reddit.com/r/videos/new.json?"

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request(reqUrl).responseJSON { response in
            if let data = response.data {
                if let decodedSubRedditData = try? JSONDecoder().decode(SubRedditDecode.Root.self,from:  data) {
                    print(decodedSubRedditData.data.children[0])
                }
            }
        }
    }
}

