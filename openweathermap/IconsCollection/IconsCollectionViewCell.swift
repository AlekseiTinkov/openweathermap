import UIKit

final class IconsCollectionViewCell: UICollectionViewCell {
    static let identifier = "IcinsCollectionCell"
    
    private var weaterImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .colorBlack
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        [weaterImage, nameLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            weaterImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            weaterImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            weaterImage.widthAnchor.constraint(equalToConstant: 100),
            weaterImage.heightAnchor.constraint(equalToConstant: 100),
            nameLabel.topAnchor.constraint(equalTo: weaterImage.bottomAnchor),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    func configure(name: String, section: Int) {
        self.backgroundColor = section == 0 ? UIColor.white : UIColor.black
        self.nameLabel.textColor = section == 0 ? UIColor.black : UIColor.white
                
        self.weaterImage.image = UIImage(named: name)?.withRenderingMode(.alwaysOriginal)
        self.nameLabel.text = name
    }
    
    
}
