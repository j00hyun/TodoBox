//
//  TaskEditorViewController.swift
//  Todobox
//
//  Created by Park JooHyun on 2020/10/06.
//

import UIKit

class TaskEditorViewController: UIViewController {
    
    @IBOutlet var titleInput: UITextField!
    @IBOutlet var textView: UITextView!
    
    /// Task 존재할 경우 nil 반환
    /// Void : 아무 내용도 없는 튜플, ()
    /* Closer
         { (파라미터들) -> 반환타입 in
            로직 구현
         }
        return type : ()?
        내부 로직이 아직 구현되지 않은 함수 같은 존재..?
     */
    var didAddHandler: ((Task) -> Void)?
    
    /// 실행시 딱 한번 초기 설정
    override func viewDidLoad() {
        print("등록 화면 초기 설정 진행중")
        super.viewDidLoad()
        /// textView 테두리 설정
        self.textView.layer.cornerRadius = 5
        self.textView.layer.borderColor = UIColor.lightGray.cgColor
        self.textView.layer.borderWidth = 1 / UIScreen.main.scale
    }
    
    /// 뷰 보여줄때마다 실행
    override func viewWillAppear(_ animated: Bool) {
        print("등록 화면 실행 전 준비")
        super.viewWillAppear(animated)
        /// becomeFirstResponder : 뷰를 띄우면서 자동으로 titleInput에 커서 위치
        self.titleInput.becomeFirstResponder()
    }
    
    /// cancel 버튼 누를 때 실행
    /// titleInput 빈칸 : 모달 닫기
    /// titleInput 빈칸 아님 : 경고창 노출
    @IBAction func cancelButtonDidTap() {
        print("등록 취소 진행 중")
        self.titleInput.resignFirstResponder()
        
        /// titleInput 빈칸일 경우 모달 제거
        if self.titleInput.text?.isEmpty == true {
            print("등록 모드 정상 종료")
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let alertController = UIAlertController(
            title: "앗!",
            message: "취소하면 작성중인 내용이 손실됩니다.\n취소하시겠어요?",
            preferredStyle: .alert
        )
        
        /// _in : return 값 없음
        let yes = UIAlertAction(title: "작성 취소", style: .destructive) { _ in
            print("등록 모드 종료")
            self.dismiss(animated: true, completion: nil)
        }
        let no = UIAlertAction(title: "계속 작성", style: .default) { _ in
            print("등록 모드 종료 취소")
            self.titleInput.becomeFirstResponder()
        }
        
        alertController.addAction(yes)
        alertController.addAction(no)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// done 버튼을 누를 경우 실행
    /// titleInput 빈칸 : 입력창 흔들기
    /// titleInput 빈칸 아님 : task 저장
    @IBAction func doneButtonDidTap() {
        print("할일 등록 진행 중")
        
        /// titleInput 빈칸일 경우 흔들기
        guard let title = self.titleInput.text, !title.isEmpty else {
            print("할일을 입력하세요")
            self.shakeTitleInput()
            return
        }
        
        self.titleInput.resignFirstResponder()
        
        let newTask = Task(title: title, note: self.textView.text)
        self.didAddHandler?(newTask)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// titleInput 입력창 흔들기
    func shakeTitleInput() {
        print("입력창 흔들기")
        UIView.animate(withDuration: 0.05, animations: { self.titleInput.frame.origin.x -= 5 }, completion: { _ in
            UIView.animate(withDuration: 0.05, animations: { self.titleInput.frame.origin.x += 10 }, completion: { _ in
                UIView.animate(withDuration: 0.05, animations: { self.titleInput.frame.origin.x -= 10 }, completion: {_ in
                    UIView.animate(withDuration: 0.05, animations: { self.titleInput.frame.origin.x += 10 }, completion: {_ in
                        UIView.animate(withDuration: 0.05, animations: { self.titleInput.frame.origin.x -= 5 })
                    })
                })
            })
        })
    }
}
