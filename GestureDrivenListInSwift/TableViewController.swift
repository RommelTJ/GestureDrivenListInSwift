//
//  TableViewController.swift
//  GestureDrivenListInSwift
//
//  Created by Rommel Rico on 3/4/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    //Properties
    var toDoItems = [ToDoItem]()
    let placeHolderCell = TableViewCell(style: .Default, reuseIdentifier: "cell")
    var pullDownInProgress = false
    let pinchRecognizer = UIPinchGestureRecognizer()
    var pinchInProgress = false
    struct TouchPoints {
        var upper: CGPoint
        var lower: CGPoint
    }
    var upperCellIndex = -100
    var lowerCellIndex = -100
    var initialTouchPoints: TouchPoints!
    var pinchExceededRequiredDistance = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add the pinch recognizer to the view.
        pinchRecognizer.addTarget(self, action: "handlePinch:")
        self.tableView.addGestureRecognizer(pinchRecognizer)
        
        //Hardcode some items to our list.
        if toDoItems.count == 0 {
            toDoItems.append(ToDoItem(text: "Write an app"))
            toDoItems.append(ToDoItem(text: "Eat dinner"))
            toDoItems.append(ToDoItem(text: "Buy milk"))
            toDoItems.append(ToDoItem(text: "Create website"))
            toDoItems.append(ToDoItem(text: "Discuss options"))
            toDoItems.append(ToDoItem(text: "Kill the spider"))
            toDoItems.append(ToDoItem(text: "Go to Tijuana"))
            toDoItems.append(ToDoItem(text: "Learn Korean"))
        }
        
        //Styling for the cells.
        self.tableView.separatorStyle = .None
        self.tableView.backgroundColor = UIColor.blackColor()
        self.tableView.rowHeight = 50.0
        
    }
    
    func toDoItemAdded() {
        toDoItemAddedAtIndex(0)
    }
    
    func toDoItemAddedAtIndex(index: Int) {
        let toDoItem = ToDoItem(text: "")
        toDoItems.insert(toDoItem, atIndex: index)
        self.tableView.reloadData()
        // enter edit mode
        var editCell: TableViewCell
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for cell in visibleCells {
            if (cell.toDoItem === toDoItem) { //Identity operator. Object references must be the same.
                editCell = cell
                editCell.label.becomeFirstResponder()
                break
            }
        }
    }
    
    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        switch(recognizer.state) {
        case .Began:
            pinchStarted(recognizer)
            break
        case .Changed:
            if pinchInProgress && recognizer.numberOfTouches() == 2 {
                pinchChanged(recognizer)
            }
            break
        default:
            pinchEnded(recognizer)
            break
        }
    }
    
    func pinchStarted(recognizer: UIPinchGestureRecognizer) {
        //Find the TouchPoints
        initialTouchPoints = getNormalizedTouchPoints(recognizer)
        
        //Locate the cells that these points touch.
        upperCellIndex = -100
        lowerCellIndex = -100
        let visibleCells = self.tableView.visibleCells as! [TableViewCell]
        for i in 0..<visibleCells.count {
            let cell = visibleCells[i]
            if viewContainsPoint(cell, point: initialTouchPoints.upper) {
                upperCellIndex = i
            }
            if viewContainsPoint(cell, point: initialTouchPoints.lower) {
                lowerCellIndex = i
            }
        }
        
        //Check if the cells are neighbors.
        if abs(upperCellIndex - lowerCellIndex) == 1 {
            //Initiate the pinch.
            pinchInProgress = true
            let precedingCell = visibleCells[upperCellIndex]
            placeHolderCell.frame = CGRectOffset(precedingCell.frame, 0, self.tableView.rowHeight / 2.0)
            placeHolderCell.backgroundColor = precedingCell.backgroundColor
            self.tableView.insertSubview(placeHolderCell, atIndex: 0)
        }
    }
    
    func pinchChanged(recognizer: UIPinchGestureRecognizer) {
        //Find the TouchPoints
        let currentTouchPoints = getNormalizedTouchPoints(recognizer)
        
        //Determine by how much the points have changed and take the minimum vertical delta.
        let upperDelta = currentTouchPoints.upper.y - initialTouchPoints.upper.y
        let lowerDelta = currentTouchPoints.lower.y - initialTouchPoints.lower.y
        let delta = -min(0, min(upperDelta, lowerDelta))
        
        //Offset the cells, negative for the cells above, positive for those below.
        let visibleCells = self.tableView.visibleCells as! [TableViewCell]
        for i in 0..<visibleCells.count {
            let cell = visibleCells[i]
            if i <= upperCellIndex {
                cell.transform = CGAffineTransformMakeTranslation(0, -delta)
            }
            if i >= lowerCellIndex {
                cell.transform = CGAffineTransformMakeTranslation(0, delta)
            }
        }
        
        //Scale the placeholder cell.
        let gapSize = delta * 2
        let cappedGapSize = min(gapSize, self.tableView.rowHeight)
        placeHolderCell.transform = CGAffineTransformMakeScale(1, cappedGapSize / self.tableView.rowHeight)
        if gapSize > self.tableView.rowHeight {
            placeHolderCell.label.text = "Release to add item"
        } else {
            placeHolderCell.label.text = "Pull  apart to add item"
        }
        placeHolderCell.alpha = min(1, gapSize / self.tableView.rowHeight)
        
        //Check if user has pinched enough.
        pinchExceededRequiredDistance = gapSize > self.tableView.rowHeight
    }
    
    func pinchEnded(recognizer: UIPinchGestureRecognizer) {
        pinchInProgress = false
        
        //Remove the placeholder cell.
        placeHolderCell.transform = CGAffineTransformIdentity
        placeHolderCell.removeFromSuperview()
        
        if pinchExceededRequiredDistance {
            pinchExceededRequiredDistance = false
            
            //Set all the cells back to the transform identity.
            let visibleCells = self.tableView.visibleCells as! [TableViewCell]
            for cell in visibleCells {
                cell.transform = CGAffineTransformIdentity
            }
            
            //Add a new item.
            let indexOffset = Int(floor(self.tableView.contentOffset.y / self.tableView.rowHeight))
            toDoItemAddedAtIndex(lowerCellIndex + indexOffset)
        } else {
            //Otherwise, animate back to position.
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                let visibleCells = self.tableView.visibleCells as! [TableViewCell]
                for cell in visibleCells {
                    cell.transform = CGAffineTransformIdentity
                }
                }, completion: nil)
        }
    }
    
    func getNormalizedTouchPoints(recognizer: UIGestureRecognizer) -> TouchPoints {
        var pointOne = recognizer.locationOfTouch(0, inView: self.tableView)
        var pointTwo = recognizer.locationOfTouch(1, inView: self.tableView)
        if pointOne.y > pointTwo.y {
            let temp = pointOne
            pointOne = pointTwo
            pointTwo = temp
        }
        return TouchPoints(upper: pointOne, lower: pointTwo)
    }
    
    func viewContainsPoint(view: UIView, point: CGPoint) -> Bool {
        let frame = view.frame
        //Return true if point is below the frame origin AND it's within the height of the view.
        return (frame.origin.y < point.y) && (frame.origin.y + (frame.size.height) > point.y)
    }

    // MARK: TABLE VIEW DATA SOURCE
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TableViewCell

        //Configure the cell.
        let item = toDoItems[indexPath.row]
        cell.selectionStyle = .None
        cell.delegate = self
        cell.toDoItem = item

        return cell
    }
    
    //MARK: TABLE VIEW DELEGATE
    func colorForIndex(index: Int) -> UIColor {
        //Helper method for returning a red color that is progressively greener based on its index.
        let itemCount = toDoItems.count - 1
        let val = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = colorForIndex(indexPath.row)
    }
    
    //MARK: SCROLL VIEW DELEGATE
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        //This behavior starts when a user pulls down while at the top of the table.
        pullDownInProgress = scrollView.contentOffset.y <= 0.0 //At the top of the table.
        placeHolderCell.backgroundColor = UIColor.redColor()
        if pullDownInProgress {
            //Add the placeholder
            self.tableView.insertSubview(placeHolderCell, atIndex: 0)
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollViewContentOffsetY = scrollView.contentOffset.y
        
        if pullDownInProgress && scrollView.contentOffset.y <= 0.0 {
            //Maintain the location of the placeholder.
            placeHolderCell.frame = CGRect(x: 0, y: -tableView.rowHeight, width: tableView.frame.size.width, height: tableView.rowHeight)
            placeHolderCell.label.text = -scrollViewContentOffsetY > tableView.rowHeight ? "Release to add item" : "Pull to add item"
            placeHolderCell.alpha = min(1.0, -scrollViewContentOffsetY / tableView.rowHeight)
        } else {
            pullDownInProgress = false
        }
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //Check whether the user pulled down far enough.
        if pullDownInProgress && -scrollView.contentOffset.y > tableView.rowHeight {
            toDoItemAdded()
        }
        pullDownInProgress = false
        placeHolderCell.removeFromSuperview()
    }

}

