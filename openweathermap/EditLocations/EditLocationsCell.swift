import UIKit

final class EditLocationsCell: UITableViewCell {
    
    static let identifier = "EditLocationsCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(location: LocationModel) {
        textLabel?.text = location.name
        detailTextLabel?.text = location.countryAndState
    }
    
}

