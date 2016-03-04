//
//  StrikeThroughText.swift
//  GestureDrivenListInSwift
//
//  Created by Rommel Rico on 3/4/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit
import QuartzCore

class StrikeThroughText: UILabel {
    //Properties
    let kStrikeOutThickness: CGFloat = 2.0
    let strikeThroughLayer: CALayer
    var strikeThrough: Bool {
        didSet {
            strikeThroughLayer.hidden = !strikeThrough
            if strikeThrough {
                resizeStrikeThrough()
            }
        }
    }
    
    override init(frame: CGRect) {
        //Initialize without a strikeThrough
        strikeThroughLayer = CALayer()
        strikeThroughLayer.backgroundColor = UIColor.whiteColor().CGColor
        strikeThroughLayer.hidden = true
        strikeThrough = false
        super.init(frame: frame)
        layer.addSublayer(strikeThroughLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resizeStrikeThrough()
    }
    
    func resizeStrikeThrough() {
        //Draws a line in the vertical middle of the label.
        let textSize = (self.text! as NSString).sizeWithAttributes([NSFontAttributeName : font])
        strikeThroughLayer.frame = CGRect(x: 0, y: bounds.size.height/2, width: textSize.width, height: kStrikeOutThickness)
    }

}
