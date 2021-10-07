
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
        
       listenForConvos()
       
        
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        listenForConvos()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        
    }
    
    //MARK: - Components
    
    private var conversations : [ConversationModel] = []
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let tableView : UITableView = {
        
        let view = UITableView()
        
        view.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        
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
    
    private func listenForConvos(){
        
        guard let safeEmail = UserDefaults.standard.string(forKey: "userEmail") else {return}
        
        
        DatabaseManager.shared.getAllConvos(with:safeEmail) { [weak self] result in
            switch result{
                
            case .success(let conversations):
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    private func fetchConvoData(){
        
        tableView.isHidden = false
        
    }
    
    @objc func didTapNewConversation(){
        
        let vc = NewConversationViewController()
        let nav = UINavigationController(rootViewController: vc)
        
        vc.completion = { [weak self] result in
            guard let safeName = result["userFirstName"], let safeEmail = result["userEmail"] else {return}
        
            
            
            self?.createNewConvo(userName:safeName , userEmail:safeEmail )
        }
        
        present(nav, animated: true, completion: nil)
        
    
       
        }
    
    private func createNewConvo(userName: String, userEmail: String){
        
    
        let vc = ChatViewController(chattingWithEmail: userEmail, chattingWithName: userName, convoID: nil)
        
        vc.title = userName
        vc.navigationItem.largeTitleDisplayMode = .never
    
        
        navigationController?.pushViewController(vc, animated: true)
        
            
        
        
    }
}



//MARK: - Extension

extension ConversationViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as? ConversationTableViewCell else{return UITableViewCell()}
        
        let model = conversations[indexPath.row]
       
        
        cell.configureCell(model: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let results = conversations[indexPath.row]
        
        let vc = ChatViewController(chattingWithEmail: results.chattingWithEmail, chattingWithName: results.chattingWithName, convoID: results.convoID)
        print(results.convoID)

        vc.title = results.chattingWithName
        vc.navigationItem.largeTitleDisplayMode = .never
        
    
        
        navigationController?.pushViewController(vc, animated: true)
        

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100    }
    
    
}
