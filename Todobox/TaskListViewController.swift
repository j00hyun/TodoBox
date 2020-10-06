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
    /// target : 액션을 받을 객체, action : 누를때 수행할 메서드
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonDidTap))
    
    /// 할일 목록
    var tasks = [Task]() {
        /// 값이 변경된 직후에 호출
        didSet {
            self.saveAll()
        }
    }
    
    /// viewDidLoad : 앱 실행시 단 한번만 호출
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadAll()
        self.doneButton.target = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            /// $0["done"]값이 없어도 런타임 예외 발생 안함
            let done = $0["done"]?.boolValue == true
            return Task(title: title, done: done)
        }
    }
    
    @IBAction func editButtonDidTap() {
        guard !self.tasks.isEmpty else {
            return
        }
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.tableView.setEditing(true, animated: true)
    }
    
    /// dynamic : 함수가 실행될 때 마다 찾아서 실행 -> 성능저하
    @objc dynamic func doneButtonDidTap() {
        self.navigationItem.leftBarButtonItem = self.editButton
        self.tableView.setEditing(false, animated: true)
    }
    
}

// MARK: - UITableViewDataSource

extension TaskListViewController: UITableViewDataSource {
    
    /// 특정 section에 존재하는 table row 갯수 세기
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    /// "cell"이라는 cell이 존재하지 않을경우 생성하고, 존재한다면 cell 사용 준비 시작
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let task = self.tasks[indexPath.row]
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate
/// 테이블 뷰의 셀 재정렬, 삭제 등 편집 그 외 다양한 액션처리 관리

extension TaskListViewController: UITableViewDelegate {
    
    /// 특정 할일 완수 여부 관리
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = self.tasks[indexPath.row]
        task.done = !task.done
        self.tasks[indexPath.row] = task
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

