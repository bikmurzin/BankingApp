//
//  ViewController.swift
//  BankingApp
//
//  Created by User on 26.05.2023.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, TotalSumDelegate {
    
    @IBOutlet weak var historyView: UIView!
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var depositView: UIView!
    @IBOutlet weak var AddMoneyButton: UIButton!
    @IBOutlet weak var imageDeposit: UIImageView!
    @IBOutlet weak var cashRequestButton: UIButton!
    @IBOutlet weak var topUpPhoneButton: UIButton!
    @IBOutlet weak var expensesSumLabel: UILabel!
    
    var expensesSum: Float = 0
    weak var delegate: WorkWithOperationDelegate?
    
    var currentBalance: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm()
        let storedSum = StoredSum()
        let collectionOfStoredSum = realm.objects(StoredSum.self)
        if !collectionOfStoredSum.isEmpty {
            currentBalance = collectionOfStoredSum[0].sum
        }
        
        historyView.layer.cornerRadius = historyView.layer.bounds.height / 4.5//30
        depositView.layer.cornerRadius = depositView.layer.bounds.height / 4.5// 30
        AddMoneyButton.layer.cornerRadius = AddMoneyButton.layer.bounds.height / 4.5// 10
        cashRequestButton.layer.cornerRadius = cashRequestButton.layer.bounds.height / 4.5
        topUpPhoneButton.layer.cornerRadius = topUpPhoneButton.layer.bounds.height / 4.5
        
        balanceLabel.text = String(currentBalance)
        expensesSum = 0
        
        let collectionModel = realm.objects(Model.self)
        for i in 0..<collectionModel.count {
            if collectionModel[i].type == "Расход" {
                //минус, т.к. все расходы записаны со знаком минус
                expensesSum -= collectionModel[i].sum
            }
        }
        expensesSumLabel.text = String(expensesSum)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let realm = try! Realm()
        let storedSum = StoredSum()
        let collectionOfStoredSum = realm.objects(StoredSum.self)
        if !collectionOfStoredSum.isEmpty {
            currentBalance = collectionOfStoredSum[0].sum
        }
        balanceLabel.text = String(currentBalance)
        expensesSum = 0
        let collectionModel = realm.objects(Model.self)
        for i in 0..<collectionModel.count {
            if collectionModel[i].type == "Расход" {
                //минус, т.к. все расходы записаны со знаком минус
                expensesSum -= collectionModel[i].sum
            }
        }
        expensesSumLabel.text = String(expensesSum)
    }
    
    @IBAction func historyViewTouched(_ sender: UITapGestureRecognizer) {
        print("Touch")
        let destination = storyboard?.instantiateViewController(withIdentifier: "HistoryOperationVC") as! HistoryOperationVC
        navigationController?.pushViewController(destination, animated: true)
    }
    
    @IBAction func addMoneyBtnPressed(_ sender: UIButton) {
        let destination = storyboard?.instantiateViewController(withIdentifier: "OperationVC") as! OperationVC
        delegate = destination
        delegate?.operation = "AddMoney"
        delegate?.delegateMainVC = self
        navigationController?.pushViewController(destination, animated: true)
    }
    
    @IBAction func cashRequestBtnPressed(_ sender: UIButton) {
        let destination = storyboard?.instantiateViewController(withIdentifier: "OperationVC") as! OperationVC
        delegate = destination
        delegate?.operation = "CashRequest"
        delegate?.delegateMainVC = self
        navigationController?.pushViewController(destination, animated: true)
    }
    
    @IBAction func topUpPhoneBtnPressed(_ sender: UIButton) {
        let destination = storyboard?.instantiateViewController(withIdentifier: "OperationVC") as! OperationVC
        delegate = destination
        delegate?.operation = "TopUpPhone"
        delegate?.delegateMainVC = self
        navigationController?.pushViewController(destination, animated: true)
    }
}
