import UIKit

protocol LocationPageViewControllerProtocol {
    var pageIndex: Int { get set}
    func updatePage()
}

final class LocationPageViewController: UIViewController, LocationPageViewControllerProtocol {

    var pageIndex: Int
    
    private lazy var labelLocationName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .colorBlack
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    init(pageIndex: Int) {
        self.pageIndex = pageIndex
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .colorWhite

        setupLabelLocationName()
    }
    
    private func setupLabelLocationName() {
        labelLocationName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelLocationName)
        NSLayoutConstraint.activate([
            labelLocationName.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38) ,
            labelLocationName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 58),
            labelLocationName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    func updatePage() {
        if locations.count == 0 {
            self.labelLocationName.text = ""
        } else {
            self.labelLocationName.text = locations[pageIndex].name
        }
    }
}
