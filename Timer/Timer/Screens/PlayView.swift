//
//  PlayView.swift
//  Timer
//
//  Created by Marco Arias on 2021-07-13.
//

import SwiftUI

struct PlayView: View {
    @ObservedObject var routineStore = RoutineStore()
    @State var currentExerciseIndex: Int = 0
    @State var currentSet: Int = 1
    @State var timeLeft: Int = 0
    @State var isRunning: Bool = false
    @State var timer: Timer?
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
        NavigationView{
            ZStack{
                LinearGradient(gradient: Gradient(colors: [.orange, .black]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack{
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
                    HStack{
                        Button(action: previousExercise,
                               label: {BasicButton(buttonText: "chevron.backward.2")})
                        
                        Button(action: toggleTimer,
                               label: {BasicButton(buttonText: isRunning ? "pause.circle.fill" : "play.circle.fill")})
                            .padding(.horizontal, 50)
                        
                        Button(action: nextExercise,
                               label: {BasicButton(buttonText: "chevron.forward.2")})
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
            setupTimer()
        }
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView()
    }
}

struct BasicButton: View {
    var buttonText: String
    var body: some View{
        Image(systemName: buttonText)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .frame(width: 60, height: 60)
    }
}
