//
//  RxTableViewController.swift
//  LearnRxSwift
//
//  Created by Chu Guimin on 17/1/18.
//  Copyright © 2017年 e-inv. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxTableViewController: UITableViewController {
    
    private let disposeBag = DisposeBag()
    
    let dataSource = Variable([BasicModel]())
    
    let initialValue = [
        BasicModel(name: "Jack", age: 18),
        BasicModel(name: "Tim", age: 20),
        BasicModel(name: "Andy", age: 24)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 如果继承 UITableViewController, 代理必须设置为 nil
        tableView.dataSource = nil
        tableView.delegate = nil

        dataSource.value.append(contentsOf: initialValue)
        dataSource.asObservable().bindTo(tableView.rx.items(cellIdentifier: "BasicCell", cellType: UITableViewCell.self)) { (index, element, cell) in
            cell.textLabel?.text = element.name
        }.addDisposableTo(disposeBag)
        
        tableView.rx.modelSelected(BasicModel.self).subscribe(onNext: { model in
            print(model.name)
            
            if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
            }
        }).addDisposableTo(disposeBag)
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
