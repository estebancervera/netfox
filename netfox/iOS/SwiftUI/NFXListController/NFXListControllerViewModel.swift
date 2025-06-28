//
//  NFXListControllerViewModel.swift
//  netfox
//
//  Created by Esteban Cervera on 6/25/25.
//  Copyright © 2025. All rights reserved.
//
import SwiftUI
import Foundation

extension NFXListControllerView {
    
    @MainActor
    class ViewModel: ObservableObject {
        @Published var data: [NFXModel] = []
        @Published var selectedItem: NFXModel?
        @Published var isLogging: Bool
        
        @Published var filters: [HTTPModelShortType: (Int, Bool)]
        @Published var selectedFilter: [HTTPModelShortType]?
        
        @Published var textFilter: String = "" {
            didSet { filterModels() }
        }
        // UI
        @Published var routingState: RoutingState = .init()
        
        private var allModels: [NFXHTTPModel] = [] {
            didSet { filterModels() }
        }

        private var dataSubscription: Subscription<[NFXHTTPModel]>?
        
        init() {
            self.isLogging = NFX.sharedInstance().isEnabled()
            self.filters = Dictionary(uniqueKeysWithValues:
                HTTPModelShortType.allCases.enumerated().map { (index, type) in
                    (type, (index, NFXHTTPModelManager.shared.filters[index]))
                }
            )
            // Subscribe to the publisher and update allModels
            dataSubscription = Subscription<[NFXHTTPModel]> { [weak self] in
                self?.populate(with: $0)
            }
            NFXHTTPModelManager.shared.publisher.subscribe(dataSubscription!)
            populate(with: NFXHTTPModelManager.shared.filteredModels)
        }

        deinit {
            dataSubscription?.cancel()
        }

        func populate(with models: [NFXHTTPModel]) {
            DispatchQueue.main.async {
                self.allModels = models
            }
        }
        
        func close() {
            NFX.sharedInstance().hide()
        }
        
        func clearTapped() {
            self.routingState.showClearListConfirmationDialog = true
        }
        
        func clear() {
            self.data = []
            NFX.sharedInstance().clearOldData()
        }
        
        func toggleLogging() {
            isLogging ? NFX.sharedInstance().enable() : NFX.sharedInstance().disable()
        }
        
        func onSelectFilter(_ filter: HTTPModelShortType, isOn: Bool) {
            guard let indexOfType = filters[filter] else {
                return
            }
//            let isActive = NFXHTTPModelManager.shared.filters[indexOfType.0]
            NFXHTTPModelManager.shared.filters[indexOfType.0] = isOn
//            filters[filter] = (indexOfType.0, !isActive)
        }

        private func filterModels() {
            let filterText = textFilter.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !filterText.isEmpty else {
                data = allModels.toNFXModel
                return
            }
            data = allModels.filter {
                ($0.requestURL?.range(of: filterText, options: [.caseInsensitive, .diacriticInsensitive]) != nil) ||
                ($0.requestMethod?.range(of: filterText, options: [.caseInsensitive, .diacriticInsensitive]) != nil) ||
                ($0.responseType?.range(of: filterText, options: [.caseInsensitive, .diacriticInsensitive]) != nil)
            }.toNFXModel
        }
    }
}
// MARK: ROUTING
extension NFXListControllerView {
    struct RoutingState {
        var showClearListConfirmationDialog: Bool = false
    }
}
