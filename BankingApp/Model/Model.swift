//
//  Model.swift
//  BankingApp
//
//  Created by User on 26.05.2023.
//

import Foundation
import RealmSwift


class Model: Object {
    @objc dynamic var timeAndDate: Date = Date()
    @objc dynamic var operation: String = ""
    @objc dynamic var target: String = ""   //Расходы: телефон или филиал банка, Пополнение: депозит
    @objc dynamic var sum: Float = 0.0
    @objc dynamic var type: String = ""     //Расход или Пополнение
    
    func saveDataToDB() {
        let realm = try! Realm()
        try! realm.write(){
            realm.add(self)
        }
    }
}

class StoredSum: Object {
    @objc dynamic var sum: Float = 0.0
    
    func saveDataToDB() {
        let realm = try! Realm()
        let collectionStoredSum = realm.objects(StoredSum.self)
        try! realm.write(){
            if !collectionStoredSum.isEmpty {
                realm.delete(collectionStoredSum[0])
            }
            realm.add(self)
        }
    }
}

protocol WorkWithOperationDelegate: AnyObject {
    var operation: String {get set}
    var delegateMainVC: TotalSumDelegate? {get set}
}

protocol TotalSumDelegate: AnyObject {
    var currentBalance: Float {get set}
}

