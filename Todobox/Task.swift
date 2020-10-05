//
//  Task.swift
//  Todobox
//
//  Created by Park JooHyun on 2020/10/05.
//

struct Task {
    var title: String
    var note: String?
    var done: Bool = false
    
    init(title: String, note: String? = nil, done: Bool = false) {
        self.title = title
        self.note = note
        self.done = done
    }
}
