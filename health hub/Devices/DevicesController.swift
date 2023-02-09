import UIKit
import CoreBluetooth
class DevicesViewController: UIViewController {
    
    private let model = DevicesModel()
    private let devicesView = DevicesView()
    override func viewDidLoad() {
        view = devicesView
        devicesView.devicesTable.delegate = self
        devicesView.devicesTable.dataSource = self
        model.viewDelegate = self
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.navigationItem.title = "Устройства"
        
        //debug
//        debugButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        devicesView.devicesTable.reloadData()
    }
}

extension DevicesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.discoveredDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = model.discoveredDevices[indexPath.row].name! //unsafe, deprecated
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didselect", indexPath.row)
        connectToDevice()
    }
    
}

extension DevicesViewController: DevicesViewDelegate {
    func updateLabel(with info: String) {
        devicesView.infoLabel.text = info
    }
    func tableRefresh() {
        devicesView.devicesTable.reloadData()
    }
    func connectToDevice() {
        model.centralManager.connect(model.discoveredDevices[0], options: nil) //0 - затычка
    }
    func pushGlucoController() {
        self.navigationController?.pushViewController(GlucoViewController(device: model.discoveredDevices[0]), animated: true) //0 - затычка
    }
}


extension DevicesViewController {//debug
    @objc func debugFallthrough(){
        self.navigationController?.pushViewController(GlucoViewController(device: nil), animated: true)
    }
    func debugButton(){
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(debugFallthrough)), animated: true)
        
    }
}



