//
//  OperationVC.swift
//  BankingApp
//
//  Created by User on 26.05.2023.
//
/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
}
*/

import UIKit
import RealmSwift
import Foundation

class OperationVC: UIViewController, WorkWithOperationDelegate {
    weak var delegateMainVC: TotalSumDelegate?
    
    enum KindOfOperation {
        case addMoney
        case cashRequest
        case topUpPhone
    }
    var kindOfOperation = KindOfOperation.addMoney

    var phoneNumber: String = ""
    var currentBalance: Float = 0.0
    
    var operation: String = "None"
    var sum: Float = 0.0
    var target = ""
    var date = Date()
    var type: String = ""
    
    var wrongData = "Wrong Data"
    var insufficientFunds = "Insufficient Funds"
    
    enum DataError {
        case wrongData
        case insufficientFunds
    }
    
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var operationTypeLabel: UILabel!
    @IBOutlet weak var sumTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        operationTypeLabel.text = operation
        phoneNumberTF.isHidden = true
        phoneNumberLabel.isHidden = true

        operationSelection()
        navigationItem.title = operation
        
        confirmBtn.layer.cornerRadius = confirmBtn.layer.bounds.height / 4.5// 10
        
        phoneNumberTF.keyboardType = .phonePad
        sumTF.keyboardType = .decimalPad
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        guard let unwrpCurrentSum = delegateMainVC?.currentBalance else {return}
        //Получаем текущий остаток на депозите
        currentBalance = unwrpCurrentSum
        
    }
    
    func operationSelection() {
        if operation == "AddMoney" {
            operationTypeLabel.text = "Пополнение депозита"
        } else if operation == "CashRequest" {
            operationTypeLabel.text = "Запрос наличных"
        } else if operation == "TopUpPhone" {
            operationTypeLabel.text = "Пополнение телефона"
            phoneNumberTF.isHidden = false
            phoneNumberLabel.isHidden = false
        }
    }
    
    //Сохранение данных в БД
    func saveDataToDB() {
        let realm = try! Realm()
        let model = Model()
        let storedSum = StoredSum()
        let collectionOfStoredSum = realm.objects(StoredSum.self)
        
        model.timeAndDate = self.date
        model.operation = self.operation
        model.target = self.target
        model.sum = self.sum
        model.type = self.type
        storedSum.sum = self.currentBalance
        
        try! realm.write(){
            realm.add(model)
            if !collectionOfStoredSum.isEmpty {
                realm.delete(collectionOfStoredSum[0])
            }
            realm.add(storedSum)
        }
    }
    
    @IBAction func confirmBtnPressed(_ sender: UIButton) {
        guard let phoneNumberIsEmpty = phoneNumberTF.text?.isEmpty else {
            print("phone is nil")
            return
        }
        guard let sumIsEmpty = sumTF.text?.isEmpty else {
            print("sum is nil")
            return
        }
        if !phoneNumberTF.isHidden && phoneNumberIsEmpty {
            pleaseCheckData(DataError.wrongData)
            return
        }
        if sumIsEmpty {
            pleaseCheckData(DataError.wrongData)
            return
        }
        let alert = UIAlertController(title: "Подтверждение операции", message: "Вы уверены, что хотите подтвердить операцию?",preferredStyle: .alert)
        let ok = UIAlertAction(title: "Да", style: .destructive){[unowned self] action in
            if operation == "AddMoney" {
                confirmAddMoney()
            } else if operation == "CashRequest" {
                confirmCashRequest()
            } else if operation == "TopUpPhone" {
                confirmTopUpPhone()
            }
//            delegateMainVC?.currentBalance = currentBalance
            navigationController?.popToRootViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func calculateModel() -> Model {
        let model = Model()
        model.timeAndDate = Date()
        model.operation = self.operation
        switch kindOfOperation {
        case .addMoney:
            model.target = "Депозит"
            model.type = "Пополнение"
            return model
        case .cashRequest:
            model.target = "Филиал Банка"
            model.type = "Расход"
            return model
        case .topUpPhone:
            model.target = "Баланс телефона \(phoneNumber)"
            model.type = "Расход"
            return model
        }
    }
    
    func calculateStoredSum() -> StoredSum {
        let storedSum = StoredSum()
        storedSum.sum = currentBalance
        return storedSum
    }
    
    
    @objc func confirmAddMoney() {
        guard let valueSumTF = sumTF.text else {return}
        currentBalance += round(Float(valueSumTF)! * 100) / 100
        kindOfOperation = .addMoney
        let model = calculateModel()
        model.sum = round(Float(valueSumTF)! * 100) / 100
        model.saveDataToDB()
        let storeSum = calculateStoredSum()
        storeSum.saveDataToDB()
    }
    
    @objc func confirmCashRequest() {
        guard let valueSumTF = sumTF.text else {return}
        kindOfOperation = .cashRequest
        let model = calculateModel()
        if currentBalance >= Float(valueSumTF)! {
            currentBalance -= round(Float(valueSumTF)! * 100) / 100
            model.sum = -round(Float(valueSumTF)! * 100) / 100
            model.saveDataToDB()
            let storeSum = calculateStoredSum()
            storeSum.saveDataToDB()
        } else {
            pleaseCheckData(.insufficientFunds)
        }
    }
    
    @objc func confirmTopUpPhone() {
        guard let valueSumTF = sumTF.text else {return}
        kindOfOperation = .topUpPhone
        let model = calculateModel()
        phoneNumber = phoneNumberTF.text!
        if currentBalance >= Float(valueSumTF)! {
            currentBalance -= round(Float(valueSumTF)! * 100) / 100
            model.sum = -round(Float(valueSumTF)! * 100) / 100
            model.saveDataToDB()
            let storeSum = calculateStoredSum()
            storeSum.saveDataToDB()
        } else {
            pleaseCheckData(.insufficientFunds)
        }
    }
    
    // При нажатии на любое место экрана клавиатура скроется
    @objc func dismissKeyboard() {
          view.endEditing(true)
        }
    
    func pleaseCheckData(_ dataError: DataError) {
        switch dataError {
        case .wrongData:
            let alert = UIAlertController(title: "Ошибка", message: "Проверьте корректность введенных вами данных", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(ok)
            present(alert, animated: true)
        case .insufficientFunds:
            let alert = UIAlertController(title: "Ошибка", message: "Недостаточно средств на счете", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(ok)
            present(alert, animated: true)
        }
    }
}
