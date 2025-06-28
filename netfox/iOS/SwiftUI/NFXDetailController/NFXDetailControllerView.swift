//
//  NFXDetailControllerView.swift
//  netfox
//
//  Created by Esteban Cervera on 6/25/25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

struct NFXDetailControllerView: View {
    @ObservedObject private var viewModel: ViewModel
    
    @State private var headerExpanded = false
    @State private var bodyExpanded = true
    
    public init(_ viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        mainView
            .navigationTitle("Details")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: viewModel.shareLog(), subject: Text("Full Log"), message: Text("Full Log"))
                }
                
                ToolbarItem(placement: .bottomBar) {
                    selectorView
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Menu("Menu", systemImage: "document.on.document") {
                        Button("Copy Both", systemImage: "document.on.clipboard", action: viewModel.onCopyTextBoth)
                        Button("Copy Headers", systemImage: "document.on.document.fill", action: viewModel.onCopyTextHeader)
                        Button("Copy Body", systemImage: "document.on.document", action: viewModel.onCopyTextBody)
                    } primaryAction: {
                        viewModel.onCopyTextBody()
                    }

                }
            }
    }
    
    private var mainView: some View {
        VStack {
            Form {
                form
            }
        }
    }
    
    private var selectorView: some View {
        Section {
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
    }
    
    @ViewBuilder
    private var form: some View {
        Group {
            switch viewModel.selectedType {
            case .info:
                headerTextView
                    .frame(maxHeight: .infinity)
            case .request, .response:
                expandableHeaderView
                expandableBodyView
            }
        }
    }
    
    private var expandableHeaderView: some View {
        Section {
            HStack {
                Text("Headers")
                    .font(.headline)
                Spacer()
                
                Button {
                    withAnimation {
                        self.headerExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .renderingMode(.template)
                        .foregroundStyle(.primary)
                        .rotationEffect(headerExpanded ? .degrees(90) : .zero, anchor: .center)
                }
            }
            if headerExpanded {
                headerTextView
            }
        }
    }
    
    private var expandableBodyView: some View {
        Section {
            HStack {
                Text("Body")
                    .font(.headline)
                Spacer()
                Button {
                    withAnimation {
                        self.bodyExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .renderingMode(.template)
                        .foregroundStyle(.primary)
                        .rotationEffect(bodyExpanded ? .degrees(90) : .zero, anchor: .center)
                }
            }
            if bodyExpanded {
                textView
            }
        }
    }
    
    
    @ViewBuilder
    private var headerTextView: some View {
        if #available(iOS 18.0, *) {
            TextEditor(text: .constant(viewModel.selectedAtributedText.string), selection: .constant(nil))
                .font(.caption)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
        } else {
            Text(viewModel.selectedAtributedText.string)
                .font(.caption)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
        }
        
    }
    
   
    
    @ViewBuilder
    private var textView: some View {
        Section {
            if let text = viewModel.selectedStringText {
                if #available(iOS 18.0, *) {
                    TextEditor(text:.constant(text), selection: .constant(nil))
                        .font(.caption)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                } else {
                    Text(text)
                        .font(.caption)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
}

#Preview {
    NFXDetailControllerView(.init(item: .init(httpModel: .random())))
}
