//
//  ContentView.swift
//  Timer
//
//  Created by Marco Arias on 2021-07-05.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var routineStore = RoutineStore()

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

                        Spacer().frame(height: 20)
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

                        List {
                            ForEach(routineStore.routines) { routine in
                                RoutineRow(routineName: routine.routineName, dayOfWeek: routine.dayOfWeek)
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
        routineStore.moveRoutines(from: source, to: destination)
    }

    func delete(at offsets: IndexSet) {
        routineStore.deleteRoutines(at: offsets)
    }
}

// Top Part
struct TodaysWorkout: View {
    let dayOfWeek: String
    @ObservedObject var routineStore: RoutineStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let todaysRoutine = routineStore.getTodaysRoutine() {
                VStack(alignment: .leading, spacing: 8) {
                    Text(dayOfWeek)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)

                    Text(todaysRoutine.routineName.uppercased())
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.12))
                        .cornerRadius(6)

                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(todaysRoutine.exercises.enumerated()), id: \.offset) { index, exercise in
                            HStack(spacing: 10) {
                                Text("\(index + 1)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 22, height: 22)
                                    .background(Color.orange)
                                    .clipShape(Circle())
                                Text(exercise.name)
                                    .font(.system(size: 15))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(formatDuration(exercise.duration))
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                .padding(.horizontal, 16)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text(dayOfWeek)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    Text("No workout scheduled today")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                .padding(.horizontal, 16)
            }
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        if seconds >= 3600 {
            let h = seconds / 3600
            let m = (seconds % 3600) / 60
            return "\(h)h \(m)m"
        } else if seconds >= 60 {
            let m = seconds / 60
            let s = seconds % 60
            return s == 0 ? "\(m)m" : "\(m)m \(s)s"
        } else {
            return "\(seconds)s"
        }
    }
}

// Lower Part
struct RoutineRow: View {
    let routineName: String
    let dayOfWeek: String

    var body: some View {
        HStack {
            Text(routineName)
                .font(.system(size: 16))
            Spacer()
            if !dayOfWeek.isEmpty {
                Text(dayOfWeek)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
