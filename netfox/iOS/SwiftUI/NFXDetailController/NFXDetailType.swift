//
//  NFXDetailType.swift
//  netfox
//
//  Created by Esteban Cervera on 6/25/25.
//  Copyright © 2025 kasketis. All rights reserved.
//

import SwiftUI

extension NFXDetailControllerView {
   
    
   
}

struct NFXDetailConstants {
    enum NNFXDetailType: String, CaseIterable, Equatable, Hashable, Identifiable {
        
        var id: String { rawValue }
        
        case info
        case request
        case response
        
        var label: String {
            rawValue.capitalized
        }
    }
    
    enum Texts: String {
        case headersTitle = "-- Headers --\n\n"
        case bodyTitle = "\n-- Body --\n\n"
        case tooLongToShowTitle = "Too long to show. If you want to see it, please tap the following button\n"
    }
    
    static func getText(for type: NNFXDetailType, with object: NFXHTTPModel) -> (NSAttributedString, String?) {
        switch type {
        case .info:
            (getInfoStringFromObject(object), nil)
        case .request:
            (getRequestStringFromObject(object), getRequestBodyStringFooter(object))
        case .response:
            (getResponseStringFromObject(object), getResponseBodyStringFooter(object))
        }
    }
}

// MARK: Format NFX String
extension NFXDetailConstants {
    
    private static func formatNFXString(_ string: String) -> NSAttributedString {
        var tempMutableString = NSMutableAttributedString()
        tempMutableString = NSMutableAttributedString(string: string)
        
        let stringCount = string.count
        
        let regexBodyHeaders = try! NSRegularExpression(pattern: "(\\-- Body \\--)|(\\-- Headers \\--)", options: NSRegularExpression.Options.caseInsensitive)
        let matchesBodyHeaders = regexBodyHeaders.matches(in: string, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, stringCount)) as Array<NSTextCheckingResult>
        
        for match in matchesBodyHeaders {
            tempMutableString.addAttribute(.font, value: NFXFont.NFXFontBold(size: 14), range: match.range)
            tempMutableString.addAttribute(.foregroundColor, value: NFXColor.NFXOrangeColor(), range: match.range)
        }
        
        let regexKeys = try! NSRegularExpression(pattern: "\\[.+?\\]", options: NSRegularExpression.Options.caseInsensitive)
        let matchesKeys = regexKeys.matches(in: string, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, stringCount)) as Array<NSTextCheckingResult>
        
        for match in matchesKeys {
            tempMutableString.addAttribute(.foregroundColor, value: NFXColor.NFXBlackColor(), range: match.range)
            tempMutableString.addAttribute(.link,
                                           value: (string as NSString).substring(with: match.range),
                                           range: match.range)
        }
        
        return tempMutableString
    }
}

// MARK: RESPONSE FUNCTION

extension NFXDetailConstants {
    private static func getResponseStringFromObject(_ object: NFXHTTPModel, withFooter: Bool = false) -> NSAttributedString {
        if (object.noResponse) {
            return NSMutableAttributedString(string: "No response")
        }
        
        var tempString: String
        tempString = String()
        
        tempString +=  Texts.headersTitle.rawValue
        
        if object.responseHeaders?.count ?? 0 > 0 {
            for (key, val) in object.responseHeaders! {
                tempString += "[\(key)] \n\(val)\n\n"
            }
        } else {
            tempString += "Response headers are empty\n\n"
        }
        
        
    #if os(iOS)
        if withFooter {
            tempString += getResponseBodyStringFooter(object)
        }
    #endif
        return NFXDetailConstants.formatNFXString(tempString)
    }
    
   private static func getResponseBodyStringFooter(_ object: NFXHTTPModel) -> String {
        var tempString =  Texts.bodyTitle.rawValue
        if (object.responseBodyLength == 0) {
            tempString += "Response body is empty\n"
        } else if (object.responseBodyLength ?? 0 > 1024) {
            tempString +=  Texts.tooLongToShowTitle.rawValue
        } else {
            tempString += "\(object.getResponseBody())\n"
        }
        return tempString
    }
}

// MARK: REQUEST FUNCTION

extension NFXDetailConstants {
    private static func getRequestStringFromObject(_ object: NFXHTTPModel, withFooter: Bool = false) -> NSAttributedString {
        var tempString: String
        tempString = String()
        
        tempString += Texts.headersTitle.rawValue
        
        if object.requestHeaders?.count ?? 0 > 0 {
            for (key, val) in (object.requestHeaders)! {
                tempString += "[\(key)] \n\(val)\n\n"
            }
        } else {
            tempString += "Request headers are empty\n\n"
        }
        
    #if os(iOS)
        if withFooter {
            tempString += getRequestBodyStringFooter(object)
        }
    #endif
        return formatNFXString(tempString)
    }

    private static func getRequestBodyStringFooter(_ object: NFXHTTPModel) -> String {
        var tempString = Texts.bodyTitle.rawValue
        if (object.requestBodyLength == 0) {
            tempString += "Request body is empty\n"
        } else if (object.requestBodyLength ?? 0 > 1024) {
            tempString += Texts.tooLongToShowTitle.rawValue
        } else {
            tempString += "\(object.getRequestBody())\n"
        }
        return tempString
    }
}

// MARK: INFO Functions

extension NFXDetailConstants {
    private static func getInfoStringFromObject(_ object: NFXHTTPModel) -> NSAttributedString {
        var tempString: String
        tempString = String()
        
        tempString += "[URL] \n\(object.requestURL!)\n\n"
        tempString += "[Method] \n\(object.requestMethod!)\n\n"
        if !(object.noResponse) {
            tempString += "[Status] \n\(object.responseStatus!)\n\n"
        }
        tempString += "[Request date] \n\(object.requestDate!)\n\n"
        if !(object.noResponse) {
            tempString += "[Response date] \n\(object.responseDate!)\n\n"
            tempString += "[Time interval] \n\(object.timeInterval!)\n\n"
        }
        tempString += "[Timeout] \n\(object.requestTimeout!)\n\n"
        tempString += "[Cache policy] \n\(object.requestCachePolicy!)\n\n"
        
        return formatNFXString(tempString)
    }
}
