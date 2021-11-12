//
//  AddItemView.swift
//  Timer
//
//  Created by Marco Arias on 2021-07-12.
//

import SwiftUI


struct AddItemView: View {
    //Main Form Info
    @State private var title = ""
    var dayarr = ["Sunday", "Monday", "Tuesday","Wednesday","Thursday","Friday","Saturday"]
    @State private var day = "Sunday"
    @State private var numOfWorkuts = 1
    
    //Exercise info
    @State var time1 = ""
    @State private var workoutName1 = ""
    
    @State private var sec = ""
    
    @State private var workoutName = ""
    @State private var sets = 1
    
    
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("Build your  Workout Routine").padding(.top)){
                    TextField("Routine Name", text: $title)
                    Picker("Assign a Day", selection: $day){
                        ForEach(dayarr, id: \.self) {
                            Text($0)
                        } }
                    Stepper("Exercises in Routine: \(self.numOfWorkuts)", value: $numOfWorkuts, in: 1...10)
                }
                
                ForEach(0 ..< numOfWorkuts, id:\.self) { item in
                    Section(header: Text("Workout \(item+1)")){
                        TextField("Exercise Name", text: $workoutName1)
                        TextField("Timer", text: $time1)
                        Stepper("Current Sets \(sets)", value: $sets, in: 1...10)
                        
                    }
                }
            }
            .navigationTitle("New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel", action:{})
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Save", action:{})
                }
            }
            
        }.navigationBarHidden(true)
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView()
            
    }
}
