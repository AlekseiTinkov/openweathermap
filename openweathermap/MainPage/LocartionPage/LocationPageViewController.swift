import UIKit
import Kingfisher

protocol LocationPageViewControllerProtocol {
    var locationId: UUID? { get }
    func updatePage()
}

final class LocationPageViewController: UIViewController, LocationPageViewControllerProtocol {
    
    private var locationPageViewModel: LocationPageViewModel
    
    var locationId: UUID?
    
    private lazy var labelLocationName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .colorBlack
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let currentWeaterStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        return stackView
    }()
    
    private lazy var currentTempLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 60)
        label.textColor = .colorBlack
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private var currentWeaterImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var currentWeatherLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .colorBlack
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var feelsLikeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .colorBlack
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    init(locationId: UUID?, locationPageViewModel: LocationPageViewModel) {
        self.locationId = locationId
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
            self.currentTempLabel.text = weaterInfo.temp
            self.currentWeaterImage.kf.setImage(with: URL(string: weaterInfo.icon))
            self.currentWeatherLabel.text = weaterInfo.description
            self.feelsLikeLabel.text = weaterInfo.feelsLike
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .colorWhite
        [labelLocationName, currentWeaterStackView, currentWeatherLabel, feelsLikeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        [currentTempLabel, currentWeaterImage].forEach {
            currentWeaterStackView.addArrangedSubview($0)
        }
        NSLayoutConstraint.activate([
            labelLocationName.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
            labelLocationName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 58),
            labelLocationName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -58),
            currentWeaterStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            currentWeaterStackView.topAnchor.constraint(equalTo: labelLocationName.bottomAnchor, constant: 20),
            currentWeatherLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            currentWeatherLabel.topAnchor.constraint(equalTo: currentWeaterStackView.bottomAnchor, constant: 3),
            feelsLikeLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            feelsLikeLabel.topAnchor.constraint(equalTo: currentWeatherLabel.bottomAnchor, constant: 3)
        ])
    }
    
    func updatePage() {
        guard let location = locations.first(where: {$0.id == locationId}) else {
            self.labelLocationName.text = ""
            self.currentTempLabel.text = ""
            return
        }
    
        self.labelLocationName.text = location.name
        
        locationPageViewModel.loadWeather(lat: location.lat, lon: location.lon)
    }
}
