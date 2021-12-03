//
//  ViewController.swift
//  reminder-sample
//
//  Created by 伊藤明孝 on 2021/07/10.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    
    @IBOutlet var table: UITableView!
    
    var models = [MyReminder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        table.delegate = self
        table.dataSource = self
    }
    
    @IBAction func didTapAdd(){
        //show add vc
        //AddViewControllerをインスタンス化する
        guard  let vc = storyboard?.instantiateViewController(identifier: "add") as? AddViewController else {
            return
        }
        
        vc.title = "New Reminder"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = {
            title, body, date in
            
            DispatchQueue.main.async {
                //navigationControllerで遷移前の画面に戻る
                self.navigationController?.popToRootViewController(animated: true)
                let new = MyReminder(title: title, date: date, identifier: "id_\(title)")
                self.models.append(new)
                self.table.reloadData()
                
                //UNMutableNotificationContent()は通知する内容を表す。
                let content = UNMutableNotificationContent()
                content.title = title
                content.sound = .default
                content.body = body
                
                //UNCalendarNotificationTriggerは指定日時で通知を発信するトリガー
                let targetDate = date
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
                
                //UNNotificationRequestは通知の内容や配送のトリガーを内包する
                let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
                
                //通知関連の機能を管理する
                UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
                    if error != nil{
                        print("something went wrong")
                    }
                })
            }
        }
        //AddViewControllerに画面遷移する
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapTest(){
        //fire test notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {success, error in
            if success {
                //scheduled test
                self.scheduleTest()
            }
            else if error != nil{
                print("error occurred")
            }
        })
    }
    
    func scheduleTest() {
        let content = UNMutableNotificationContent()
        content.title = "Hello World"
        content.sound = .default
        content.body = "My long body. My long body. My long body."
        
        let targetDate = Date().addingTimeInterval(10)
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
        
        let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
            if error != nil{
                print("something went wrong")
            }
        })
    }
    
    
}


extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row].title
        let date = models[indexPath.row].date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, dd, YYYY at hh:mm a"
        cell.detailTextLabel?.text = formatter.string(from: date)
        print(models[indexPath.row].date)
        return cell
    }
}

struct  MyReminder {
    let title: String
    let date: Date
    let identifier: String
}
