//
//  TableViewCell.swift
//  GestureDrivenListInSwift
//
//  Created by Rommel Rico on 3/4/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit
import QuartzCore

class TableViewCell: UITableViewCell {
    //Properties
    let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        //Gradient layer for cell.
        gradientLayer.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.2).CGColor as CGColorRef
        let color2 = UIColor(white: 1.0, alpha: 0.1).CGColor as CGColorRef
        let color3 = UIColor.clearColor().CGColor as CGColorRef
        let color4 = UIColor(white: 0, alpha: 0.1).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0, 0.01, 0.95, 1]
        layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

}
