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
        print("메인화면 초기 설정 진행중")
        super.viewDidLoad()
        self.loadAll()
        self.doneButton.target = self
    }
    
    /// 메모리를 많이 소비할 때 경고
    override func didReceiveMemoryWarning() {
        print("메모리 과다 사용 경고")
        super.didReceiveMemoryWarning()
    }
    
    /// prepare : 뷰 컨트롤러 간 전환 시 데이터 전달
    /// TaskListView -> TaskEditView로 전환시  task 전달하기 위한 로직 넘겨주기
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("뷰 컨트롤러 전환 및 데이터 전달 준비 완료")
        /// 목적지인 해당 네비게이션 컨트롤러가 존재하는지
        if let navigationController = segue.destination as? UINavigationController,
           let taskEditorViewController = navigationController.viewControllers.first as? TaskEditorViewController {
            /// task를 append 하고 reloadData 한 후, 빈 튜플 반환
            taskEditorViewController.didAddHandler = { task in
                self.tasks.append(task)
                self.tableView.reloadData()
            }
        }
    }
    
    /// 'tasks'를 로컬에 저장
    func saveAll() {
        print("모든 할일 로컬에 저장")
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
    
    /// 로컬에 저장된 모든 'tasks' 가져와서 화면에 띄우기
    func loadAll() {
        print("로컬에 저장된 모든 할일 불러오기")
        let userDefaults = UserDefaults.standard
        /// guard 조건 else { 조건이 false인경우 수행되는 구문 }
        /// object : data 불러오기
        /// as? : optional 객체로 다운캐스팅
        /// AnyObject : 모든 클래스 타입의 인스턴트 가능
        guard let data = userDefaults.object(forKey: TodoboxTasksUserDefaultsKey) as? [[String: AnyObject]] else {
            print("할일이 존재하지 않습니다.")
            return
        }
        /// flatMap : 다차원 map 차원낮추기, compactMap : nil 제거와 같은 작업
        self.tasks = data.compactMap {
            guard let title = $0["title"] as? String else {
                print("올바르지 않은 형식의 할일이 존재합니다.")
                return nil
            }
            /// $0["done"]값이 없어도 런타임 예외 발생 안함
            /// $0["done"]값이 true or false 라면 Task 리턴
            let done = $0["done"]?.boolValue == true
            return Task(title: title, done: done)
        }
    }
    
    /// 수정하기 위해 Edit 버튼을 누르면 실행
    @IBAction func editButtonDidTap() {
        print("Edit 모드 실행")
        guard !self.tasks.isEmpty else {
            return
        }
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.tableView.setEditing(true, animated: true)
    }
    
    /// dynamic : 함수가 실행될 때 마다 찾아서 실행 -> 성능저하
    /// 수정 후 Done 버튼을 누르면 실행
    @objc dynamic func doneButtonDidTap() {
        print("Edit 모드 종료")
        self.navigationItem.leftBarButtonItem = self.editButton
        self.tableView.setEditing(false, animated: true)
    }
    
}

// MARK: - UITableViewDataSource
/// 테이블 데이터 보여주기

extension TaskListViewController: UITableViewDataSource {
    
    /// table : section -> cell - row
    /// section 안에 들어갈 table row 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    /// "cell"이라는 cell에  데이터 삽입
    /// cell 개수 만큼 실행
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// dequeueReusableCell : 현재 페이지에 나타나는 셀만 메모리 할당 (스크롤 내리면 원래 할당 된것 제거 후 다음 것 할당)
        /// "cell" : 재사용할 객체
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        /// indexPath : [section index, cell index]
        let task = self.tasks[indexPath.row]
        cell.textLabel?.text = task.title
        cell.detailTextLabel?.text = task.note
        if task.done {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
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

