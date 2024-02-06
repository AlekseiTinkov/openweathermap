import UIKit

final class DailyForecastTableViewCell: UITableViewCell {
    static let identifier = "DailyForecastTableCell"
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .colorBlack
        return label
    }()
    
    private var weaterImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var tempLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .colorBlack
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func setupCell() {
        self.backgroundColor = .clear
        [dateLabel, weaterImage, tempLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            weaterImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            weaterImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -150),
            weaterImage.widthAnchor.constraint(equalToConstant: 50),
            weaterImage.widthAnchor.constraint(equalToConstant: 50),
            tempLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tempLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    func configure(_ info: DailyForecastInfoModel) {
        self.dateLabel.text = info.date
        self.weaterImage.image = UIImage(named: info.icon)
        self.tempLabel.text = info.temp
    }
    
    
}
