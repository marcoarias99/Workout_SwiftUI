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
    @State private var totalDuration: Int = 0
    @State private var isRunning: Bool = false
    @State private var timer: Timer?
    @State private var workoutComplete: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var currentRoutine: Routine? {
        routineStore.getTodaysRoutine()
    }

    var currentExercise: Exercise? {
        guard let routine = currentRoutine,
              currentExerciseIndex < routine.exercises.count else { return nil }
        return routine.exercises[currentExerciseIndex]
    }

    var progress: CGFloat {
        guard totalDuration > 0 else { return 1 }
        return CGFloat(timeLeft) / CGFloat(totalDuration)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            if workoutComplete {
                workoutCompleteView
            } else if currentExercise != nil {
                mainTimerView
            } else {
                noWorkoutView
            }
        }
        .navigationBarHidden(true)
        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - Main Timer View

    private var mainTimerView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 50)

            // Exercise name
            Text(currentExercise?.name ?? "")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            // Set badge
            if let exercise = currentExercise {
                Text("Set \(currentSet) of \(exercise.sets)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
                    .padding(.top, 10)
            }

            Spacer()

            // Circular progress ring + timer
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 12)
                    .frame(width: 240, height: 240)

                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.white,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 240, height: 240)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timeLeft)

                // Timer text
                Text(formatTime(timeLeft))
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .onAppear {
                        setupTimer()
                    }
            }

            Spacer()

            // Controls
            HStack(spacing: 40) {
                Button(action: previousExercise) {
                    CircleIconButton(systemName: "chevron.backward.2", enabled: currentExerciseIndex > 0)
                }
                .disabled(currentExerciseIndex == 0)

                Button(action: toggleTimer) {
                    CircleIconButton(systemName: isRunning ? "pause.fill" : "play.fill", enabled: true, size: 70)
                }

                Button(action: nextExercise) {
                    let hasNext = currentRoutine != nil && currentExerciseIndex < (currentRoutine?.exercises.count ?? 0) - 1
                    CircleIconButton(systemName: "chevron.forward.2", enabled: hasNext)
                }
                .disabled(currentRoutine == nil || currentExerciseIndex >= (currentRoutine?.exercises.count ?? 0) - 1)
            }
            .padding(.bottom, 20)

            // Exercise progress
            if let routine = currentRoutine {
                Text("Exercise \(currentExerciseIndex + 1) of \(routine.exercises.count)")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Workout Complete View

    private var workoutCompleteView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.white)

            Text("Workout Complete!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Text("Great job!")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))

            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Text("Done")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.orange)
                    .frame(width: 160, height: 52)
                    .background(Color.white)
                    .cornerRadius(14)
            }
            .padding(.top, 10)
        }
    }

    // MARK: - No Workout View

    private var noWorkoutView: some View {
        VStack(spacing: 16) {
            Text("No workout available")
                .font(.largeTitle)
                .foregroundColor(.white)

            Text("Please add a routine for today")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))

            Button("Go Back") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.2))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top, 8)
        }
    }

    // MARK: - Timer Logic

    func setupTimer() {
        if let exercise = currentExercise {
            timeLeft = exercise.duration
            totalDuration = exercise.duration
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
                stopTimer()
                isRunning = false

                if let exercise = currentExercise, currentSet < exercise.sets {
                    currentSet += 1
                    timeLeft = exercise.duration
                } else {
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
            stopTimer()
            isRunning = false
            workoutComplete = true
        }
    }

    func previousExercise() {
        if currentExerciseIndex > 0 {
            stopTimer()
            isRunning = false
            currentExerciseIndex -= 1
            currentSet = 1
            setupTimer()
        }
    }

    func formatTime(_ seconds: Int) -> String {
        if seconds >= 3600 {
            let h = seconds / 3600
            let m = (seconds % 3600) / 60
            let s = seconds % 60
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            let m = seconds / 60
            let s = seconds % 60
            return String(format: "%d:%02d", m, s)
        }
    }
}

// MARK: - Subviews

struct CircleIconButton: View {
    let systemName: String
    let enabled: Bool
    var size: CGFloat = 52

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.38, weight: .semibold))
            .foregroundColor(enabled ? .white : .white.opacity(0.3))
            .frame(width: size, height: size)
            .background(Color.white.opacity(enabled ? 0.2 : 0.08))
            .clipShape(Circle())
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView(routineStore: RoutineStore())
    }
}
