//
//  ContentView.swift
//  Timer
//
//  Created by Marco Arias on 2021-07-05.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var routineStore = RoutineStore()
    @State private var textBox: String = ""
    
    var dayarr = ["","Sunday", "Monday", "Tuesday","Wednesday","Thursday","Friday","Saturday"]
    
    // Get current day of week
    private var weekday: Int {
        Calendar.current.component(.weekday, from: Date())
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                VStack {
                    VStack {
                        Text("Calendar")
                            .frame(width: 350, height: 50, alignment: .leading)
                            .font(.system(size: 32, weight: .bold))
                        
                        TodaysWorkout(dayOfWeek: "\(dayarr[weekday])", routineStore: routineStore)
                        
                        Spacer().frame(height: 150)
                    }
                    
                    NavigationLink(destination: PlayView(routineStore: routineStore)) {
                        Text("START")
                            .font(.system(size: 32, weight: .bold))
                            .frame(width: 400, height: 80, alignment: .center)
                            .background(routineStore.getTodaysRoutine() != nil ? Color.red : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                    .disabled(routineStore.getTodaysRoutine() == nil)
                    
                    VStack {
                        HStack {
                            Text("Routines")
                                .frame(width: 300, height: 50, alignment: .leading)
                                .font(.system(size: 32, weight: .bold))
                            
                            NavigationLink(destination: AddItemView(routineStore: routineStore)) {
                                ImageButton(buttonText: "plus.circle.fill")
                            }
                        }
                        
                        TextField("Enter the new routine", text: $textBox, onCommit: {
                            addNewRoutine()
                        })
                        .frame(width: 350, height: 25)
                        
                        List {
                            ForEach(routineStore.routines) { routine in
                                RoutineRow(routineName: routine.routineName)
                            }
                            .onMove(perform: move)
                            .onDelete(perform: delete)
                        }
                        .frame(width: geo.size.width - 5, height: geo.size.height - 50, alignment: .center)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        routineStore.routines.move(fromOffsets: source, toOffset: destination)
    }
    
    func delete(at offsets: IndexSet) {
        routineStore.routines.remove(atOffsets: offsets)
    }
    
    func addNewRoutine() {
        guard !textBox.trimmingCharacters(in: .whitespaces).isEmpty else {
            return textBox = ""
        }
        let newRoutine = Routine(routineName: textBox)
        routineStore.routines.append(newRoutine)
        textBox = ""
    }
}
    
    func move(from source: IndexSet, to destination: Int) {
        routineStore.routines.move(fromOffsets: source, toOffset: destination)
    }
    func delete(at offsets: IndexSet) {
        routineStore.routines.remove(atOffsets: offsets)
    }
    
    func addNewRoutine(){
        guard !textBox.trimmingCharacters(in: .whitespaces).isEmpty else {
            return textBox = ""
        }
        let newRoutine = Routine(routineName: textBox)
        routineStore.routines.append(newRoutine)
        textBox = ""
    }
}

// Top Part
struct TodaysWorkout: View {
    let dayOfWeek: String
    let routineStore: RoutineStore
    
    var body: some View {
        VStack(alignment: .center) {
            Text(dayOfWeek)
                .font(.title2)
                .padding(.top, 5)
            
            if let todaysRoutine = routineStore.getTodaysRoutine() {
                Text(todaysRoutine.routineName.uppercased())
                    .font(.body)
                    .foregroundColor(.secondary)
                
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(todaysRoutine.exercises) { exercise in
                        Text(exercise.name)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
                .frame(width: 300, height: 100, alignment: .leading)
            } else {
                Text("No workout scheduled")
                    .font(.body)
                    .foregroundColor(.secondary)
                Text("")
                    .frame(width: 300, height: 100, alignment: .leading)
            }
        }
    }
}

//Lower Part
struct RoutineRow: View {
    let routineName: String
    
    var body: some View {
        Text(routineName)
    }
}

struct ImageButton: View {
    let buttonText: String

    var body: some View {
        Image(systemName: buttonText)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.green)
            .frame(width: 40, height: 40, alignment: .center)
    }
}

#Preview {
    ContentView()
}
