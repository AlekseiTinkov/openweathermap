import UIKit

final class HourlyForecastCollectionViewCell: UICollectionViewCell {
    static let identifier = "HourlyForecastCollectionCell"
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .colorBlack
        return label
    }()
    
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
        label.font = UIFont.systemFont(ofSize: 20)
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
        self.backgroundColor = .clear
        [timeLabel, dateLabel, weaterImage, tempLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            timeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor),
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            weaterImage.topAnchor.constraint(equalTo: dateLabel.bottomAnchor),
            weaterImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            weaterImage.widthAnchor.constraint(equalToConstant: 35),
            weaterImage.heightAnchor.constraint(equalToConstant: 35),
            tempLabel.topAnchor.constraint(equalTo: weaterImage.bottomAnchor),
            tempLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    func configure(_ info: HourlyForecastInfoModel) {
        self.timeLabel.text = info.time
        self.dateLabel.text = info.date
        self.weaterImage.image = UIImage(named: info.icon)
        self.tempLabel.text = info.temp
    }
    
}
