//
//  SearchActionProtocols.swift
//  Ninox
//
//  Created by saeed on 22/05/2023.
//

import Foundation

protocol EditActionProtocol{
    func edited(tag: TagModel, indexPath: IndexPath)
}

protocol DeleteActionProtocol{
    func deleted(tag: TagModel, indexPath: IndexPath)
}
