//
//  RoundedCornerImage.swift
//  Vision_iOSDev
//
//  Created by Raju Dhumne on 17/02/18.
//  Copyright © 2018 Raju Dhumne. All rights reserved.
//

import UIKit

class RoundedCornerImage: UIImageView {
    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = 15
    }
    
}
