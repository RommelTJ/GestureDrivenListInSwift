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
    func cellDidBeginEditing(editingCell: TableViewCell)
    func cellDidEndEditing(editingCell: TableViewCell)
}

class TableViewCell: UITableViewCell, UITextFieldDelegate {
    //Properties
    let gradientLayer = CAGradientLayer()
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var completeOnDragRelease = false
    var delegate: TableViewCellDelegate?
    var toDoItem: ToDoItem? {
        didSet {
            label.text = toDoItem!.text
            label.strikeThrough = toDoItem!.completed
            itemCompleteLayer.hidden = !label.strikeThrough
        }
    }
    var label: StrikeThroughText
    var itemCompleteLayer = CALayer()
    let kLabelLeftMargin: CGFloat = 15.0
    
    required init?(coder aDecoder: NSCoder) {
        //Initialize the label.
        label = StrikeThroughText(frame: CGRect.null)
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.boldSystemFontOfSize(16)
        label.backgroundColor = UIColor.clearColor()
        super.init(coder: aDecoder)
        
        //Add the label to the Cell.
        label.delegate = self
        label.contentVerticalAlignment = .Center
        addSubview(label)
        selectionStyle = .None
    }
    
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
        
        //Add a layer that marks the item with green background when it's completed.
        itemCompleteLayer = CALayer(layer: layer)
        itemCompleteLayer.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1).CGColor
        itemCompleteLayer.hidden = true
        layer.insertSublayer(itemCompleteLayer, atIndex: 0)
        
        //Add a Pan Gesture Recognizer.
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panRecognizer.delegate = self
        addGestureRecognizer(panRecognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        itemCompleteLayer.frame = bounds
        label.frame = CGRect(x: kLabelLeftMargin,
                             y: 0,
                             width: bounds.size.width - kLabelLeftMargin,
                             height: bounds.size.height)
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
            //Drag more than halfway to complete.
            completeOnDragRelease = frame.origin.x > frame.size.width / 2.0
            break
        case .Ended:
            //Frame before dragging
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            if completeOnDragRelease {
                if toDoItem != nil {
                    toDoItem?.completed = true
                }
                label.strikeThrough = true
                itemCompleteLayer.hidden = false
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.frame = originalFrame
                })
            } else if deleteOnDragRelease {
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
    
    //MARK: UITextFieldDelegate methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //Close the keyboard on Enter.
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        //Disable editing of completed to-do items.
        if toDoItem != nil {
            //Return true if not completed; false if completed.
            return !toDoItem!.completed
        }
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //Update the toDoItem text after editing is complete.
        if toDoItem != nil {
            toDoItem!.text = textField.text!
        }
        //Invoke cellDidEndEditing when we end editing.
        if delegate != nil {
            delegate?.cellDidEndEditing(self)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //Invoke cellDidBeginEditing when we begin editing.
        if delegate != nil {
            delegate?.cellDidBeginEditing(self)
        }
    }

}
