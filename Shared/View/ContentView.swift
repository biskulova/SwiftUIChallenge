//
//  ContentView.swift
//  SwiftUIChallenge
//
//  Created by Alexandra Biskulova on 20.02.2024.
//

// 1. Setup UI of the ContentView. Try to keep it as similar as possible.
// 2. Subscribe to the timer and count seconds down from 60 to 0 on the ContentView.
// 3. Present PaymentModalView as a sheet after tapping on the "Open payment" button.
// 4. Load payment types from repository in PaymentInfoView. Show loader when waiting for the response. No need to handle error.
// 5. List should be refreshable.
// 6. Show search bar for the list to filter payment types. You can filter items in any way.
// 7. User should select one of the types on the list. Show checkmark next to the name when item is selected.
// 8. Show "Done" button in navigation bar only if payment type is selected. Tapping this button should hide the modal.
// 9. Show "Finish" button on ContentScreen only when "payment type" was selected.
// 10. Replace main view with "FinishView" when user taps on the "Finish" button.

import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var model: Model
    var body: some View {
        if (model.isFinished) {
            FinishView()
        } else {
            VStack {
                Spacer()
                // Seconds should count down from 60 to 0
                Text("You have only \(model.currentTime) seconds left to get the discount")
                    .font(.title)
                    .foregroundColor(.white)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .multilineTextAlignment(.center)
                
                Spacer()
                VStack {
                    Button(action: {
                        model.presentPaymentMethods()
                    }, label: {
                        Text("Open payment")
                            .padding(.top)
                            .padding(.bottom)
                            .frame(maxWidth: .infinity)
                    })
                    .blueButtonStyle()
                    .sheet(isPresented: $model.isPresented, content: {
                        PaymentModalView()
                    })
                    
                    if (model.isPaymentSelected) {
                        // Visible only if payment type is selected
                        Button(action: {
                            model.finishFlow()
                        }, label: {
                            Text("Finish")
                                .padding(.top)
                                .padding(.bottom)
                                .frame(maxWidth: .infinity)
                            
                        })
                        .blueButtonStyle()
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.blue)
        }
    }
}

struct PaymentModalView : View {
    var body: some View {
        NavigationView {
            PaymentInfoView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Model())
    }
}
