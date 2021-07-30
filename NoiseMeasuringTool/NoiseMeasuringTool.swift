//
//  NoiseMeasuringTool.swift
//  NoiseMeasuringTool
//
//  Created by Dikey on 2021/7/30.
//

import Foundation
import AVFoundation

protocol NoiseMeasuringToolDelegate:AnyObject {
    
    /// audio power change callback
    /// - Parameters:
    ///   - tool: NoiseMeasuringTool
    ///   - db: db
    func audioPowerChanged(tool:NoiseMeasuringTool, db:Float)
}

class NoiseMeasuringTool:NSObject{
    
    // MARK: Public

    static let shared = NoiseMeasuringTool()
    
    /// delegate
    var delegate:NoiseMeasuringToolDelegate?

    /// if is measuring
    public private(set) var measuring:Bool = false
    
    /// from 0 to 1
    public private(set) var powerPercentage:Float = 0.0

    /// averagePower
    public private(set) var averagePower:Float = 0.0

    /// peakPower
    public private(set) var peakPower:Float = 0.0

    /// dB
    public private(set) var dB:Float = 0.0
    
    // MARK: Private

    private let kSavedAudioFileName = "tempAudioFile.caf"

    /// Use for track audio power changes
    private var timer:Timer?
    
    /// Use for audio recorder
    private var audioRecord:AVAudioRecorder?
    
    /// use for audio file save
    private var audioFilePath:URL?
    
    init(trackingInterval:Float? = 0.1) {
        
        super.init()
        
        // audio file Path
        self.audioFilePath = assignAudioFilePath()
        
        // init audio recorder
        self.audioRecord = assignAudioRecorder(filePath: self.audioFilePath)

        func assignAudioFilePath() -> URL? {
            let urlString = NSSearchPathForDirectoriesInDomains(.documentationDirectory, .userDomainMask, true).last?.appending(kSavedAudioFileName)
            assert((urlString != nil))
            if let urlString = urlString{
                let url = URL.init(fileURLWithPath: urlString)
                return url
            }
            return nil
        }

        func assignAudioRecorder(filePath:URL?)->AVAudioRecorder?{
            
            assert((filePath != nil))
            guard let filePath = filePath else {
                return nil
            }
            
            let recordSettings = [AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                    AVEncoderBitRateKey: 16,
                    AVFormatIDKey:kAudioFormatLinearPCM,
                    AVLinearPCMBitDepthKey:8,
                    AVLinearPCMIsFloatKey:true,
                    AVNumberOfChannelsKey: 2,
                    AVSampleRateKey: 8000] as [String : Any]
            
            // set audio sessiong
            do {
                try AVAudioSession.sharedInstance().setCategory(.record, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                let audioRecorder = try AVAudioRecorder(url: filePath, settings: recordSettings)
                
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
                
                return audioRecorder
            } catch {
                print(error)
            }

            return nil
        }

    }
    
    func assignTimer(trackingInterval:Float? = 0.1) -> Timer? {
        var interval:Float = 0.1
        if let trackingInterval = trackingInterval {
            interval = trackingInterval
        }
        let timer = Timer.scheduledTimer(timeInterval: TimeInterval(interval),
                                         target: self,
                                         selector: #selector(audioPowerChanged),
                                         userInfo: nil, repeats: true)
        timer.fireDate = NSDate.distantPast
        return timer
    }
    
    // MARK: audioPowerChanged

    @objc private func audioPowerChanged() {
        guard let audioRecord = self.audioRecord else {
            return
        }
        audioRecord.updateMeters()

        let averagePower = audioRecord.averagePower(forChannel: 0)
        let peakPower = audioRecord.peakPower(forChannel: 0)

        self.averagePower = averagePower
        self.peakPower = peakPower
        self.powerPercentage = (1.0 / 160.0) * (averagePower + 160.0);
        
        let power = averagePower + 160 - 50

        var dbPower:Float = 0.0
        if power < 0.0{
            dbPower = 0
        }else if power < 40.0 {
            dbPower = power * 0.875
        } else if power < 100.0 {
            dbPower = power - 15
        } else if power < 110 {
            dbPower = power * 2.5 - 165
        } else {
            dbPower = 110.0
        }
        self.dB = dbPower
        
        self.delegate?.audioPowerChanged(tool: self, db: dB)
    }
        
    // MARK: Method for measure
    
    func startMeasuring() {
        if measuring == true {
            return
        }
        measuring = true
        self.audioRecord?.record()
        
        if self.timer == nil {
            self.timer = assignTimer()
        }
    }
    
    func isMeasuring() -> Bool {
        return measuring
    }
    
    func stopMeasuring() {
        if measuring == false {
            return
        }
        measuring = false
        self.audioRecord?.stop()
        self.timer?.fireDate = NSDate.distantFuture
        self.timer?.invalidate()
        self.timer = nil
    }

}

extension NoiseMeasuringTool: AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool){
        
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?){
        print(error as Any)
    }
}
