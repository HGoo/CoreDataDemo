//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Николай Петров on 18.03.2022.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    var tasks: [Task] = []
    let cellID = "cell"
    
    // MARK: - Private Properties
    private let manageContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var isEditingMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        // Table view cell register
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchdData()
    }
    
    /// Setup view
    // MARK: - Private Methods
    private func setupView(){
        view.backgroundColor = .white
        setupNavigationBar()
    }
    
    /// Setup navigation bar
    private func setupNavigationBar() {
        
        // Set title for navigation bar
        navigationItem.title = "Tasks List"
        
        
        // Navihation bar color
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(
            displayP3Red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        // Title
        navigationController?.navigationBar.prefersLargeTitles = true
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Add button navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
    }
    
    @objc private func addNewTask() {
        showAlerrt(title: "New task", message: "What do you want to do?")
    }
    
}

// MARK: -  Add swipe and tap action
extension ViewController {
    private func delete(rowIndexPathAt  indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            
            let task = self.tasks[indexPath.row]
            self.deleteTask(task, indexPath: indexPath)
            
        }
        return action
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let task = tasks[indexPath.row]
        
            showAlerrt(title: "Do you want to edit?",
                        message: "You could do so when we implemebt this functionality",
                        currentTask: task) { (newValue) in

                tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = self.delete(rowIndexPathAt: indexPath)
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        
        return swipe
    }
}

// MARK: - Work id DataBase
extension ViewController {
    private func fetchdData() {
        //Запрос выборки из базы всех значений по ключу Task
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            tasks = try manageContext.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func saveTask(_ taskName: String) {
        // Entity name
        guard let entityDescription = NSEntityDescription.entity(
            forEntityName: "Task",
            in: manageContext
        ) else { return }
        
        // Model instance
        let task = NSManagedObject(entity: entityDescription,
                                   insertInto: manageContext) as! Task
       
        task.name = taskName
        
        do {
            try manageContext.save()
            tasks.append(task)
            tableView.insertRows(at: [IndexPath(row: tasks.count - 1, section: 0)],
                                 with: .automatic)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func editTASK(_ task: Task, newName: String) {
        
        do {
            task.name = newName
            try manageContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func deleteTask(_ task: Task, indexPath: IndexPath) {
        
        manageContext.delete(task)
        
        do {
            try manageContext.save()
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}


extension ViewController {
    private func showAlerrt(title: String,
                            message: String,
                            currentTask: Task? = nil,
                            completion: ((String) -> ())? = nil) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        // Save Action
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            
            
            guard let newValue = alert.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            
            // Edit current task or add new task
            currentTask != nil ? self.editTASK(currentTask!, newName: newValue) : self.saveTask(newValue)
            if completion != nil { completion!(newValue) }
            
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel",
                                   style: .destructive) { _ in
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
        if currentTask != nil {
            alert.textFields?.first?.text = currentTask?.name
        }
    }
}
