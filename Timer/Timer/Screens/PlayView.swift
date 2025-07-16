//
//  PlayView.swift
//  Timer
//
//  Created by Marco Arias on 2021-07-13.
//

import SwiftUI

struct PlayView: View {
    @ObservedObject var routineStore: RoutineStore
    @State private var currentExerciseIndex: Int = 0
    @State private var currentSet: Int = 1
    @State private var timeLeft: Int = 0
    @State private var isRunning: Bool = false
    @State private var timer: Timer?
    @Environment(\.presentationMode) var presentationMode
    
    var currentRoutine: Routine? {
        routineStore.getTodaysRoutine()
    }
    
    var currentExercise: Exercise? {
        guard let routine = currentRoutine,
              currentExerciseIndex < routine.exercises.count else { return nil }
        return routine.exercises[currentExerciseIndex]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.orange, .black]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Exercise Name
                Text(currentExercise?.name ?? "Exercise Name")
                    .bold()
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.vertical)
                
                // Set indicator
                if let exercise = currentExercise {
                    Text("Set \(currentSet) of \(exercise.sets)")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom, 20)
                }
                
                Spacer().frame(height: 100)
                
                // Timer Display
                Text(formatTime(timeLeft))
                    .font(.system(size: 100, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()
                    .onAppear {
                        setupTimer()
                    }
                
                Spacer().frame(height: 100)
                
                // Controls
                HStack {
                    Button(action: previousExercise) {
                        BasicButton(buttonText: "chevron.backward.2")
                    }
                    .disabled(currentExerciseIndex == 0)
                    
                    Button(action: toggleTimer) {
                        BasicButton(buttonText: isRunning ? "pause.circle.fill" : "play.circle.fill")
                    }
                    .padding(.horizontal, 50)
                    
                    Button(action: nextExercise) {
                        BasicButton(buttonText: "chevron.forward.2")
                    }
                    .disabled(currentRoutine == nil || currentExerciseIndex >= (currentRoutine?.exercises.count ?? 0) - 1)
                }
                
                // Progress indicator
                if let routine = currentRoutine {
                    Text("Exercise \(currentExerciseIndex + 1) of \(routine.exercises.count)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 20)
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onDisappear {
            stopTimer()
        }
    }
    
    func setupTimer() {
        if let exercise = currentExercise {
            timeLeft = exercise.duration
        }
    }
    
    func toggleTimer() {
        if isRunning {
            stopTimer()
        } else {
            startTimer()
        }
        isRunning.toggle()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                // Time's up for this set
                stopTimer()
                isRunning = false
                
                // Check if there are more sets
                if let exercise = currentExercise, currentSet < exercise.sets {
                    currentSet += 1
                    timeLeft = exercise.duration
                } else {
                    // Move to next exercise or finish
                    nextExercise()
                }
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func nextExercise() {
        guard let routine = currentRoutine else { return }
        
        if currentExerciseIndex < routine.exercises.count - 1 {
            currentExerciseIndex += 1
            currentSet = 1
            setupTimer()
        } else {
            // Workout complete
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func previousExercise() {
        if currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
            currentSet = 1
            Task {
                await setupTimer()
            }
        }
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
}

struct BasicButton: View {
    let buttonText: String
    
    var body: some View {
        Image(systemName: buttonText)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .frame(width: 60, height: 60)
    }
}

#Preview {
    PlayView(routineStore: RoutineStore())
}
