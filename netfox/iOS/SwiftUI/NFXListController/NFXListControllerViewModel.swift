//
//  NFXListControllerViewModel.swift
//  netfox
//
//  Created by Esteban Cervera on 6/25/25.
//  Copyright © 2025 kasketis. All rights reserved.
//
import SwiftUI
import Foundation

extension NFXListControllerView {
    
    @MainActor
    class ViewModel: ObservableObject {
        @Published var data: [NFXModel] = []
        @Published var selectedItem: NFXModel?
        @Published var isLogging: Bool
        
        @Published var textFilter: String = "" {
            didSet { filterModels() }
        }
        // UI
        
        // MOVE TO DIALOG LOGIC
        @Published var showConfirmationDialog: Bool = false
        
        private var allModels: [NFXHTTPModel] = [] {
            didSet { filterModels() }
        }

        private var dataSubscription: Subscription<[NFXHTTPModel]>?
        
        init() {
            self.isLogging = NFX.sharedInstance().isEnabled()
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
            self.showConfirmationDialog = true
        }
        
        func clear() {
            self.data = []
            NFX.sharedInstance().clearOldData()
        }
        
        func toggleLogging() {
            isLogging ? NFX.sharedInstance().enable() : NFX.sharedInstance().disable()
        }
        
        func selectItem(_ item: NFXModel) {
            
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
