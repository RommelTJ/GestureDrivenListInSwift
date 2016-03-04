//
//  ToDoItem.swift
//  GestureDrivenListInSwift
//
//  Created by Rommel Rico on 3/4/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit

class ToDoItem: NSObject {
    //Properties
    var text: String
    var completed: Bool
    
    init(text: String) {
        self.text = text
        self.completed = false
    }
}
