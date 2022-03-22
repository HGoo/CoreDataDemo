//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Николай Петров on 18.03.2022.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    // MARK: - Private Properties
    private let cellID = "cell"
    private var tasks: [Task] = []
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
    
    private func showAlerrt(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else {
                print("The text field is empty")
                return
            }
            
            //Add new task tj tasks array
            self.save(task)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        
        // Entity name
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: manageContext) else { return }
        
        // Model instance
        let task = NSManagedObject(entity: entityDescription, insertInto: manageContext) as! Task
        
        task.name = taskName
        
        do {
            try manageContext.save()
            tasks.append(task)
            self.tableView.insertRows(
                at: [IndexPath(row: self.tasks.count - 1, section: 0)],
                with: .automatic
            )
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    private func fetchdData() {
        //Запрос выборки из базы всех значений по ключу Task
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            tasks = try manageContext.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func delete(rowIndexPathAt  indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, _) in
            guard let self = self else { return }
            
            
            self.tasks.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
        return action
    }
    
    private func edit(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { _, _, _ in
            
            let alert = UIAlertController(
                title: "Do you want to edit?",
                message: "You could do so when we implemebt this functionality",
                preferredStyle: .alert
            )
            
            let edit = UIAlertAction(title: "OK", style: .default, handler: { _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else {
                    print("The text field is empty")
                    return
                }
                self.tasks[indexPath.row].name = task
                self.tableView.reloadData()
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                self.tableView.reloadData()
            }
            
            alert.addAction(edit)
            alert.addAction(cancel)
            alert.addTextField { text in
                text.text = self.tasks[indexPath.row].name
            }
            
            self.present(alert, animated: true)
            
        }
        return action
    }
    
    // MARK: - Table View Data Sourse
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let edit = self.edit(rowIndexPathAt: indexPath)
        let delete = self.delete(rowIndexPathAt: indexPath)
        let swipe = UISwipeActionsConfiguration(actions: [delete, edit])
        
        return swipe
    }
}

// MARK: - UITableViewDataSource
extension ViewController {
    @objc private func addNewTask() {
        showAlerrt(title: "New task", message: "What do you want to do?")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
