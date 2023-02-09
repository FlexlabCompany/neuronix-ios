import UIKit

class SettingsView: UIView {
    required init?(coder: NSCoder) {fatalError("")}
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewSetup()
    }
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "info"
        label.backgroundColor = .systemBlue
        return label
    }()
    
    private func viewSetup() {
        self.backgroundColor = .systemBrown
        [infoLabel].forEach{self.addSubview($0); $0.translatesAutoresizingMaskIntoConstraints = false}
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16),
            infoLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            infoLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
            infoLabel.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}