//MARK: TABLE VIEW CELL DELEGATE
extension TableViewController: TableViewCellDelegate {

    func toDoItemDeleted(toDoItem: ToDoItem) {
        let index = toDoItems.indexOf(toDoItem)
        if index != nil {
            //Found the item in the array, so remove it.
            toDoItems.removeAtIndex(index!)
            
            //Loop over the visible cells to animate delete.
            let visibleCells = self.tableView.visibleCells as! [TableViewCell]
            let lastView = visibleCells.last
            var delay = 0.0
            var startAnimating = false
            for i in 0..<visibleCells.count {
                let cell = visibleCells[i]
                if startAnimating {
                    UIView.animateWithDuration(0.3, delay: delay, options: .CurveEaseInOut, animations: { () -> Void in
                        cell.frame = CGRectOffset(cell.frame, 0, -cell.frame.size.height)
                        }, completion: { (finished) -> Void in
                            if (cell == lastView) {
                                self.tableView.reloadData()
                            }
                    })
                    delay += 0.03
                }
                if cell.toDoItem === toDoItem {
                    startAnimating = true
                    cell.hidden = true
                }
            }
            
            //Animate the remove of the row.
            self.tableView.beginUpdates()
            let indexPathForRow = NSIndexPath(forRow: index!, inSection: 0)
            self.tableView.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: .Fade)
            self.tableView.endUpdates()
        }
    }
    
    func cellDidBeginEditing(editingCell: TableViewCell) {
        let editingOffset = tableView.contentOffset.y - editingCell.frame.origin.y as CGFloat
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for cell in visibleCells {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                cell.transform = CGAffineTransformMakeTranslation(0, editingOffset)
                if cell !== editingCell { //Identity operator. Object references must not be the same.
                    cell.alpha = 0.3
                }
            })
        }
    }
    
    func cellDidEndEditing(editingCell: TableViewCell) {
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for cell in visibleCells {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                cell.transform = CGAffineTransformIdentity
                if cell !== editingCell { //Identity operator. Object references must not be the same.
                    cell.alpha = 1
                }
            })
        }
        if editingCell.toDoItem!.text == "" {
            toDoItemDeleted(editingCell.toDoItem!)
        }
    }
    
}