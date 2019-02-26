//
//  VYNFCNDEFPayloadTypes.m
//  VYNFCKit
//
//  Created by Vince Yuan on 7/14/17.
//  Copyright © 2017 Vince Yuan. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//


import Foundation

// pragma mark - Base classes

public protocol INDEFPayload : NSObjectProtocol {}

public protocol INDEFWellKnownPayload : INDEFPayload {}

protocol INDEFMediaPayload : INDEFPayload {}

// pragma mark - Well Known Type

protocol INDEFTextPayload : INDEFWellKnownPayload {
    var isUTF16: Bool { get set }
    var langCode: String { get set }
    var text: String { get set }
}


public protocol INDEFURIPayload : INDEFWellKnownPayload {
    var uriString: String { get set }
}


protocol INDEFSmartPosterPayload : INDEFWellKnownPayload {
     var payloadURI: INDEFURIPayload? { get set }
     var payloadTexts: [Any] { get set }
}


// pragma mark - Media Type

protocol INDEFTextXVCardPayload : INDEFMediaPayload {
    var text: String { get set }
}

public enum NDEFWifiSimpleConfigAuthType: UInt8 {
    case open               = 0x00
    case wpaPersonal        = 0x01
    case shared             = 0x02
    case wpaEnterprise      = 0x03
    case wpa2Enterprise     = 0x04
    case wpa2Personal       = 0x05
    case wpaWpa2Personal    = 0x06
}

public enum  NDEFWifiSimpleConfigEncryptType: UInt8 {
    case none    = 0x00
    case wep     = 0x01
    case tkip    = 0x02
    case aes     = 0x03
    case aesTkip = 0x04
}



public protocol INDEFWifiSimpleConfigVersion2: NSObjectProtocol {
    var version: String { get set }
}

protocol INDEFWifiSimpleConfigPayload: INDEFMediaPayload {
    var credentials: [NDEFWifiSimpleConfigCredential] { get set }// There could be more than one credential (e.g. 1 for 2.5GHz and 1 for 5GHz).
    var version2: INDEFWifiSimpleConfigVersion2? { get set }
}



// pragma mark - Base classes

class NDEFPayload: NSObject, INDEFPayload {}

class NDEFWellKnownPayload: NSObject, INDEFWellKnownPayload {}

class NDEFMediaPayload: NSObject, INDEFMediaPayload {}

// pragma mark - Well Known Type

open class NDEFTextPayload: NSObject, INDEFTextPayload {
    open var isUTF16: Bool
    
    open var langCode: String
    
    open var text: String
    
    init(isUTF16: Bool, langCode: String, text: String) {
        self.isUTF16 = isUTF16
        self.langCode = langCode
        self.text = text
    }
}

open class NDEFURIPayload: NSObject, INDEFURIPayload {
    open var uriString: String
    init(URIString: String) {
        self.uriString = URIString
    }
}

open class NDEFSmartPosterPayload: NSObject, INDEFSmartPosterPayload {
    
    open var payloadURI: INDEFURIPayload?
    
    open var payloadTexts: [Any]
    
    init(payloadURI: INDEFURIPayload?, payloadTexts: [Any]) {
        self.payloadURI = payloadURI
        self.payloadTexts = payloadTexts
    }
}

// pragma mark - Media Type

open class NDEFTextXVCardPayload: NSObject, INDEFTextXVCardPayload {
    open var text: String
    init(text: String) {
        self.text = text
    }
}

open class NDEFWifiSimpleConfigCredential: NSObject {
    open var ssid: String
    
    open var macAddress: String
    
    open var networkIndex: UInt8 = 0
    
    open var networkKey: String
    
    open var authType: NDEFWifiSimpleConfigAuthType?
    
    open var encryptType: NDEFWifiSimpleConfigEncryptType?
    
    
    init(ssid: String, macAddress: String, networkIndex: UInt8?, networkKey: String, authType: NDEFWifiSimpleConfigAuthType?, encryptType: NDEFWifiSimpleConfigEncryptType?) {
        self.ssid = ssid
        self.macAddress = macAddress
        self.networkIndex = networkIndex ?? 0
        self.networkKey = networkKey
        self.authType = authType
        self.encryptType = encryptType
    }
    
    
    public class func authTypeString(type: NDEFWifiSimpleConfigAuthType) -> String {
        switch (type) {
        case .open: return "Open";
        case .wpaPersonal: return "WPA Personal";
        case .shared: return "Shared";
        case .wpaEnterprise: return "WPA Enterprise";
        case .wpa2Enterprise: return "WPA2 Enterprise";
        case .wpa2Personal: return "WPA2 Personal";
        case .wpaWpa2Personal: return "WPA/WPA2 Personal";
        //default: return "Unknown";
        }
    }
    
    public class func encryptTypeString(type: NDEFWifiSimpleConfigEncryptType) -> String {
        switch (type) {
        case .none:
            return "None"
        case .wep:
            return "WEP"
        case .tkip:
            return "TKIP"
        case .aes:
            return "AES"
        case .aesTkip:
            return "AES/TKIP"
        //default:return "Unknown"
        }
    }
}


class NDEFWifiSimpleConfigVersion2: NSObject, INDEFWifiSimpleConfigVersion2 {
    var version: String
    init(version: String) {
        self.version = version
    }
}

open class NDEFWifiSimpleConfigPayload: NSObject, INDEFWifiSimpleConfigPayload {
    open var credentials = [NDEFWifiSimpleConfigCredential]()
    
    open var version2: INDEFWifiSimpleConfigVersion2?
    
    init(version2: INDEFWifiSimpleConfigVersion2?) {
        self.version2 = version2
    }
}
