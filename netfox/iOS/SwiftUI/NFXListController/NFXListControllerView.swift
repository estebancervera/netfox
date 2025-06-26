//
//  NFXListControllerView.swift
//  netfox
//
//  Created by Esteban Cervera on 6/25/25.
//  Copyright © 2025 kasketis. All rights reserved.
//

import SwiftUI
import Foundation

public struct NFXListControllerView: View {
    @StateObject private var viewModel: ViewModel = .init()
    
    @State var isRecording: Bool = false
    @State var slider: Double = 10.0
    
    public var body: some View {
        NavigationStack {
            mainView
        }
    }
    
    private var mainView: some View {
        listView
            .toolbar {
                if #available(iOS 26.0, *) {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close", systemImage: "xmark", role: .close, action: viewModel.close)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear", systemImage: "trash", role: .destructive, action: viewModel.clearTapped)
                            .confirmationDialog("Clear data?", isPresented: $viewModel.showConfirmationDialog) {
                                
                                Button("Yes, delete", role: .destructive, action: viewModel.clear)
                                    
                                Button("Cancel", role: .close) { }
                                    
                            } message: {
                                Text("You sure you want to delete all the previous data?")
                            }
                        
                    }
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                    ToolbarItem(placement: .topBarTrailing) {
                        Toggle("Logging", systemImage: "record.circle", isOn: $viewModel.isLogging)
                            .tint(.red)
                            .onChange(of: viewModel.isLogging) {
                                viewModel.toggleLogging()
                            }
                    }
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                    ToolbarItem(placement: .topBarTrailing) {
                        
                        Menu("Menu", systemImage: "ellipsis") {
                           
                            Button("Filter", systemImage: "line.3.horizontal.decrease") {
                                print("filter")
                            }
                            Button("Settings", systemImage: "gear") {
                                print("settings")
                            }
                            
                        }
                        
                        
                    }
                } else {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close", systemImage: "xmark", action: viewModel.close)
                    }
                    
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("Clear", systemImage: "trash", action: viewModel.clear)
                        
                        Menu("Menu", systemImage: "ellipsis") {
                            Toggle("Logging", systemImage: "record.circle", isOn: $viewModel.isLogging)
                            Button("Filter", systemImage: "line.3.horizontal.decrease") {
                                print("filter")
                            }
                            Button("Settings", systemImage: "gear") {
                                print("settings")
                            }
                            
                        }
                    }
                }
            }
    }
    
    private var listView: some View {
        List {
            if viewModel.data.isEmpty {
                Text("No data found")
            } else {
                ForEach(viewModel.data) { item in
                    NavigationLink {
                        detailView(item: item)
                    } label: {
                        rowView(item)
                    }
                }
            }
        }
        .searchable(text: $viewModel.textFilter, placement: .toolbarPrincipal, prompt: "Search")
        .toolbarTitleDisplayMode(.automatic)
        .navigationTitle("Requests")
    }
    
    private func rowView(_ item: NFXModel) -> some View {
        HStack {
            VStack {
                item.type.icon
                    .font(.title)
                    .foregroundStyle(item.status.color)
                Text(item.type.label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(item.status.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    
            }
            
            
            VStack(alignment: .leading) {
                Text(item.label)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.7)
                    .truncationMode(.tail)
                Text(item.date, style: .time)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
        }
        .contextMenu {
            Label(item.url, systemImage: "globe")
            Label("Resp. Time: \(item.timeInteval)", systemImage: "timer")
            Label("Method: \(item.method)", systemImage: "ellipsis.curlybraces")
        }
    }
    
    private func detailView(item: NFXModel) -> some View {
        NFXDetailControllerView(.init(item: item))
    }
}

#Preview {
    NavigationStack {
        NFXListControllerView()
    }
}
