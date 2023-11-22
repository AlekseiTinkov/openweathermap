import UIKit

protocol LocationPageViewControllerProtocol {
    var pageIndex: Int { get set}
    func updatePage()
}

final class LocationPageViewController: UIViewController, LocationPageViewControllerProtocol {
    
    private var locationPageViewModel: LocationPageViewModel
    
    var pageIndex: Int
    
    private lazy var labelLocationName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .colorBlack
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var labelCurrentTemp: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 80)
        label.textColor = .colorBlack
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    init(pageIndex: Int, locationPageViewModel: LocationPageViewModel) {
        self.pageIndex = pageIndex
        self.locationPageViewModel = locationPageViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        locationPageViewModel.$weaterInfo.bind { [weak self] _ in
            guard let self = self,
                  let weaterInfo = locationPageViewModel.weaterInfo
            else { return }
            self.labelCurrentTemp.text = weaterInfo.temp
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .colorWhite
        [labelLocationName, labelCurrentTemp].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            labelLocationName.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
            labelLocationName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 58),
            labelLocationName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -58),
            labelCurrentTemp.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            labelCurrentTemp.topAnchor.constraint(equalTo: labelLocationName.bottomAnchor, constant: 20)
        ])
    }
    
    func updatePage() {
        if locations.count == 0 {
            self.labelLocationName.text = ""
            self.labelCurrentTemp.text = ""
            return
        }
        
        self.labelLocationName.text = locations[pageIndex].name
        
        locationPageViewModel.loadWeather(lat: locations[pageIndex].lat, lon: locations[pageIndex].lon)
    }
}
