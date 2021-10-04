//
//  NewConversationViewController.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-09-23.
//

import UIKit

class NewConversationViewController: UIViewController {
    
    //MARK: - Properties
    
    private var allUsers : [String] = []
    private var results : [String] = []
    
    private let searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        
        searchBar.placeholder = "Search"
        
        return searchBar
    }()
    
    private let tableView : UITableView = {
        let view = UITableView()
        
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return view
    }()
    
    private let label : UILabel = {
        let label = UILabel()
        
        label.text = "No results"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 50, weight: .bold)
        
        return label
    }()
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        searchBar.delegate = self
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.close, target: self, action: #selector(didTapClose))
        
        view.addSubview(tableView)
        view.addSubview(label)

        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        label.isHidden = true
        
        searchBar.becomeFirstResponder()
        
     fetchUsers()
    
    }
  
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        label.frame = CGRect(x: 0, y: (view.height-50)/2, width: view.width, height: 50)
    }
    
    //MARK: - Functions
    
    
    
    private func fetchUsers(){
        
        DatabaseManager.shared.fetchAllUsers { [weak self] users in
            
            self?.allUsers = users
            
        }
        
    }
    
    
    private func filterUsers(query: String){
        
        self.results.removeAll()

        let results =  self.allUsers.filter({$0.lowercased().hasPrefix(query)})
            
        self.results = results
        
        
    }
    
    private func updateUI(){
        
        if results.isEmpty{
            label.isHidden = false
            tableView.isHidden = true
            
        }else{
            
            label.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
        
        

    }
    
    
    @objc func didTapClose(){
        
        dismiss(animated: true, completion: nil)
    }
    

}

//MARK: - Extension

extension NewConversationViewController : UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = results[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {return}
        
        filterUsers(query: text.lowercased())
        
        updateUI()
         
    }
}
