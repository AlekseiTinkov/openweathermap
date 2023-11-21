import UIKit

final class AddLocationViewController: UIViewController {
    
    private var addLocationViewModel: AddLocationViewModel
    private let mainPageViewController: MainPageViewControllerProtocol
    
    private lazy var searchField: UISearchTextField = {
        let searchField = UISearchTextField()
        searchField.placeholder = "Enter location name".localized
        searchField.delegate = self
        return searchField
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .colorWhite
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .colorGray
        tableView.register(AddLocationCell.self, forCellReuseIdentifier: AddLocationCell.identifier)
        return tableView
    }()
    
    init(addLocationViewModel: AddLocationViewModel, mainPageViewController: MainPageViewControllerProtocol) {
        self.addLocationViewModel = addLocationViewModel
        self.mainPageViewController = mainPageViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title  = "Adding a location".localized
        
        setupViews()
        
        self.hideKeyboardWhenTappedAround()
        
        addLocationViewModel.$searchResult.bind { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .colorWhite
        
        [searchField, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

}

extension AddLocationViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = searchField.text else { return true }
        if query == "" { return true }
        addLocationViewModel.searchLocation(searchString: query)
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let query = searchField.text else { return }
        if query == "" { return }
        addLocationViewModel.searchLocation(searchString: query)
    }
    
}

extension AddLocationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addLocationViewModel.searchResult.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AddLocationCell.identifier, for: indexPath) as? AddLocationCell else {
            assertionFailure("Error get cell")
            return .init()
        }
        
        if indexPath.row == addLocationViewModel.searchResult.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        cell.configure(location: addLocationViewModel.searchResult[indexPath.row])
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        cell.layer.maskedCorners = []
        
        return cell
    }
    
}

extension AddLocationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = addLocationViewModel.searchResult[indexPath.row]
        let alert = UIAlertController(
            title: "",
            message: "Add".localized + " " + location.name + "?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Yes".localized, style: .default){ [weak self] _ in
            guard let self else { return }
            self.mainPageViewController.addLocation(location: location)
            navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: nil))
        present(alert, animated: true)
    }
}


