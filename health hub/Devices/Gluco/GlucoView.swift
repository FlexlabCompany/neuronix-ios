import UIKit

class GlucoView: UIView {
    required init?(coder: NSCoder) {fatalError("")}
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewSetup()
    }

    let infoView: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
//        label.backgroundColor = .systemGreen
        label.text = "Поместите в прибор указательный палец и нажмите кнопку \"Начать\""
        return label
    }()

    let startButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Начать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 30)
        button.layer.cornerRadius = 16
        return button
    }()

    let progressBar: UIProgressView = {
       let bar = UIProgressView()
        bar.tintColor = .systemBlue
        bar.heightAnchor.constraint(equalToConstant: 10).isActive = true
        return bar
    }()

    let scanSelector: UISegmentedControl = {
        let selector = UISegmentedControl(items: ["Быстрое","Стандартное","Расширенное"])
        selector.selectedSegmentIndex = 1
        selector.isHidden = true
        return selector
    }()

    let resultView: UILabel = {
        let label = UILabel()
//        label.font = UIFont(name: "Helvetica", size: 100)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    let visualInstructionView = VisualInstructionView()

    func viewSetup(){
        [scanSelector, progressBar, infoView, startButton, visualInstructionView, resultView].forEach{self.addSubview($0); $0.translatesAutoresizingMaskIntoConstraints = false}
        self.backgroundColor = .systemBackground
        NSLayoutConstraint.activate([
            scanSelector.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16),
            scanSelector.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            scanSelector.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
            scanSelector.heightAnchor.constraint(equalToConstant: 30),
            
            infoView.topAnchor.constraint(equalTo: scanSelector.bottomAnchor, constant: 16),
            infoView.heightAnchor.constraint(equalToConstant: 100),
            infoView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -32),
            infoView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            visualInstructionView.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: 16),
            visualInstructionView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            visualInstructionView.widthAnchor.constraint(equalToConstant: 200),
            
            startButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            startButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
            startButton.heightAnchor.constraint(equalToConstant: 70),
            startButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            progressBar.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -46),
            progressBar.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            progressBar.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
            
            resultView.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: 16),
            resultView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            resultView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
            resultView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -16),
        ])
    }
}

class VisualInstructionView: UIView {
    required init?(coder: NSCoder) {fatalError("")}
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewSetup()
    }
    
    var dynamicConstraint: NSLayoutConstraint?
    let handView = UIImageView(image: UIImage(systemName: "hand.raised.fill")!)
    let arrowView = UIImageView(image: UIImage(systemName: "arrow.down")!)
    
    func viewSetup(){
//        self.backgroundColor = .systemRed
        arrowView.tintColor = .systemGreen
        handView.tintColor = .systemBlue
        [handView,arrowView].forEach{self.addSubview($0); $0.translatesAutoresizingMaskIntoConstraints = false}
        dynamicConstraint = arrowView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 107)
        NSLayoutConstraint.activate([
            arrowView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            arrowView.widthAnchor.constraint(equalToConstant: 30),
            arrowView.heightAnchor.constraint(equalTo: arrowView.widthAnchor),
            handView.topAnchor.constraint(equalTo: arrowView.bottomAnchor, constant: 2),
            handView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            handView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
            handView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            handView.heightAnchor.constraint(equalTo: handView.widthAnchor),
            
            dynamicConstraint!
        ])
        
    }
    
    func arrowAdjust(finger: Int){
        dynamicConstraint!.isActive = false
        if finger < 4 {
            dynamicConstraint = arrowView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 107 - 21.5 * CGFloat(finger))
        } else {
            dynamicConstraint = arrowView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 140)
        }
        dynamicConstraint!.isActive = true
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        }
    }
}
