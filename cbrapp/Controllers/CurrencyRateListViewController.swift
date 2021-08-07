//
//  ViewController.swift
//  cbrapp
//
//  Created by Nikita Fedorenko on 04.08.2021.
//

import UIKit

class CurrencyRateListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var records: [Record] = []
    let service = CBRService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        fetch()
        
        setupNavBar()
        configureTableView()
    }
    
    @objc
    func willEnterForeground() {
        fetch()
    }
    
    func fetch() {
        service.fetch{ records in
            
            self.records = self.service.sortedByDateDesc(records: records)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

private extension CurrencyRateListViewController{
    
    func setupNavBar() {
        navigationItem.title = String(GlobalSettings.currentRate)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
    }
}

extension CurrencyRateListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String(format: "%.4f", records[indexPath.row].value)
        cell.detailTextLabel?.text = records[indexPath.row].date.getFormattedDate(format: "dd.MM.yyyy")
        return cell
    }
}

