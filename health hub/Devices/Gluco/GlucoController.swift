import UIKit
import CoreBluetooth

class GlucoViewController: UIViewController {
    required init?(coder: NSCoder) {fatalError("")}
    init(device: CBPeripheral?){
        model = GlucoModel(device: device)
        super.init(nibName: nil, bundle: nil)
        model.viewDelegate = self
        
        
        //debug
//        debugButton()
    }
    
    let model: GlucoModel
    let glucoView = GlucoView()
    override func viewDidLoad() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view = glucoView
        navigationItem.title = "Глюкометр"
        navigationController?.navigationBar.prefersLargeTitles = false
        glucoView.startButton.addTarget(self, action: #selector(startScan), for: .touchUpInside)
        glucoView.scanSelector.addTarget(self, action: #selector(modeSelect), for: .valueChanged)
    }
    
    @objc func startScan(){
        model.firstScanInitiated()
        glucoView.infoView.text = "Сканирование запущено, не вынимайте палец из прибора"
        glucoView.scanSelector.isEnabled = false
        glucoView.startButton.removeTarget(self, action: #selector(startScan), for: .touchUpInside)
        glucoView.startButton.addTarget(self, action: #selector(continueScan), for: .touchUpInside)
        glucoView.startButton.isHidden = true
    }
    
    @objc func modeSelect(){
        model.scanMode = glucoView.scanSelector.selectedSegmentIndex
    }
    @objc func continueScan(){

        model.startScan()
        glucoView.progressBar.progress = 0
        glucoView.infoView.text = "Сканирование запущено, не вынимайте палец из прибора"
        glucoView.startButton.isHidden = true
    }
}

extension GlucoViewController: GlucoViewDelegate {
    func finishedScan(result: Double) {
        glucoView.visualInstructionView.isHidden = true
        glucoView.infoView.text = "Сканирование завершено."
        let df = DateFormatter()
        df.dateFormat = "H:mm, dd.MM.yy"
        let answerString: NSMutableAttributedString = NSMutableAttributedString(string: "Дата:\n",
                                                                 attributes: [NSAttributedString.Key.font : UIFont(name: "Helvetica", size: 30)!])
        let datePart: NSAttributedString = NSAttributedString(string: df.string(from: Date()) + "\n\n",
                                                             attributes: [NSAttributedString.Key.font : UIFont(name: "Helvetica", size: 45)!])
        let answerPart1: NSAttributedString = NSAttributedString(string: "Результат:\n",
                                                                        attributes: [NSAttributedString.Key.font : UIFont(name: "Helvetica", size: 30)!])
        let answerPart2: NSAttributedString = NSAttributedString(string: String(format: "%.2f", result) + "\n",
                                                                 attributes: [NSAttributedString.Key.font : UIFont(name: "Helvetica", size: 100)!])
        let answerPart3: NSAttributedString = NSAttributedString(string: "mmol/l",
                                                                 attributes: [NSAttributedString.Key.font : UIFont(name: "Helvetica", size: 30)!])
        
        answerString.append(datePart)
        answerString.append(answerPart1)
        answerString.append(answerPart2)
        answerString.append(answerPart3)
        glucoView.resultView.attributedText = answerString
        glucoView.resultView.isHidden = false
        

        glucoView.startButton.isHidden = true
        glucoView.progressBar.progress = 1
        
    }
    
    func prepareToContinue(finger: Int) {// до нажатия
        var fingerName = ""
        switch finger {
        case 1: fingerName = "средний палец"
        case 2: fingerName = "безымянный палец"
        case 3: fingerName = "мезинец"
        case 4: fingerName = "большой палец"
        default: fingerName = "указательный палец"
        }
        glucoView.startButton.isHidden = false
        glucoView.infoView.text = "Вставьте " + fingerName + " в прибор и нажмите кнопку \"Продолжить\""
        glucoView.startButton.setTitle("Продолжить", for: .normal)
        glucoView.visualInstructionView.arrowAdjust(finger: finger)
    }
    
    
    func serverErrorOccured() {
        //вывести сообщение об ошибке, перезапустить для ТЕКУЩЕГО пальца
    }
    func updateProgress(_ progress: Int, _ presence: Int) {
        glucoView.progressBar.setProgress(Float(progress) / 100, animated: true)
        //обработать процент отсутствия пальца
    }
}


extension GlucoViewController {
    @objc func debugFallthrough(){
startScan()
        glucoView.progressBar.progress = 0.6
    }
    func debugButton(){
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(debugFallthrough)), animated: true)
    }
}
