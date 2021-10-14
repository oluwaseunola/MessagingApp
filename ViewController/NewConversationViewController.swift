//
//  NewConversationViewController.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-09-23.
//

import UIKit

class NewConversationViewController: UIViewController {
    
    //MARK: - Properties
    
    private var allUsers : [[String:Any]] = []
    private var results : [[String:Any]] = []
    public var completion : (([String:Any])->Void)?
    
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
        
        configureNav()
        view.addSubview(tableView)
        view.addSubview(label)
        
        configureTableView()
        
        fetchUsers()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        label.frame = CGRect(x: 0, y: (view.height-50)/2, width: view.width, height: 50)
    }
    
    //MARK: - Functions
    
    private func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        tableView.register(SearchViewTableViewCell.self, forCellReuseIdentifier: SearchViewTableViewCell.identifier)
        label.isHidden = true
    }
    
    private func configureNav(){
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.close, target: self, action: #selector(didTapClose))
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        
        
    }
    
    private func fetchUsers(){
        
        DatabaseManager.shared.fetchAllUsers { [weak self] users in
            
            self?.allUsers = users
            
        }
        
    }
    
    
    private func filterUsers(query: String){
        
        self.results.removeAll()
        
        let results =  self.allUsers.filter({guard let name = $0["userFirstName"] as? String else{return false}
            
            return name.lowercased().hasPrefix(query)})
        
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchViewTableViewCell.identifier, for: indexPath) as? SearchViewTableViewCell else{return UITableViewCell()}
        
        cell.configureCell(model: results[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = results[indexPath.row]
        self.dismiss(animated: true) {
            
            self.completion?(result)
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {return}
        
        filterUsers(query: text.lowercased())
        
        updateUI()
        
    }
}
