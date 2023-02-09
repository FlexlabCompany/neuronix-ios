import CoreBluetooth
class GlucoModel: NSObject {
    
    init(device: CBPeripheral?) {
        self.device = device
        super.init()
        self.device?.delegate = self
        self.device?.discoverServices([serviceUuid])
        
        //DEBUG
        networkSetup()
    }
    

    // BT
    var scanMode: Int = 1
    let serviceUuid = CBUUID(string: "49535343-FE7D-4AE5-8FA9-9FAFD205E455")
    let characteristicUuid = CBUUID(string: "49535343-1e4d-4bd9-ba61-23c647249616")
    let device: CBPeripheral?
    var service: CBService?
    var characteristic: CBCharacteristic?
    let startMessage = Data.init(_: [0xFF,0x55,0x06,0x00,0x14,0xFF,0x72,0x1E])
    let endMessage = Data.init(_: [0xFF,0x55,0x05,0x00,0x15,0x65,0xF8])
    var viewDelegate: GlucoViewDelegate?
    var serialNumber: Data {get {("D88039FD" + Array(device?.name! ?? "debug_device")[7...10]).data(using: .ascii)!}}
    // Network
    let zero = Data(count: 1)
    var fingersCount: Data {get {Data.init([UInt8(2 * scanMode + 1)])}}
    var fingerNum = 0       // 0 - указательный, 4 - большой
    var inputStream: InputStream!
    var outputStream: OutputStream!
    private var url = URL(string: "prbot.brainbeat.ru")!
    private var port: UInt32 = 5055
    var running = false
    var serialMessage: Data {get {Data(_:[0x1c,0x00]) + "BIXXI_SERIAL".data(using: .ascii)! + zero + serialNumber + zero}}
    var countMessage: Data {get {Data(_:[0x11,0x00]) + "FINGERS_COUNT".data(using: .ascii)! + zero + fingersCount}}
    var messageStub: Data {get {("FINGER_" + String(fingerNum)).data(using: .ascii)! + zero}}

    
    func firstScanInitiated(){
        send(data: serialMessage)
        send(data: countMessage)
        startScan()
    }
    

    
    func startScan(){
        print("start")
        device?.setNotifyValue(true, for: characteristic!)
        device?.writeValue(startMessage, for: characteristic!, type: .withoutResponse)
    }
    
    func stopScan(){
        print("stop")
        device?.writeValue(endMessage, for: characteristic!, type: .withoutResponse)
        if fingerNum < (scanMode * 2) {
            fingerNum += 1
            viewDelegate?.prepareToContinue(finger: fingerNum)
        }
    }
}


// MARK: BT--------------------------------
extension GlucoModel: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("service")
        service = peripheral.services![0]//unsafe
        peripheral.discoverCharacteristics([characteristicUuid], for: service!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        self.characteristic = service.characteristics![0]//unsafe
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic.value != nil else {print ("no value"); return}
        let message = Data(_: [UInt8(Array(characteristic.value!).count + 12),0]) + messageStub + characteristic.value! + zero
        send(data: message)
    }
}



//MARK: NET------------------------------------
extension GlucoModel: StreamDelegate {

    
    func send(data: Data){
//        print("sending ", Array(data))
        data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                print("error sending")
                return
            }
            outputStream.write(pointer, maxLength: data.count)
        }
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            print("data from server received")
            readFromServer(stream: aStream as! InputStream)
        case .openCompleted:
            print("opened")
        case .endEncountered:
            print("stream ended")
        case .errorOccurred:
            print("error occurred")
            //обработать отказ сети
        case .hasSpaceAvailable:
            print("has space available")
        default:
            print("unknown event")
        }
    }
    
    //MARK: - чтение и парс ответа с сервера
    func readFromServer(stream: InputStream) {
        var buffer = Array<UInt8>(repeating: 0, count: 21)
        var dataFromServer = Data()
        var answer: (progress: Int, presenceChance: Int, serverError: Bool) = (0, 0, false)
        inputStream.read(&buffer, maxLength: 256)
        print("пришло ", buffer)
        print(String(data: Data(buffer), encoding: .ascii)!)
        switch buffer[0] {
        case 16:
            dataFromServer = Data(_: buffer[12...15])
            answer.progress = Int(String(dataFromServer[0])) ?? -1
            answer.presenceChance = Int(String(dataFromServer[2])) ?? -1
            if dataFromServer[3] != 0 {answer.serverError = true}
        case 21:
            let result = Double(bitPattern: Data(_: buffer[13...20]).withUnsafeBytes{$0.load(as: UInt64.self).littleEndian})
            viewDelegate?.finishedScan(result: result)
        default:
            answer.serverError = true
        }
        print(answer)
        guard !answer.serverError else {viewDelegate?.serverErrorOccured(); return}
        viewDelegate?.updateProgress(answer.progress, answer.presenceChance)
        if answer.progress == 100 {stopScan()}
    }
    
    func networkSetup() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (url.absoluteString as CFString), port, &readStream, &writeStream);
        outputStream = writeStream?.takeRetainedValue()
        inputStream = readStream?.takeRetainedValue()
        outputStream?.delegate = self;
        inputStream?.delegate = self;
        outputStream?.schedule(in: RunLoop.current, forMode: .common);
        inputStream?.schedule(in: RunLoop.current, forMode: .common);
        outputStream?.open()
        inputStream?.open()
    }
}

protocol GlucoViewDelegate {
    func prepareToContinue(finger: Int)
    func serverErrorOccured()
    func updateProgress(_ progress: Int, _ presence: Int)
    func finishedScan(result: Double)
}
