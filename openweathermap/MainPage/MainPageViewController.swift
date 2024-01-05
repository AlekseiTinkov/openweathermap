import UIKit

private let userDefaults = UserDefaults.standard
private let userDefaultsLocationsKey = "locations"

var locations: [LocationModel] = {
    guard let data = userDefaults.data(forKey: userDefaultsLocationsKey),
          let locations = try? JSONDecoder().decode([LocationModel].self, from: data) else {
        return []
    }
    return locations
}() {
    didSet {
        guard let data = try? JSONEncoder().encode(locations) else {
            assertionFailure("Error save locations")
            return
        }
        userDefaults.set(data, forKey: userDefaultsLocationsKey)
    }
}

protocol MainPageViewControllerProtocol {
    func addLocation(location: LocationModel)
    func updatePageControl(pageInc: Int)
}

final class MainPageViewController: UIPageViewController, MainPageViewControllerProtocol {
    
    var locationPageViews: [LocationPageViewController] = []
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = locations.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .colorBlack
        pageControl.pageIndicatorTintColor = .colorGray
        return pageControl
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.tintColor = .colorBlack
        button.setImage(UIImage(named: "menu"), for: .normal)
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        SettingsVarible.shared.getUnits()
        SettingsVarible.shared.$units.bind { [weak self] _ in
            for i in 0..<locations.count {
                self?.locationPageViews[i].updatePage()
            }
        }
//        locationPageViewModel.$hourlyForecastInfo.bind { [weak self] _ in
//            guard let self = self else { return }
//            self.hourlyForecastCollectionView.backgroundColor = locationPageViewModel.hourlyForecastInfo.isEmpty ? .clear : .colorGray
//            self.hourlyForecastCollectionView.reloadData()
//        }
        
        Cache.shared.initCache(timeout: 30 * 60) // 30 minutes
        updatePageControl(pageInc: 0)
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func addLocationTaped() {
        let addLocationViewModel = AddLocationViewModel()
        let addLocationViewController = AddLocationViewController(addLocationViewModel: addLocationViewModel, mainPageViewController: self)
        navigationController?.pushViewController(addLocationViewController, animated: true)
    }
    
    func addLocation(location: LocationModel) {
        locations.append(location)
        updatePageControl(pageInc: 1)
        updateMenu()
    }
    
    private func deleteLocationTaped() {
        if locations.isEmpty { return }
        
        let alert = UIAlertController(
            title: "",
            message: "Remove".localized + " " + locations[pageControl.currentPage].name + "?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Yes".localized, style: .destructive){ [weak self] _ in
            guard let self else { return }
            locations.remove(at: pageControl.currentPage)
            locationPageViews.remove(at: pageControl.currentPage)
            updatePageControl(pageInc: -1)
            updateMenu()
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    private func editLocationsTaped() {
        let editLocationsViewController = EditLocationsViewController(mainPageViewController: self)
        navigationController?.pushViewController(editLocationsViewController, animated: true)
    }
    
    private func settingsTaped() {
        let settingsViewController = SettingsViewController()
        navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    private func setupViews() {
        [pageControl, menuButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            menuButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            menuButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
            menuButton.widthAnchor.constraint(equalToConstant: 32),
            menuButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        updateMenu()
    }
    
    func updatePageControl(pageInc: Int) {
        while locationPageViews.count < locations.count + 1 {
            let locationPageViewModel = LocationPageViewModel()
            let locationPageViewController = LocationPageViewController(locationId: nil, locationPageViewModel: locationPageViewModel, mainPageViewController: self)
            locationPageViews.append(locationPageViewController)
        }
        for locationsIndex in 0..<locations.count {
            locationPageViews[locationsIndex].locationId = locations[locationsIndex].locationId
        }
        
        pageControl.numberOfPages = (locations.count == 1) ? 0 : locations.count
        if pageInc == 0 {
            pageControl.currentPage = 0
        } else {
            if pageControl.currentPage + pageInc >= 0 { pageControl.currentPage += pageInc }
        }
        
        setViewControllers([locationPageViews[pageControl.currentPage]],
                           direction: .forward,
                           animated: true,
                           completion: nil
        )
        locationPageViews[pageControl.currentPage].updatePage()
    }
    
    private func updateMenu() {
        var deleteButtonText = "Remove".localized
        if !locations.isEmpty { deleteButtonText += " " + locations[pageControl.currentPage].name }
        let deleteButtonAttributes: UIMenuElement.Attributes = locations.isEmpty ? .disabled : .destructive
        let editButtonAttributes: UIMenuElement.Attributes = locations.isEmpty ? .disabled : UIMenuElement.Attributes()
        
        menuButton.menu = UIMenu(children: [
            UIAction(title: "Add new location".localized) { [weak self] _ in
                self?.addLocationTaped()
            },
            UIAction(title: deleteButtonText,
                     attributes: deleteButtonAttributes
                    ) { [weak self] _ in
                        self?.deleteLocationTaped()
                    },
            UIAction(title: "Edit list".localized,
                     attributes: editButtonAttributes
                    ) { [weak self] _ in
                        self?.editLocationsTaped()
                    },
            UIAction(title: "Settings".localized) { [weak self] _ in
                self?.settingsTaped()
            }
        ])
    }
    
}

extension MainPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? LocationPageViewControllerProtocol else { return nil }
        if locations.count < 2 { return nil }
        guard var pageIndex = locations.firstIndex(where: {$0.locationId == viewController.locationId}) else { return nil }
        pageIndex += locations.count - 1
        pageIndex %= locations.count
        return locationPageViews[pageIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? LocationPageViewControllerProtocol else { return nil }
        if locations.count < 2 { return nil }
        guard var pageIndex = locations.firstIndex(where: {$0.locationId == viewController.locationId}) else { return nil }
        pageIndex += 1
        pageIndex %= locations.count
        return locationPageViews[pageIndex]
    }
    
    
}

extension MainPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let viewController = pendingViewControllers.first as? LocationPageViewControllerProtocol else { return }
        viewController.updatePage()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewController = pageViewController.viewControllers?.first as? LocationPageViewController,
              let pageIndex = locations.firstIndex(where: {$0.locationId == viewController.locationId})
        else {
            return
        }
        pageControl.currentPage = pageIndex
        updateMenu()
    }
}

