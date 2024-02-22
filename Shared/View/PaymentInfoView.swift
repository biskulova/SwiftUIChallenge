//
//  PaymentInfoView.swift
//  SwiftUIChallenge
//
//  Created by Alexandra Biskulova on 20.02.2024.
//

import Foundation
import SwiftUI

// Load payment types when presenting the view. Repository has 2 seconds delay.
// User should select an item.
// Show checkmark in a selected row.
//
// No need to handle error.
// Use refreshing mechanism to reload the list items.
// Show loader before response comes.
// Show search bar to filter payment types
//
// Finish button should be only available if user selected payment type.
// Tapping on Finish button should close the modal.

struct PaymentInfoView: View {
    @EnvironmentObject var model: Model
    @Environment(\.dismiss) private var dismiss
    @State var selection: PaymentType? // TODO: save selection in model
    
    var body: some View {
        if model.loadingState != .loaded {
            ProgressView()
                .navigationTitle("Payment info")
                .progressViewStyle(.circular)
                .task(priority: .background) { // schedule in background priority
                    if model.loadingState == .initial {
                        await model.reloadData()
                    }
                }
        } else {
            List(model.filteredTypes(), id:\.id) { type in
                Button(action: {
                    selection = type
                    model.isPaymentSelected = selection != nil
                }, label: {
                    HStack {
                        Text(type.name)
                        Spacer()
                        if selection == type {
                            Image(systemName: "checkmark")
                        }
                    }
                    .tint(.black)
                })
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button("Favorite") {}.tint(.yellow)
                    Button("Delete", role: .destructive) {}
                }
            }
            .searchable(text: $model.searchText)//, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Payment info")
            .navigationBarItems(trailing: Group {
                if (selection != nil) {
                    Button("Done", action: {
                        dismiss()
                    })
                }
            })
            .refreshable { // user initiated task priority
                selection = nil
                model.isPaymentSelected = false
                await model.reloadData()
            }
            .onDisappear() {
                model.loadingState = .initial
            }
        }
    }
}

struct PaymentInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentInfoView()
            .environmentObject(Model())
    }
}
