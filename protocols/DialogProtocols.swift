//
//  DialogProtocols.swift
//  Ninox
//
//  Created by saeed on 12/05/2023.
//

import Foundation


protocol IconTypeSelection {
    func IconTypeSelected(item: IconTypeModel)
}

//protocol CustomInfoSelection {
//    func CustomInfoSelected(item: TargetCustomInfo)
//}


protocol ServiceDateSelection {
    func ServiceDateSelected(item: TargetServiceDate)
}

protocol DataSelection{
    func DataSelected(selectedItemIndex: Int, targetAction: Int)
}

protocol AddCustomInfoProtocol{
    func saveCustomInfo(title: String, Content: String)
}

protocol FlagNoteProtocol{
    func flagNoteText(note: String, indexPath: IndexPath)
}


protocol SearchFilterProtocol{
    func searchFiltered(filterModel: SearchFilterModel)
}
