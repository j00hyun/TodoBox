//
//  ViewController.swift
//  Todobox
//
//  Created by Park JooHyun on 2020/10/05.
//

import UIKit

let TodoboxTasksUserDefaultsKey = "TodoboxTasksUserDefaultsKey"

class TaskListViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    
    /// 할일 목록
    var tasks = [Task]() {
        /// 값이 변경된 직후에 호출
        didSet {
            self.saveAll()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// 'tasks'를 로컬에 저장
    func saveAll() {
        let data = self.tasks.map {
            [
                "title": $0.title,
                "done": $0.done,
            ]
        }
        /// UserDefaults : 데이터 저장소 [데이터,키(String)]
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: TodoboxTasksUserDefaultsKey)
        userDefaults.synchronize() /// 파일에 저장
    }
    
    func loadAll() {
        let userDefaults = UserDefaults.standard
        /// guard 조건 else { 조건이 false인경우 수행되는 구문 }
        /// object : data 불러오기
        /// as? : optional 객체로 다운캐스팅
        /// AnyObject : 모든 클래스 타입의 인스턴트 가능
        guard let data = userDefaults.object(forKey: TodoboxTasksUserDefaultsKey) as? [[String: AnyObject]] else {
            return
        }
        /// flatMap : 다차원 map 차원낮추기, compactMap : nil 제거와 같은 작업
        self.tasks = data.compactMap {
            guard let title = $0["title"] as? String else {
                return nil
            }
            let done = $0["done"]?.boolValue == true
            return Task(title: title, done: done)
        }
    }
    
    
}

// MARK: - UITableViewDataSource

extension TaskListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
}

