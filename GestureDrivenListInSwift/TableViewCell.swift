//
//  TableViewCell.swift
//  GestureDrivenListInSwift
//
//  Created by Rommel Rico on 3/4/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit
import QuartzCore

//Protocol to inform TableViewController that cell has changed.
protocol TableViewCellDelegate {
    func toDoItemDeleted(toDoItem: ToDoItem)
}

class TableViewCell: UITableViewCell {
    //Properties
    let gradientLayer = CAGradientLayer()
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var delegate: TableViewCellDelegate?
    var toDoItem: ToDoItem?
    
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
        
        //Add a Pan Gesture Recognizer.
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panRecognizer.delegate = self
        addGestureRecognizer(panRecognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        switch(recognizer.state) {
        case .Began:
            originalCenter = center
            break
        case .Changed:
            let translation = recognizer.translationInView(self)
            center = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
            //Drag more than halfway to delete.
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
            break
        case .Ended:
            //Frame before dragging
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            if deleteOnDragRelease {
                if delegate != nil && toDoItem != nil {
                    //Notify delegate that item should be deleted.
                    delegate?.toDoItemDeleted(toDoItem!)
                }
            } else {
                //If the item is not being deleted, drag back to original place.
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.frame = originalFrame
                })
            }
            break
        default:
            break
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = gestureRecognizer.translationInView(superview!)
            if fabs(translation.x) > fabs(translation.y) {
                //Here we determine that the gesture is horizontal not vertical.
                return true
            }
        }
        return false
    }

}
