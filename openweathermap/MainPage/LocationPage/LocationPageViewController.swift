import UIKit
import ProgressHUD

protocol LocationPageViewControllerProtocol {
    var locationId: UUID? { get }
    func updatePage()
}

final class LocationPageViewController: UIViewController, LocationPageViewControllerProtocol {
    
    private var locationPageViewModel: LocationPageViewModel
    private let mainPageViewController: MainPageViewControllerProtocol
    
    var locationId: UUID? {
        didSet {
            updatePage()
        }
    }
    
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
    
    private lazy var hourlyForecastCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.register(HourlyForecastCollectionViewCell.self, forCellWithReuseIdentifier: HourlyForecastCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private lazy var dailyForecastTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .colorWhite
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .colorGray
        tableView.register(DailyForecastTableViewCell.self, forCellReuseIdentifier: DailyForecastTableViewCell.identifier)
        return tableView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .colorBlack
        label.backgroundColor = .colorWhite
        label.text = "Tap to add a new location".localized
        label.numberOfLines = 0
        label.textAlignment = .center
        
        label.isUserInteractionEnabled = true
        let guestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapPlaceholderLabel))
        label.addGestureRecognizer(guestureRecognizer)
        
        label.isHidden = true
        return label
    }()
    
    init(locationId: UUID?, locationPageViewModel: LocationPageViewModel, mainPageViewController: MainPageViewControllerProtocol) {
        self.locationId = locationId
        self.locationPageViewModel = locationPageViewModel
        self.mainPageViewController = mainPageViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        locationPageViewModel.$currentWeatherInfo.bind { [weak self] _ in
            guard let self = self,
                  let currenWeaterInfo = locationPageViewModel.currentWeatherInfo
            else { return }
            self.currentTempLabel.text = currenWeaterInfo.temp
            self.currentWeaterImage.image = UIImage(named: currenWeaterInfo.icon)
            self.currentWeatherLabel.text = currenWeaterInfo.description
            self.feelsLikeLabel.text = currenWeaterInfo.feelsLike
        }
        
        locationPageViewModel.$hourlyForecastInfo.bind { [weak self] _ in
            guard let self = self else { return }
            self.hourlyForecastCollectionView.backgroundColor = locationPageViewModel.hourlyForecastInfo.isEmpty ? .clear : .colorGray
            self.hourlyForecastCollectionView.reloadData()
        }
        
        locationPageViewModel.$dailyForecastInfo.bind { [weak self] _ in
            guard let self = self else { return }
            self.dailyForecastTableView.reloadData()
        }
        
        locationPageViewModel.$isLoading.bind { [weak self] _ in
            guard let self = self else { return }
            if locationPageViewModel.isLoading {
                ProgressHUD.colorHUD = .clear
                ProgressHUD.colorAnimation = .colorBlack
                ProgressHUD.animationType = .circleStrokeSpin
                ProgressHUD.animate()
            } else {
                ProgressHUD.dismiss()
            }
        }
    }
    
    @objc
    private func didTapPlaceholderLabel() {
        let addLocationViewModel = AddLocationViewModel()
        let addLocationViewController = AddLocationViewController(addLocationViewModel: addLocationViewModel, mainPageViewController: self.mainPageViewController)
        navigationController?.pushViewController(addLocationViewController, animated: true)
    }
    
    private func setupViews() {
        view.backgroundColor = .colorWhite
        [labelLocationName, currentWeaterStackView, currentWeatherLabel, feelsLikeLabel, hourlyForecastCollectionView, dailyForecastTableView, placeholderLabel].forEach {
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
            feelsLikeLabel.topAnchor.constraint(equalTo: currentWeatherLabel.bottomAnchor, constant: 3),
            hourlyForecastCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200),
            hourlyForecastCollectionView.heightAnchor.constraint(equalToConstant: 110),
            hourlyForecastCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hourlyForecastCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            dailyForecastTableView.topAnchor.constraint(equalTo: hourlyForecastCollectionView.bottomAnchor, constant: 10),
            dailyForecastTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            dailyForecastTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            dailyForecastTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            placeholderLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            currentWeaterImage.widthAnchor.constraint(equalToConstant: 70),
            currentWeaterImage.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    func updatePage() {
        placeholderLabel.isHidden = !locations.isEmpty
        
        guard let location = locations.first(where: {$0.locationId == locationId}) else {
            return
        }
        self.labelLocationName.text = location.name
        
        locationPageViewModel.loadWeather(lat: location.lat, lon: location.lon)
    }
}

extension LocationPageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return locationPageViewModel.hourlyForecastInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HourlyForecastCollectionViewCell.identifier,
            for: indexPath
        ) as? HourlyForecastCollectionViewCell else {
            assertionFailure("Error get cell")
            return .init()
        }
        cell.configure(locationPageViewModel.hourlyForecastInfo[indexPath.row])
        return cell
    }
}

extension LocationPageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 100, height: 110)
        }
}

extension LocationPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationPageViewModel.dailyForecastInfo.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DailyForecastTableViewCell.identifier,
                                                       for: indexPath) as? DailyForecastTableViewCell
        else {
            assertionFailure("Error get cell")
            return .init()
        }
        
        if indexPath.row == locationPageViewModel.dailyForecastInfo.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        cell.configure(locationPageViewModel.dailyForecastInfo[indexPath.row])
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        cell.layer.maskedCorners = []
        
        return cell
    }
    
}

extension LocationPageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

