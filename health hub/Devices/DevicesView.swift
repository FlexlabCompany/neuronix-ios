import UIKit

class DevicesView: UIView {
    required init?(coder: NSCoder) {fatalError("")}
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewSetup()
    }

    let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let devicesTable: UITableView = {
        let table = UITableView()
//        table.backgroundColor = .systemRed
        return table
    }()
    
    private let someButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.isHidden = true
        return button
    }()
    
    let tableTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "ОБНАРУЖЕННЫЕ УСТРОЙТСВА"
        label.textColor = .systemGray3
        return label
    }()
    
    func viewSetup(){
        
        [infoLabel, devicesTable, someButton, tableTitleLabel].forEach{self.addSubview($0); $0.translatesAutoresizingMaskIntoConstraints = false}
        self.backgroundColor = .systemBackground
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16),
            infoLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            infoLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
            infoLabel.heightAnchor.constraint(equalToConstant: 50),
            
            tableTitleLabel.topAnchor.constraint(equalTo: someButton.bottomAnchor, constant: 32),
            tableTitleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            
            devicesTable.topAnchor.constraint(equalTo: tableTitleLabel.bottomAnchor, constant: 8),
            devicesTable.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            devicesTable.widthAnchor.constraint(equalTo: self.widthAnchor),
            devicesTable.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            
            someButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 16),
            someButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            someButton.heightAnchor.constraint(equalToConstant: 50),
            someButton.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -32)
        
        ])
    }
}

