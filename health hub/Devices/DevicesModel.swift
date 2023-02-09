import CoreBluetooth

class DevicesModel: NSObject {
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    //мб создать структуру + перечисление доступных устройств
    
    private var transferCharacteristic: CBCharacteristic!
    var centralManager: CBCentralManager!
    private var service: CBService!
    var discoveredDevices: [CBPeripheral] = []
    var viewDelegate: DevicesViewDelegate?
}
    

extension DevicesModel: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
       /* print("Central state update")
        if central.state == .poweredOn {
           central.scanForPeripherals(withServices: nil, options: nil)
           print("Scanning...")
        } else {print("not powered")}*/
        
        
        switch central.state {
        case .poweredOn:
            central.scanForPeripherals(withServices: nil, options: nil)
            print("Scanning")
            viewDelegate?.updateLabel(with: "Поиск совместимых устройств")
        case .poweredOff:
            print("BT is off")
            viewDelegate?.updateLabel(with: "BlueTooth отключен на устройстве")
        case .resetting:
            print("resetting(?)")
            viewDelegate?.updateLabel(with: "связь с устройством потеряна(?)")
        case .unauthorized:
            print("BT unauthorized")
            viewDelegate?.updateLabel(with: "Использование BlueTooth запрещено пользователем")
        case .unsupported:
            print("BT is unsupported")
            viewDelegate?.updateLabel(with: "BlueTooth LE не поддерживается на данном устройстве")
        case .unknown:
            print("unknown state")
            viewDelegate?.updateLabel(with: "Неизвестная ошибка BLE")
        default:
            print("they added a new state")
            viewDelegate?.updateLabel(with: "new state added")
        }
        
        
    }
    
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        
        guard peripheral.name != nil else {return}
        let names = discoveredDevices.map{$0.name}
            if peripheral.name!.contains("GlucoM-") {
                if (!names.contains(peripheral.name)){
                    print("discovered", peripheral.discoverServices(nil))
                    discoveredDevices.append(peripheral)
                    viewDelegate?.tableRefresh()
                    viewDelegate?.connectToDevice()
                }
            }

    }
    
    //---------------------------------------------------

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("fail, ", error ?? "actually no")
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Device Connected")
        viewDelegate?.pushGlucoController()
        viewDelegate?.updateLabel(with: "Подключение к устройству")
        self.centralManager.stopScan()
    }
    
//-------------------------------------------------------------------
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        discoveredDevices.removeAll(where: {$0 == peripheral})
        print("disconnected")
        viewDelegate?.tableRefresh() // перенести в момент, где он теряет его
    }
    
}

protocol DevicesViewDelegate: AnyObject {
    func updateLabel(with info: String)
    func tableRefresh()
    func connectToDevice()
    func pushGlucoController()
}

