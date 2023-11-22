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
}

final class MainPageViewController: UIPageViewController, MainPageViewControllerProtocol {
    
    var locationPageViewController: LocationPageViewController
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = locations.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .colorBlack
        pageControl.pageIndicatorTintColor = .colorGray
        pageControl.tag = 111
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
        let locationPageViewModel = LocationPageViewModel()
        self.locationPageViewController = LocationPageViewController(pageIndex: 0, locationPageViewModel: locationPageViewModel)
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            updatePageControl()
            updateMenu()
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: nil))
        present(alert, animated: true)
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
        delegate = self
        updatePageControl()
    }
    
    private func updatePageControl() {
        dataSource = nil
        dataSource = self
        pageControl.numberOfPages = (locations.count == 1) ? 0 : locations.count
        locationPageViewController.pageIndex = pageControl.currentPage
        locationPageViewController.updatePage()
        setViewControllers([locationPageViewController], direction: .forward, animated: true, completion: nil)
    }
    
    private func updateMenu() {
        var deleteButtonText = "Remove".localized
        if !locations.isEmpty { deleteButtonText += " " + locations[pageControl.currentPage].name }
        let deleteButtonAttributes: UIMenuElement.Attributes = locations.isEmpty ? .disabled : .destructive
        
        menuButton.menu = UIMenu(children: [
            UIAction(title: "Add new location".localized) { [weak self] _ in
                self?.addLocationTaped()
            },
            UIAction(title: deleteButtonText,
                     attributes: deleteButtonAttributes
                    ) { [weak self] _ in
                        self?.deleteLocationTaped()
                    }
        ])
    }
    
    func addLocation(location: LocationModel) {
        locations.append(location)
        updatePageControl()
        updateMenu()
    }
    
}

extension MainPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? LocationPageViewControllerProtocol else { return nil }
        if locations.count < 2 { return nil }
        var pageIndex = viewController.pageIndex
        pageIndex += locations.count - 1
        pageIndex %= locations.count
        let locationPageViewModel = LocationPageViewModel()
        return LocationPageViewController(pageIndex: pageIndex, locationPageViewModel: locationPageViewModel)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? LocationPageViewControllerProtocol else { return nil }
        if locations.count < 2 { return nil }
        var pageIndex = viewController.pageIndex
        pageIndex += 1
        pageIndex %= locations.count
        let locationPageViewModel = LocationPageViewModel()
        return LocationPageViewController(pageIndex: pageIndex, locationPageViewModel: locationPageViewModel)
    }
    
    
}

extension MainPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard var viewController = pendingViewControllers.first as? LocationPageViewControllerProtocol else { return }
        if viewController.pageIndex >= locations.count { viewController.pageIndex = 0 }
        viewController.updatePage()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewController = pageViewController.viewControllers?.first as? LocationPageViewController else { return }
        pageControl.currentPage = viewController.pageIndex
        locationPageViewController = viewController
        updateMenu()
    }
}

