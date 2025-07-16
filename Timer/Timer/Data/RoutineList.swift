//
//  RoutineList.swift
//  Timer
//
//  Created by Marco Arias on 2021-07-09.
//

import Foundation
import SwiftUI
import Observation

struct Exercise: Identifiable {
    var id = UUID()
    var name: String
    var duration: Int // in seconds
    var sets: Int
    var restDuration: Int // rest between sets in seconds
}

struct Routine: Identifiable {
    var id = UUID()
    var routineName: String
    var dayOfWeek: String
    var exercises: [Exercise]
    
    init(routineName: String, dayOfWeek: String = "", exercises: [Exercise] = []) {
        self.routineName = routineName
        self.dayOfWeek = dayOfWeek
        self.exercises = exercises
    }
}

@Observable
class RoutineStore {
    var routines: [Routine] = [
        Routine(routineName: "Legs", dayOfWeek: "Friday", exercises: [
            Exercise(name: "Raises", duration: 60, sets: 3, restDuration: 30),
            Exercise(name: "Pull Ups", duration: 45, sets: 3, restDuration: 30),
            Exercise(name: "Run", duration: 300, sets: 1, restDuration: 0)
        ]),
        Routine(routineName: "Abs", dayOfWeek: "Monday", exercises: [
            Exercise(name: "Crunches", duration: 45, sets: 3, restDuration: 20),
            Exercise(name: "Plank", duration: 60, sets: 2, restDuration: 30)
        ])
    ]
    
    // Get routine for specific day
    func getRoutineForDay(_ day: String) -> Routine? {
        return routines.first { $0.dayOfWeek.lowercased() == day.lowercased() }
    }
    
    // Get today's routine
    func getTodaysRoutine() -> Routine? {
        let today = Calendar.current.component(.weekday, from: Date())
        let dayNames = ["","Sunday", "Monday", "Tuesday","Wednesday","Thursday","Friday","Saturday"]
        let todayName = dayNames[today]
        return getRoutineForDay(todayName)
    }
}
