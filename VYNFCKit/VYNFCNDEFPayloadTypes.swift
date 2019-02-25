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

public protocol IVYNFCNDEFPayload : NSObjectProtocol {}

public protocol IVYNFCNDEFWellKnownPayload : IVYNFCNDEFPayload {}

protocol IVYNFCNDEFMediaPayload : IVYNFCNDEFPayload {}

// pragma mark - Well Known Type

protocol IVYNFCNDEFTextPayload : IVYNFCNDEFWellKnownPayload {
    var isUTF16: Bool { get set }
    var langCode: String { get set }
    var text: String { get set }
}


public protocol IVYNFCNDEFURIPayload : IVYNFCNDEFWellKnownPayload {
    var uriString: String { get set }
}


protocol IVYNFCNDEFSmartPosterPayload : IVYNFCNDEFWellKnownPayload {
     var payloadURI: IVYNFCNDEFURIPayload? { get set }
     var payloadTexts: [Any] { get set }
}


// pragma mark - Media Type

protocol IVYNFCNDEFTextXVCardPayload : IVYNFCNDEFMediaPayload {
    var text: String { get set }
}

public enum VYNFCNDEFWifiSimpleConfigAuthType: UInt8 {
    case open               = 0x00
    case wpaPersonal        = 0x01
    case shared             = 0x02
    case wpaEnterprise      = 0x03
    case wpa2Enterprise     = 0x04
    case wpa2Personal       = 0x05
    case wpaWpa2Personal    = 0x06
}

public enum  VYNFCNDEFWifiSimpleConfigEncryptType: UInt8 {
    case none    = 0x00
    case wep     = 0x01
    case tkip    = 0x02
    case aes     = 0x03
    case aesTkip = 0x04
}


public protocol IVYNFCNDEFWifiSimpleConfigCredential: NSObjectProtocol {
    var ssid: String { get set }
    var macAddress: String { get set }// "ff:ff:ff:ff:ff:ff" means unlimited
    var networkIndex: UInt8 { get set }
    var networkKey: String { get set }
    var authType: VYNFCNDEFWifiSimpleConfigAuthType? { get set }
    var encryptType: VYNFCNDEFWifiSimpleConfigEncryptType? { get set }
    
    func authTypeString(type: VYNFCNDEFWifiSimpleConfigAuthType) -> String
    func encryptTypeString(type: VYNFCNDEFWifiSimpleConfigEncryptType) -> String
}


public protocol IVYNFCNDEFWifiSimpleConfigVersion2: NSObjectProtocol {
    var version: String { get set }
}

protocol IVYNFCNDEFWifiSimpleConfigPayload: IVYNFCNDEFMediaPayload {
    var credentials: [IVYNFCNDEFWifiSimpleConfigCredential] { get set }// There could be more than one credential (e.g. 1 for 2.5GHz and 1 for 5GHz).
    var version2: IVYNFCNDEFWifiSimpleConfigVersion2? { get set }
}



// pragma mark - Base classes

class VYNFCNDEFPayload: NSObject, IVYNFCNDEFPayload {}

class VYNFCNDEFWellKnownPayload: NSObject, IVYNFCNDEFWellKnownPayload {}

class VYNFCNDEFMediaPayload: NSObject, IVYNFCNDEFMediaPayload {}

// pragma mark - Well Known Type

open class VYNFCNDEFTextPayload: NSObject, IVYNFCNDEFTextPayload {
    open var isUTF16: Bool
    
    open var langCode: String
    
    open var text: String
    
    init(isUTF16: Bool, langCode: String, text: String) {
        self.isUTF16 = isUTF16
        self.langCode = langCode
        self.text = text
    }
}

open class VYNFCNDEFURIPayload: NSObject, IVYNFCNDEFURIPayload {
    open var uriString: String
    init(URIString: String) {
        self.uriString = URIString
    }
}

open class VYNFCNDEFSmartPosterPayload: NSObject, IVYNFCNDEFSmartPosterPayload {
    
    open var payloadURI: IVYNFCNDEFURIPayload?
    
    open var payloadTexts: [Any]
    
    init(payloadURI: IVYNFCNDEFURIPayload?, payloadTexts: [Any]) {
        self.payloadURI = payloadURI
        self.payloadTexts = payloadTexts
    }
}

// pragma mark - Media Type

open class VYNFCNDEFTextXVCardPayload: NSObject, IVYNFCNDEFTextXVCardPayload {
    open var text: String
    init(text: String) {
        self.text = text
    }
}

open class VYNFCNDEFWifiSimpleConfigCredential: NSObject, IVYNFCNDEFWifiSimpleConfigCredential {
    open var ssid: String
    
    open var macAddress: String
    
    open var networkIndex: UInt8 = 0
    
    open var networkKey: String
    
    open var authType: VYNFCNDEFWifiSimpleConfigAuthType?
    
    open var encryptType: VYNFCNDEFWifiSimpleConfigEncryptType?
    
    
    init(ssid: String, macAddress: String, networkIndex: UInt8?, networkKey: String, authType: VYNFCNDEFWifiSimpleConfigAuthType?, encryptType: VYNFCNDEFWifiSimpleConfigEncryptType?) {
        self.ssid = ssid
        self.macAddress = macAddress
        self.networkIndex = networkIndex ?? 0
        self.networkKey = networkKey
        self.authType = authType
        self.encryptType = encryptType
    }
    
    
    public func authTypeString(type: VYNFCNDEFWifiSimpleConfigAuthType) -> String {
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
    
    public func encryptTypeString(type: VYNFCNDEFWifiSimpleConfigEncryptType) -> String {
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


class VYNFCNDEFWifiSimpleConfigVersion2: NSObject, IVYNFCNDEFWifiSimpleConfigVersion2 {
    var version: String
    init(version: String) {
        self.version = version
    }
}

open class VYNFCNDEFWifiSimpleConfigPayload: NSObject, IVYNFCNDEFWifiSimpleConfigPayload {
    open var credentials = [IVYNFCNDEFWifiSimpleConfigCredential]()
    
    open var version2: IVYNFCNDEFWifiSimpleConfigVersion2?
    
    init(version2: IVYNFCNDEFWifiSimpleConfigVersion2?) {
        self.version2 = version2
    }
}
