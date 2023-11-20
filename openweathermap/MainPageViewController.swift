import UIKit

var locations: [LocationModel] = []

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
        button.menu = UIMenu(children: [
            UIAction(title: "Add location".localized) { [weak self] _ in
                self?.addLocationTaped()
            },
            UIAction(title: "Delete location".localized, attributes: .destructive) { [weak self] _ in
                self?.deleteLocationTaped()
            }
        ])
        return button
    }()
    
    init() {
        self.locationPageViewController = LocationPageViewController(pageIndex: 0)
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPageControl()
        setupMenuButton()
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
        locations.remove(at: pageControl.currentPage)
        updatePageControl()
    }
    
    private func setupPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        dataSource = self
        delegate = self
        
        updatePageControl()
    }
    
    private func updatePageControl() {
        pageControl.numberOfPages = (locations.count == 1) ? 0 : locations.count
        locationPageViewController.pageIndex = pageControl.currentPage
        locationPageViewController.updatePage()
        setViewControllers([locationPageViewController], direction: .forward, animated: true, completion: nil)
    }
    
    private func setupMenuButton() {
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuButton)
        NSLayoutConstraint.activate([
            menuButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            menuButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
            menuButton.widthAnchor.constraint(equalToConstant: 32),
            menuButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func addLocation(location: LocationModel) {
        locations.append(location)
        dataSource = nil
        dataSource = self
        updatePageControl()
    }
    
}

extension MainPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? LocationPageViewControllerProtocol else { return nil }
        if locations.count < 2 { return nil }
        var pageIndex = viewController.pageIndex
        pageIndex += locations.count - 1
        pageIndex %= locations.count
        return LocationPageViewController(pageIndex: pageIndex )
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? LocationPageViewControllerProtocol else { return nil }
        if locations.count < 2 { return nil }
        var pageIndex = viewController.pageIndex
        pageIndex += 1
        pageIndex %= locations.count
        return LocationPageViewController(pageIndex: pageIndex )
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
    }
}

