//
//  TestEveryThing.swift
//  Ninox
//
//  Created by saeed on 12/05/2023.
//

import UIKit

class TestEveryThing: UIViewController, IconTypeSelection, DataSelection {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        
        performSegue(withIdentifier: "openTest", sender: self)
        
//        let dialogStoryboard = UIStoryboard(name: "dialogStoryboard", bundle: nil)
//        let dest = dialogStoryboard.instantiateViewController(withIdentifier: "dialogDataPicker") as! DataPickerDialog
//        dest.targetAction = 1
//        dest.titleOfDialog = "Data Picker"
//        let MyTitles = ["shit", "boz", "messi", "goosale", "gavazn"]
//        dest.datas = MyTitles
//        dest.selectionProtocol = self
//        self.present(dest, animated: true)
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "t2t"{
//            let dest = segue.destination as! IconTypeDialog
//            dest.iconTypeSelection = self
//        }
        
        print(segue.identifier)
        
//        if segue.identifier == "t2t"{
//            let dest = segue.destination as! DataPickerDialog
//
//        }
    }
    
    func IconTypeSelected(item: IconTypeModel) {
        print(item.title)
    }
    
    func DataSelected(selectedItemIndex: Int, targetAction: Int) {
        print("\(selectedItemIndex) selected item with target")
    }

}
