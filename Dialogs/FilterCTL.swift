//
//  FilterCTL.swift
//  Ninox
//
//  Created by saeed on 24/05/2023.
//

import UIKit

class FilterCTL: UIViewController {

    var filterModel: SearchFilterModel?
    var fitlerProtocol: SearchFilterProtocol?
    
    
    @IBOutlet weak var sliderFilterRSSI: UISlider!
    @IBOutlet weak var btnAllFlagType: UIButton!
    @IBOutlet weak var btnGreenFlagType: UIButton!
    @IBOutlet weak var btnYellowFlagType: UIButton!
    @IBOutlet weak var btnOrangeFlagType: UIButton!
    
    @IBOutlet weak var switchCaution: UISwitch!
    @IBOutlet weak var switchWarning: UISwitch!
    @IBOutlet weak var switchIsOnGoing: UISwitch!
    
    var choosedFlagType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ///TODO
        ///set props of filter model
        ///
        
        setProps2View()
        
    }
    
    
    @IBAction func sliderActionChangeValue(_ sender: Any) {
        sliderFilterRSSI.setValue(Float(lroundf(sliderFilterRSSI.value)), animated: true)
    }
    
    
    func setProps2View(){
        if let rssiRange = filterModel?.rssiRange{
            self.sliderFilterRSSI.setValue(Float(rssiRange), animated: true)
        }else{
            self.sliderFilterRSSI.setValue(0, animated: true)
        }
        if let flagType = filterModel?.flagType{
            setFlagTypeView(state: flagType)
            choosedFlagType = flagType
        }else{
            setFlagTypeView(state: 0)
        }
        if let CE = filterModel?.cautionEnabled{
            self.switchCaution.setOn(CE, animated: true)
        }else{
            self.switchCaution.setOn(false, animated: true)
        }
        if let BW = filterModel?.batteryWarning{
            self.switchWarning.setOn(BW, animated: true)
        }else{
            self.switchWarning.setOn(false, animated: false)
        }
        if let IOG = filterModel?.isOnGoing{
            self.switchIsOnGoing.setOn(IOG, animated: true)
        }else{
            self.switchIsOnGoing.setOn(false, animated: true)
        }
        
    }
    
    func normalizeAllBtns(){
        btnAllFlagType.configuration = .plain()
        btnAllFlagType.setTitle("All", for: .normal)
        
        btnGreenFlagType.configuration = .plain()
        btnYellowFlagType.configuration = .plain()
        btnOrangeFlagType.configuration = .plain()
        
        btnGreenFlagType.setImage(UIImage(named: "flag_icon"), for: .normal)
        btnYellowFlagType.setImage(UIImage(named: "flag_icon"), for: .normal)
        btnOrangeFlagType.setImage(UIImage(named: "flag_icon"), for: .normal)
    }
    
    
    func setFlagTypeView(state: Int){
        switch state {
        case 0:
            normalizeAllBtns()
            btnAllFlagType.configuration = .tinted()
            btnAllFlagType.setTitle("All", for: .normal)
        case 1:
            normalizeAllBtns()
            btnGreenFlagType.configuration = .tinted()
            btnGreenFlagType.setImage(UIImage(named: "flag_icon"), for: .normal)
        case 2:
            normalizeAllBtns()
            btnYellowFlagType.configuration = .tinted()
            btnYellowFlagType.setImage(UIImage(named: "flag_icon"), for: .normal)
        case 3:
            normalizeAllBtns()
            btnOrangeFlagType.configuration = .tinted()
            btnOrangeFlagType.setImage(UIImage(named: "flag_icon"), for: .normal)
        default:
            print("noting happed!")
        }
    }
    
    @IBAction func allAction(_ sender: Any) {
        setFlagTypeView(state: 0)
        choosedFlagType = 0
    }
    
    @IBAction func greenAction(_ sender: Any) {
        setFlagTypeView(state: 1)
        choosedFlagType = 1
    }
    
    @IBAction func yellowAction(_ sender: Any) {
        setFlagTypeView(state: 2)
        choosedFlagType = 2
    }
    
    @IBAction func orangeAction(_ sender: Any) {
        setFlagTypeView(state: 3)
        choosedFlagType = 3
    }
    
    func getFilterModelFromViews(){
        self.filterModel?.rssiRange = Int(self.sliderFilterRSSI.value)
        self.filterModel?.flagType = self.choosedFlagType
        self.filterModel?.isOnGoing = switchIsOnGoing.isOn
        self.filterModel?.cautionEnabled = self.switchCaution.isOn
        self.filterModel?.batteryWarning = self.switchWarning.isOn
    }
    
    @IBAction func filterAction(_ sender: Any) {
        getFilterModelFromViews()
        self.fitlerProtocol?.searchFiltered(filterModel: self.filterModel!)
        self.dismiss(animated: true)
    }
    
    @IBAction func cancleAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
