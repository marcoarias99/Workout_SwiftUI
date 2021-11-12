//
//  RoutineList.swift
//  Timer
//
//  Created by Marco Arias on 2021-07-09.
//

import Foundation
import SwiftUI
import Combine

struct Routine: Identifiable {
    var id = UUID()
    var routineName: String
//    var dayOfWeek: String
//    var warmUp: Int
//    var numExercises: Int
//    var exerciseName: String
    
}

class RoutineStore: ObservableObject{
    @Published var routines: [Routine] = [
        Routine(routineName: "Legs"),
        Routine(routineName: "Abs")
//        Routine(routineName: "Leg", dayOfWeek: "TUE", warmUp: 0, numExercises: 1, exerciseName: "Pull Ups"),
//        Routine(routineName: "Abs", dayOfWeek: "FRI", warmUp: 0, numExercises: 1, exerciseName: "Crunch")
    ]
}
