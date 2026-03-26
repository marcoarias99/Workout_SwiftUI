//
//  AddItemView.swift
//  Timer
//
//  Created by Marco Arias on 2021-07-12.
//

import SwiftUI

struct AddItemView: View {
    @ObservedObject var routineStore: RoutineStore
    @Environment(\.presentationMode) var presentationMode
    
    //Main Form Info
    @State private var title = ""
    private let dayarr = ["Sunday", "Monday", "Tuesday","Wednesday","Thursday","Friday","Saturday"]
    @State private var day = "Sunday"
    @State private var numOfWorkouts = 1
    
    //Exercise info
    @State private var exercises: [TempExercise] = [TempExercise()]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Build your Workout Routine").padding(.top)) {
                    TextField("Routine Name", text: $title)
                    Picker("Assign a Day", selection: $day) {
                        ForEach(dayarr, id: \.self) {
                            Text($0)
                        }
                    }
                    Stepper("Exercises in Routine: \(numOfWorkouts)", value: $numOfWorkouts, in: 1...10)
                        .onChange(of: numOfWorkouts) { _ in
                            updateExercises()
                        }
                }
                
                ForEach(exercises.indices, id: \.self) { index in
                    Section(header: Text("Exercise \(index + 1)")) {
                        TextField("Exercise Name", text: $exercises[index].name)
                        TextField("Duration (seconds)", text: $exercises[index].durationString)
                            .keyboardType(.numberPad)
                        Stepper("Sets: \(exercises[index].sets)", value: $exercises[index].sets, in: 1...10)
                        TextField("Rest Duration (seconds)", text: $exercises[index].restDurationString)
                            .keyboardType(.numberPad)
                    }
                }
            }
            .navigationTitle("New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel", action: cancel),
                trailing: Button("Save", action: save)
                    .disabled(title.isEmpty)
            )
        }
        .navigationBarHidden(true)
        .onAppear {
            updateExercises()
        }
    }
    
    private func updateExercises() {
        while exercises.count < numOfWorkouts {
            exercises.append(TempExercise())
        }
        while exercises.count > numOfWorkouts {
            exercises.removeLast()
        }
    }
    
    private func save() {
        // Validate input
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        let exerciseArray = exercises.map { tempEx in
            Exercise(
                name: tempEx.name.isEmpty ? "Exercise" : tempEx.name,
                duration: max(1, Int(tempEx.durationString) ?? 60),
                sets: max(1, tempEx.sets),
                restDuration: max(0, Int(tempEx.restDurationString) ?? 30)
            )
        }
        
        let newRoutine = Routine(
            routineName: title,
            dayOfWeek: day,
            exercises: exerciseArray
        )
        
        routineStore.addRoutine(newRoutine)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func cancel() {
        presentationMode.wrappedValue.dismiss()
    }
}

class TempExercise: ObservableObject {
    @Published var name: String = ""
    @Published var durationString: String = "60"
    @Published var sets: Int = 3
    @Published var restDurationString: String = "30"
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView(routineStore: RoutineStore())
    }
}
