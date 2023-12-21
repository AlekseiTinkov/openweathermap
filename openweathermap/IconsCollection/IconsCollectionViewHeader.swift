import UIKit

final class IconsCollectionViewHeader: UICollectionReusableView {
    static let identifier = "IcinsCollectionHeader"
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font =  UIFont.boldSystemFont(ofSize: 27)
        titleLabel.textColor = .colorBlack
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
