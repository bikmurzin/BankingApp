//
//  HistoryOperationVC.swift
//  BankingApp
//
//  Created by User on 27.05.2023.
//

import UIKit
import RealmSwift

class HistoryOperationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let realm = try! Realm()
    let model = Model()
    var dataArray = [Model]()
    func getDataDB() {
        let collectionModel = realm.objects(Model.self)
        if collectionModel.isEmpty {
            return
        }
        for i in 0..<collectionModel.count{
            if collectionModel[i].type == "Расход"{
                dataArray.append(collectionModel[i])
            }
        }
        for i in 0..<collectionModel.count{
            if collectionModel[i].type == "Пополнение"{
                dataArray.append(collectionModel[i])
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: "HistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "HistoryTableViewCell")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell else {return UITableViewCell()}
        let collectionModel = realm.objects(Model.self)
        if !dataArray.isEmpty {
            cell.operationTypeLabel.text = dataArray[indexPath.row].type
            cell.operationNameLabel.text = dataArray[indexPath.row].target
            cell.sumLabel.text = String(dataArray[indexPath.row].sum)
            let formatter = DateFormatter()
            // initially set the format based on your datepicker date / server String
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = formatter.string(from: dataArray[indexPath.row].timeAndDate)
            cell.dateLabel.text = date
            cell.layer.borderWidth = 3
            cell.layer.cornerRadius = cell.layer.bounds.height / 4.5
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.backgroundColor = .black
        getDataDB()
    }
}
