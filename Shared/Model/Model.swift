//
//  Model.swift
//  SwiftUIChallenge
//
//  Created by Alexandra Biskulova on 20.02.2024.
//

import Combine
import Foundation
import SwiftUI

enum LoadingState {
    case initial
    case loading
    case loaded
}

class Model: ObservableObject {
    @Published var currentTime: Int = 60
    @Published var loadingState: LoadingState = .initial
    @Published var isFinished = false
    @Published var isPaymentSelected = false
    @Published var isPresented = false
    @Published var paymentTypes = [PaymentType]()
    @Published var searchText = ""

    let processDurationInSeconds: Int = 60
    var repository: PaymentTypesRepository = PaymentTypesRepositoryImplementation()
    var cancellables: [AnyCancellable] = []
    
   // Usecase 1: @Published private(set) var time = Date().timeIntervalSince1970
    
    init() {
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
        // Usecase 1: we may keep `timer` live as long as Model's @Published property `time` does. assign(to:) operator manages the life cycle of the subscription, canceling the subscription automatically when the ``Published`` instance deinitializes and doesn't return an ``AnyCancellable``, so `cancellables` is no longer needed.
// Usecase 1:           .map(\.timeIntervalSince1970)
// Usecase 1:           .map(\.timeIntervalSince1970)
// Usecase 1:           .assign(to: &$time)
            .receive(on: RunLoop.main)
            .sink { [weak self]
                value in
                self?.updateTime()
            }
            .store(in: &cancellables)
    }
        
    deinit {
        print("deinit")
        cancellables.forEach { $0.cancel() }
    }
    
    func updateTime() {
        if currentTime == 0 { 
            currentTime = processDurationInSeconds
        } else {
            currentTime -= 1
        }
    }
    
    func presentPaymentMethods() {
        isPresented.toggle()
    }

    func finishFlow() {
        isFinished = true
    }
    
    func filteredTypes() -> [PaymentType] {
        if searchText.isEmpty {
            paymentTypes
        } else {
            paymentTypes.filter { $0.name.lowercased().contains(searchText.lowercased())}
        }
    }

    func reloadData() async { // run not on main thread
        await MainActor.run { // update published variables on which UI is dependent on main thread
            self.loadingState = .loading
            self.isPaymentSelected = false
        }
        
        Task.detached(priority: .background) { // run background priopity task
            self.repository.getTypes { [weak self] result in
                guard let weakSelf = self else { return }
                switch result {
                case .success(let types):
                    weakSelf.paymentTypes = types
                case .failure(_):
                    weakSelf.paymentTypes = []
                }
                weakSelf.loadingState = .loaded
            }
        }
    }
}
