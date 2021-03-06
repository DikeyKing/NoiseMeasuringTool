//
//  ViewController.swift
//  NoiseMeasuringTool
//
//  Created by Dikey on 2021/7/30.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var dbLabel: UILabel!
    
    let dbTool:NoiseMeasuringTool = NoiseMeasuringTool.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbTool.delegate = self
    }

    @IBAction func start(_ sender: UIButton) {
        dbTool.startMeasuring()
    }
    
    @IBAction func stop(_ sender: UIButton) {
        dbTool.stopMeasuring()
    }

}

extension ViewController:NoiseMeasuringToolDelegate{
    
    func audioPowerChanged(tool:NoiseMeasuringTool, db:Float){
        self.dbLabel.text = "\(Int(db)) dB"
        self.progress.progress = tool.powerPercentage
    }
}
