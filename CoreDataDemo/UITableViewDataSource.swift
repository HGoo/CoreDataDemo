//
//  UITableViewDataSource.swift
//  CoreDataDemo
//
//  Created by Николай Петров on 22.03.2022.
//

import Foundation
import UIKit

// MARK: - UITableViewDataSource
extension ViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(tasks.count)
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        let task = tasks[indexPath.row]
        content.text = task.name
        cell.contentConfiguration = content
        
        return cell
    }
    
}
