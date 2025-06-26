//
//  NFXDetailControllerView.swift
//  netfox
//
//  Created by Esteban Cervera on 6/25/25.
//  Copyright © 2025 kasketis. All rights reserved.
//

import SwiftUI

struct NFXDetailControllerView: View {
    @ObservedObject private var viewModel: ViewModel
    
    public init(_ viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        mainView
    }
    
    private var mainView: some View {
        VStack {
           
            ScrollView {
                selectorView
                headerTextView
                textView
                Spacer()
            }
        }
    }
    
    private var selectorView: some View {
        Picker("View Selection", selection: $viewModel.selectedType) {
            ForEach(NFXDetailConstants.NNFXDetailType.allCases) { type in
                Text(type.label)
                    .tag(type)
                    .font(.caption)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var headerTextView: some View {
        if #available(iOS 18.0, *) {
            TextEditor(text: .constant(viewModel.selectedAtributedText.string), selection: .constant(nil))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
        } else {
            Text(viewModel.selectedAtributedText.string)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
        }
        
    }
    
    @ViewBuilder
    private var textView: some View {
        if let text = viewModel.selectedStringText {
            if #available(iOS 18.0, *) {
                TextEditor(text:.constant(text), selection: .constant(nil))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            } else {
               Text(text)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

#Preview {
    NFXDetailControllerView(.init(item: .init(httpModel: .random())))
}
