//
//  MediaTableCell.swift
//  Reddit-Gallery
//
//  Created by J Tan on 10/27/18.
//  Copyright © 2018 J Tan. All rights reserved.
//

import Foundation
import SnapKit

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
            let w = contentView.frame.size.width * 0.9
            let newH = w / 16 * 9

            make.center.equalTo(contentView.snp.center)
            make.width.equalTo(w)
            make.height.equalTo(newH)
            make.top.equalTo(contentView.snp.top).offset(10)
            make.bottom.equalTo(contentView.snp.bottom).offset(-10)
        }
    }
}
