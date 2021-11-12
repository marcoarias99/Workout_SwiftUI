//
//  CurrentCalender.swift
//  Timer
//
//  Created by Apple on 06/08/2021.
//
import Foundation

let date = Date()
let calendar = Calendar.current

let  day = calendar.component(.day, from: date)
let  weekday = calendar.component(.weekday, from: date)

class UserModel: Identifiable {
    public var id: Int64 = 0
    public var routinetype:String = ""
    public var day: String = ""
    public var excerName: String = ""
    public var time: String = ""
}


class RoutineModel: Identifiable {
    public var id:Int64 = 0
    public var routineName:String = ""
}


