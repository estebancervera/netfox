//
//  NFXModel.swift
//  netfox
//
//  Created by Esteban Cervera on 6/25/25.
//  Copyright © 2025. All rights reserved.
//

import SwiftUI

/*
 setURL(obj.customName ?? obj.requestURL ?? "-")
 setStatus(obj.responseStatus ?? 999)
 setTimeInterval(obj.timeInterval ?? 999)
 setRequestTime(obj.requestTime ?? "-")
 setType(obj.responseType ?? "-")
 setMethod(obj.requestMethod ?? "-")
 isNewBasedOnDate(obj.responseDate as Date? ?? Date())
 */

struct NFXModel: Identifiable {
    let httpModel: NFXHTTPModel
    
    var id: Int {
        httpModel.hash
    }
    
    var url: String {
        httpModel.requestURL ?? "Unknown URL"
    }
    
    var label: String {
        httpModel.customName ??  httpModel.requestURL ?? "Unknown URL"
    }
    
    var timeInteval: String {
        if status == .timeout {
            return "-"
        }
        return String(format: "%.2f ms", httpModel.timeInterval ?? 0)
    }
    
    var status: StatusType {
        .init(httpModel.responseStatus)
    }
    
    var type: ResponseType {
        .init(value: httpModel.responseType)
    }
    
    var date: Date {
        httpModel.responseDate ?? Date()
    }
    
    var time: String {
        httpModel.requestTime ?? "-"
    }
    
    var method: String {
        httpModel.shortType.rawValue
    }
    
}

extension NFXModel {
    
    enum StatusType: String, CaseIterable {
        case success
        case error
        case timeout
        
        
        init(_ statusCode: Int?) {
            guard let statusCode = statusCode else {
                self = .timeout
                return
            }
            switch statusCode {
            case 999:
                self = .timeout
            case 200..<300:
                self = .success
            default:
                self = .error
            }
        }
        
        var color: Color {
            switch self {
            case .success:
                return .green
            case .error:
                return .red
            default:
                return .gray
            }
        }
    }
    
    
    enum ResponseType: String, CaseIterable {
        case post
        case get
        case delete
        case put
        case patch
        
        init(value: String?) {
            guard let value else {
                self = .get
                return
            }
            self = .init(rawValue: value.lowercased()) ?? .get
        }
        
        var label: String {
            rawValue.uppercased()
        }
        
        var icon: Image {
            switch self {
            case .post:
                Image(systemName: "arrow.up.circle.fill")
            case .get:
                Image(systemName: "arrow.down.circle.fill")
            case .delete:
                Image(systemName: "trash.circle.fill")
            case .put:
                Image(systemName: "pencil.circle.fill")
            case .patch:
                Image(systemName: "cross.circle.fill")
            }
        }
    }
}

extension NFXModel {
    static func random(count: Int = 10) -> [NFXModel] {
        Array(1...count).map { _ in NFXModel(httpModel: .random()) }
    }
}

extension NFXHTTPModel {
    static func random() -> NFXHTTPModel {
        let random: NFXHTTPModel = .init()
        let url = URL(string: "www.google.com/\(Int.random(in: 0...20))")!
        random.saveRequest(.init(url: url))
        return random
    }
}

extension Collection where Element == NFXHTTPModel {
    var toNFXModel: [NFXModel] {
        self.map {
            .init(httpModel: $0)
        }
    }
}

