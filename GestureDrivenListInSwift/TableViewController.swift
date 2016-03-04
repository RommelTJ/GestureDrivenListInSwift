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
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        //Configure the cell.
        let item = toDoItems[indexPath.row]
        cell.textLabel?.text = item.text

        return cell
    }

}
