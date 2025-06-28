//
//  NFXDetailControllerViewModel.swift
//  netfox
//
//  Created by Esteban Cervera on 6/25/25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI
import Foundation

extension NFXDetailControllerView {
    public class ViewModel: ObservableObject {
        let item: NFXModel
        
        @Published var selectedType: NFXDetailConstants.NNFXDetailType {
            didSet {
                onChangeType(selectedType)
            }
        }
        @Published var selectedAtributedText: NSAttributedString
        @Published var selectedStringText: String?
        
        @Published var routingState: RoutingState = .init()
        
        public init(type: NFXDetailConstants.NNFXDetailType = .response, item: NFXModel) {
            self.item = item
            self.selectedType = type
            let texts = NFXDetailConstants.getText(for: type, with: item.httpModel)
            self.selectedAtributedText = texts.0
            self.selectedStringText = texts.1
        }
    
        func onChangeType(_ type: NFXDetailConstants.NNFXDetailType) {
            let texts = NFXDetailConstants.getText(for: type, with: item.httpModel)
            self.selectedAtributedText = texts.0
            self.selectedStringText = texts.1
        }
        
        func onCopyTextBoth() {
            UIPasteboard.general.string = NFXDetailConstants.getText(for: selectedType, with: item.httpModel, headerWithFooter: true).1
        }
        
        func onCopyTextHeader() {
            UIPasteboard.general.string = selectedAtributedText.string
        }
        
        func onCopyTextBody() {
            UIPasteboard.general.string = selectedStringText
        }
        
        
        // MARK: UI Functions
        
        func showShareActionDialog() {
            self.routingState.showShareResponseActionDialog = true
        }
        
        func onShareFullLog() {
            
        }
        
        func shareLog() -> String {
            var tempString = String()

            tempString += "** INFO **\n"
            tempString += "\(NFXDetailConstants.getText(for: .info, with: item.httpModel, headerWithFooter: true).0.string)\n\n"

            tempString += "** REQUEST **\n"
            tempString += "\(NFXDetailConstants.getText(for: .request, with: item.httpModel, headerWithFooter: true).0.string)\n\n"

            tempString += "** RESPONSE **\n"
            tempString += "\(NFXDetailConstants.getText(for: .response, with: item.httpModel, headerWithFooter: true).0.string)\n\n"

            
            return tempString
        }
        
    }
}

// MARK: ROUTING
extension NFXDetailControllerView {
    struct RoutingState {
        var showShareResponseActionDialog: Bool = false
    }
}
