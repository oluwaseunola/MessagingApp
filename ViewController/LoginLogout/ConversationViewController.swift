
import UIKit
import FirebaseAuth
import GoogleSignIn
import JGProgressHUD


class ConversationViewController: UIViewController {

    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.message.fill"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(didTapNewConversation))
        
        view.addSubview(tableView)

        validation()
        fetchConvoData()
        
        tableView.delegate = self
        tableView.dataSource = self
        
       
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        
    }
    
    //MARK: - Components
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let tableView : UITableView = {
        
        let view = UITableView()
        
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return view
    }()
    
    private let label : UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 100, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        
        return label
    }()
    
    
    
    //MARK: - Functions
    
    private func validation(){
        
        
        
        if Auth.auth().currentUser == nil{
            
            let vc = LoginViewController()
            vc.title = "Log in"
            
            let nav = UINavigationController(rootViewController: vc)
            
            nav.modalPresentationStyle = .fullScreen
            
            present(nav, animated: false, completion: nil)
            
        }
        
        
    }
    
    private func fetchConvoData(){
        
        tableView.isHidden = false
        
    }
    
    @objc func didTapNewConversation(){
        
        let vc = NewConversationViewController()
        
        let nav = UINavigationController(rootViewController: vc)
            
        present(nav, animated: true, completion: nil)
        
        }
}



//MARK: - Extension

extension ConversationViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "Steven"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatViewController()
        
        navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    
}
