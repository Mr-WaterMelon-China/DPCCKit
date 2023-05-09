//
//  TestViewController.swift
//  DPCCDemo
//
//  Created by 李旺 on 2022/11/23.
//

import UIKit
import WebKit
import DPCCTool

class TestViewController: UIViewController {

    var dataArr = ["账号管理","筛查","清除缓存"]
    
    var tableView: UITableView = {
        let view = UITableView(frame: CGRect(origin: .zero, size: UIScreen.main.bounds.size), style: .plain)
        view.backgroundColor = .white
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTestViewController()
    }
    
    fileprivate func initTestViewController() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        navigationController?.isNavigationBarHidden = true
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension TestViewController: UITableViewDelegate,UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "TestViewControllerCell")
        cell.textLabel?.text = dataArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.row {
        case 0:
            DPCCKitManager.shared.getResult("0") { [weak self] vc in
                guard let `self` = self else { return }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case 1:
            DPCCKitManager.shared.getResult("1") { [weak self] vc in
                guard let `self` = self else { return }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 2:
            let dataStore = WKWebsiteDataStore.default()
            dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), completionHandler: { (records) in
                for record in records{
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {
                        print("清除成功\(record)")
                    })
                }
            })
        default:
            break
        }
    }
    
}
