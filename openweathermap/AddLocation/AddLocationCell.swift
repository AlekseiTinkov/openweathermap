import UIKit

final class AddLocationCell: UITableViewCell {
    
    static let identifier = "AddLocationCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .colorWhite
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(location: LocationModel) {
        textLabel?.text = location.name
        detailTextLabel?.text = location.countryAndState
    }
    
}
