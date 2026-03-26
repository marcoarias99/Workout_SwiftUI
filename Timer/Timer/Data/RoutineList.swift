//
//  RoutineList.swift
//  Timer
//
//  Created by Marco Arias on 2021-07-09.
//

import Foundation
import SwiftUI
import Combine

struct Exercise: Identifiable, Codable {
    var id = UUID()
    var name: String
    var duration: Int // in seconds
    var sets: Int
    var restDuration: Int // rest between sets in seconds
}

struct Routine: Identifiable, Codable {
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

class RoutineStore: ObservableObject {
    @Published var routines: [Routine] = []
    
    private let userDefaults = UserDefaults.standard
    private let routinesKey = "SavedRoutines"
    
    init() {
        loadRoutines()
    }
    
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
    
    // Save routines to UserDefaults
    func saveRoutines() {
        do {
            let data = try JSONEncoder().encode(routines)
            userDefaults.set(data, forKey: routinesKey)
        } catch {
            print("Failed to save routines: \(error)")
        }
    }
    
    // Load routines from UserDefaults
    private func loadRoutines() {
        guard let data = userDefaults.data(forKey: routinesKey) else {
            // Load default routines if no saved data
            loadDefaultRoutines()
            return
        }
        
        do {
            routines = try JSONDecoder().decode([Routine].self, from: data)
        } catch {
            print("Failed to load routines: \(error)")
            loadDefaultRoutines()
        }
    }
    
    // Load default sample routines
    private func loadDefaultRoutines() {
        routines = [
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
        saveRoutines()
    }
    
    // Add routine and save
    func addRoutine(_ routine: Routine) {
        routines.append(routine)
        saveRoutines()
    }
    
    // Delete routine and save
    func deleteRoutines(at offsets: IndexSet) {
        routines.remove(atOffsets: offsets)
        saveRoutines()
    }
    
    // Move routine and save
    func moveRoutines(from source: IndexSet, to destination: Int) {
        routines.move(fromOffsets: source, toOffset: destination)
        saveRoutines()
    }
}
