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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return toDoItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TableViewCell

        //Configure the cell.
        let item = toDoItems[indexPath.row]
        //cell.textLabel?.text = item.text
        //cell.textLabel?.backgroundColor = UIColor.clearColor() //Setting background to clear so we can see gradient.
        cell.selectionStyle = .None
        cell.delegate = self
        cell.toDoItem = item

        return cell
    }
    
    //MARK: Table View Delegate
    func colorForIndex(index: Int) -> UIColor {
        //Helper method for returning a red color that is progressively greener based on its index.
        let itemCount = toDoItems.count - 1
        let val = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = colorForIndex(indexPath.row)
    }

}

//MARK: Table View Cell Delegate
extension TableViewController: TableViewCellDelegate {

    func toDoItemDeleted(toDoItem: ToDoItem) {
        let index = toDoItems.indexOf(toDoItem)
        if index != nil {
            //Found the item in the array, so remove it.
            toDoItems.removeAtIndex(index!)
            self.tableView.beginUpdates()
            let indexPathForRow = NSIndexPath(forRow: index!, inSection: 0)
            self.tableView.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.endUpdates()
        }
    }

}
