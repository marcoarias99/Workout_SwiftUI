//
//  PlayView.swift
//  Timer
//
//  Created by Marco Arias on 2021-07-13.
//

import SwiftUI

struct PlayView: View {
    @State var hours: Int = 0
    @State var minutes: Int = 0
    @State var seconds: Int = 0
    @State var isPaused: Bool = true
    
    var body: some View {
        NavigationView{
            ZStack{
                LinearGradient(gradient: Gradient(colors: [.orange, .black]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                
                VStack{
                    Text("Excersise Name")
                        .bold()
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.vertical)
                    Spacer().frame(height: 550)
                }
                
                VStack{
                    Spacer().frame(height: 100)
                    Text("\(hours):\(minutes):\(seconds)")
                        .font(.system(size: 100, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                    Spacer().frame(height: 100)
                    
                    HStack{
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/,
                               label: {BasicButton(buttonText: "chevron.backward.2")})
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/,
                               label: {BasicButton(buttonText: "play.circle.fill")}).padding(.horizontal, 50)
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/,
                               label: {BasicButton(buttonText: "chevron.forward.2")})
                    }
                    
                    
                }
            }
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
