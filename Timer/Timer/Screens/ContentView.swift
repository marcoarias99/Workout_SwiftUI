//
//  ContentView.swift
//  Timer
//
//  Created by Marco Arias on 2021-07-05.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var routineStore = RoutineStore()
    @State var textBox: String = ""
    
    var dayarr = ["","Sunday", "Monday", "Tuesday","Wednesday","Thursday","Friday","Saturday"]
    
    var body: some View {
        NavigationView{ GeometryReader{ geo in
            VStack{
                VStack{
                Text("Calendar")
                    .frame(width: 350, height: 50, alignment: .leading)
                    .font(.system(size: 32, weight: .bold))
                TodaysWorkout(dayOfWeek: "\(dayarr[weekday])", routineName: "LEGS")
                Spacer().frame(height: 150)
                }
                NavigationLink(destination: PlayView(), label: {
                    Text("START")
                        .font(.system(size: 32, weight: .bold))
                        .frame(width:400, height: 80, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .background(Color.red)
                        .foregroundColor(.black)
                        .cornerRadius(20)})
                
                VStack{
                    HStack{
                        Text("Routines")
                            .frame(width: 300, height: 50, alignment: .leading)
                            .font(.system(size: 32, weight: .bold))
//                        NavigationLink(destination: AddItemView()){
//                            ImageButton(buttonText: "plus.circle.fill")}
                        Button(action: self.addNewRoutine, label: {
                            ImageButton(buttonText: "plus.circle.fill")
                        })
                    }
                    TextField("Enter the new routine", text: self.$textBox)
                        .frame(width: 350, height: 25)
                    
                    List {
                        ForEach(routineStore.routines){ routine in
                            RoutineRow(routineName: routine.routineName)}
                        .onMove(perform: self.move)
                        .onDelete(perform: self.delete)
                    }
                    .frame(width: geo.size.width - 5, height: geo.size.height - 50, alignment: .center)
            }
        }}
        .navigationBarHidden(true)}
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
struct TodaysWorkout: View{
    var dayOfWeek: String
    var routineName: String
    
    var body: some View{
        VStack(alignment: .center){
            Text(dayOfWeek)
                .font(.title2)
                .padding(.top, 5)
            Text(routineName)
                .font(.body)
                .foregroundColor(.secondary)
            Text("Raises \nPull Ups \nRun")
                .frame(width: 300, height: 100, alignment: .leading)
        }
    }
}

//Lower Part
struct RoutineRow: View{
    var routineName: String
    var body: some View{
        Text(routineName)
    }
}

struct ImageButton: View {
    var buttonText: String

    var body: some View{
        Image(systemName: buttonText)
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
