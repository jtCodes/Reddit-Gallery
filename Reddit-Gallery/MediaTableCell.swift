//
//  MediaTableCell.swift
//  Reddit-Gallery
//
//  Created by J Tan on 10/27/18.
//  Copyright © 2018 J Tan. All rights reserved.
//

import Foundation
import SnapKit

var portW:CGFloat = 0.0
var portH:CGFloat = 0.0

class MediaTableCell: UITableViewCell {
    
    let postImage: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "placeholder-tn")
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 2.0
        return imgView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(postImage)
        self.setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("has not been implemented")
    }
    
    func setupConstraints() {
        postImage.snp.makeConstraints { make in
            let w = contentView.frame.size.width
            let newH = w / 16 * 9
            portW = w
            portH = newH
            make.width.equalTo(w)
            make.height.equalTo(newH)
            make.top.equalTo(contentView.snp.top).offset(1)
            make.bottom.equalTo(contentView.snp.bottom).offset(0)
        }
    }
}
