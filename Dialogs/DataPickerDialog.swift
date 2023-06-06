//
//  DataPickerDialog.swift
//  Ninox
//
//  Created by saeed on 12/05/2023.
//

import UIKit

class DataPickerDialog: MyViewController {

    
    @IBOutlet weak var dataPicker: UIPickerView!
    
    
    
    var titleOfDialog: String?
    var selectionProtocol: DataSelection?
    var datas: [String]?
    var targetAction: Int?
    
    @IBOutlet weak var lblTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initViews()
        
        self.view.isUserInteractionEnabled = true
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(ViewTap(_:)))
        self.view.addGestureRecognizer(viewTap)
    }
    
    @objc func ViewTap(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true)
    }
    
    func initViews(){
        lblTitle.text = titleOfDialog
        dataPicker.delegate = self
        dataPicker.dataSource = self
    }
    
    @IBAction func selectAction(_ sender: Any) {
        self.dismiss(animated: true)
        self.selectionProtocol?.DataSelected(selectedItemIndex: dataPicker.selectedRow(inComponent: 0), targetAction: targetAction!)
    }
    
    
    @IBAction func cancleAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
//    var titleOfDialog: String?
//    var selectionProtocol: DataSelection?
//    var datas: [String]?
//    var targetAction: Int?
    class func PresentDataPickerDialog(ViewController: UIViewController, titleOfDialog: String, selectionProtocol: DataSelection, datas: [String], targetAction: Int){
        
        let dialogStoryboard = UIStoryboard(name: "dialogStoryboard", bundle: nil)
        let dest = dialogStoryboard.instantiateViewController(withIdentifier: "dialogDataPicker") as! DataPickerDialog
        dest.targetAction = targetAction
        dest.titleOfDialog = titleOfDialog
        dest.datas = datas
        dest.selectionProtocol = selectionProtocol
        ViewController.present(dest, animated: true)
    }

}
extension DataPickerDialog: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.datas?.count ?? 0
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let data = self.datas![row]
        return data
    }
    
}
