//
//  RoutineView.swift
//  Timer
//
//  Created by Marco Arias on 2021-08-17.
//

import SwiftUI

struct RoutineView: View {
    var body: some View {
        VStack{
            base(routine: "Legs", chosenDay: "Saturday")
            Spacer().frame(height: 100)
            exerRow(exercise: "run", timer: 10, sets: 2)
        }
    }
}

struct RoutineView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineView()
    }
}

struct base: View {
    @State var routine: String
    @State var chosenDay: String
    
    var body: some View{
        VStack(alignment: .leading){
            Text(chosenDay)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            Text(routine)
                .foregroundColor(Color.secondary)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 300)
    }
}

struct exerRow: View {
    @State var exercise: String
    @State var timer: Int8
    @State var sets: Int8
    
    var body: some View{
        HStack(alignment: .center){
            Text(exercise)
                .font(.title)
                .lineLimit(2)
            Text("\(timer)")
                .font(.title)
            Text("\(sets)")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
        }
    }
}
