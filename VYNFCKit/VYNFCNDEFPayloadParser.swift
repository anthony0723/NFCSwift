//
//  VYNFCNDEFPayloadParser.m
//  VYNFCKit
//
//  Created by Vince Yuan on 7/8/17.
//  Copyright © 2017 Vince Yuan. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//
/// Using: https://github.com/apple/swift/blob/master/stdlib/public/core/CTypes.swift

import Foundation
import CoreNFC

@available(iOS, introduced: 11.0)//only on iPhone/iPad
protocol IVYNFCNDEFPayloadParser: NSObjectProtocol {
}

open class VYNFCNDEFPayloadParser: NSObject, IVYNFCNDEFPayloadParser {
    
    class func uint16FromBigEndian(_ array: [UInt8], offset: Int) -> Int {
        let leftByte = Int(array[offset])
        let rightByte = Int(array[offset+1])
        return leftByte*256+rightByte
    }
    
    open class func parse(payload: NFCNDEFPayload?) -> Any? {
        guard let payload = payload else {
            return nil
        }
        
        let typeString_ = String(data: payload.type, encoding: String.Encoding.utf8)
        let identifierString_ = String(data: payload.identifier, encoding: .utf8)
        
        let payloadBytesLength = payload.payload.count
        
        var payloadBytes = [CUnsignedChar](repeating:0, count: payloadBytesLength)
        payload.payload.copyBytes(to: &payloadBytes, count: payloadBytesLength)
        
        guard let typeString = typeString_,
            let _ = identifierString_ else {
                return nil
        }
        
        if (payload.typeNameFormat == NFCTypeNameFormat.nfcWellKnown) {
            if (typeString == "T") {
                return VYNFCNDEFPayloadParser.parseTextPayload(payloadBytes: payloadBytes, length: payloadBytesLength)
            } else if (typeString == "U") {
                return VYNFCNDEFPayloadParser.parseURIPayload(payloadBytes: payloadBytes, length: payloadBytesLength)
            } else if(typeString  == "Sp") {
                return VYNFCNDEFPayloadParser.parseSmartPosterPayload(payloadBytes: payloadBytes, length: payloadBytesLength)
            }
        } else if (payload.typeNameFormat == NFCTypeNameFormat.media) {
            if (typeString == "text/x-vCard") {
                return VYNFCNDEFPayloadParser.parseTextXVCardPayload(payloadBytes: payloadBytes, length: payloadBytesLength)
            } else if typeString == "application/vnd.wfa.wsc" {
                return VYNFCNDEFPayloadParser.parseWifiSimpleConfigPayload(payloadBytes: payloadBytes, length: payloadBytesLength)
            }
        }
        return nil
    }
    
    // pragma mark - Parse Well Known Type
    
    // |------------------------------|
    // | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0|
    // |------------------------------|
    // |UTF| 0 | Length of Lang Code  |  1 byte Text Record Status Byte
    // |------------------------------|
    // |          Lang Code           |  2 or 5 bytes, multi-byte language code
    // |------------------------------|
    // |             Text             |  Multiple Bytes encoded in UTF-8 or UTF-16
    // |------------------------------|
    // Text Record Status Byte: size = 1 byte: specifies the encoding type (UTF8 or UTF16) and the length of the language code
    //   UTF : 0=UTF8, 1=UTF16
    //   Bit6 : bit 6 is reserved for future use and must always be 0
    //   Bit5-0: Length Language Code: specifies the size of the Lang Code field in bytes
    // Lang Code : size = 2 or 5 bytes (may vary in future) : this is the langauge code for the document(ISO/IANA), common codes are ‘en’ for english, ‘en-US’ for United States English, ‘jp’ for japanese, … etc
    // Text : size = remainder of Payload Size : this is the area that contains the text, the format and language are known from the UTF bit and the Lang Code.
    //
    // Example: "\2enThis is text.", "\2cn你好hello"
    class func parseTextPayload(payloadBytes: [CUnsignedChar], length: Int) -> Any? {
        if (length < 1) {
            return nil
        }
        
        // Parse first byte Text Record Status Byte.
        let isUTF16 = (payloadBytes[0] & 0x80 != 0)
        let codeLength = Int(payloadBytes[0] & 0x7F)
        
        if (length < 1 + codeLength) {
            return nil
        }
        
        let lengthInt = Int(length)
        let codeLengthInt = Int(codeLength)
        
        // Get lang code and text.
        let subArr = subArray(array:payloadBytes, from:1, length: codeLengthInt)//length - 1
        let langCode = String(cString: subArr)
        
        
        let subArrayFortext = subArray(array:payloadBytes,
                                       from:1+codeLengthInt,
                                       length: lengthInt-1-codeLengthInt) //length - 1 - codeLength
        
        let text = String(cString: subArrayFortext)
        //encoding: (!isUTF16)?NSUTF8StringEncoding:NSUTF16StringEncoding]
        
        if langCode.isEmpty || text.isEmpty {
            return nil
        }
        let payload = VYNFCNDEFTextPayload(isUTF16: isUTF16, langCode: langCode, text: text)
        return payload
    }
    
    // |------------------------------|
    // |         ID Code              |  1 byte ID Code
    // |------------------------------|
    // |      UTF-8 String            |  Multiple Bytes UTF-8 string
    // |------------------------------|
    // Example: "\4example.com" stands for "https://example.com"
    class func parseURIPayload(payloadBytes: [CUnsignedChar], length: Int) -> Any? {
        if (length < 1) {
            return nil
        }
        
        // Get ID code and original text.
        let code = payloadBytes[0] as CUnsignedChar
        let originalText = String(cString: subArray(array:payloadBytes, from: 1, length: length - 1))//length - 1
        
        if originalText.isEmpty {
            return nil
        }
        
        // Add prefix according to ID code.
        var text: String
        switch (code) {
        case 0x00: // N/A. No prepending is done
            text = originalText
        case 0x01: // http://www.
            text = "http://www.".appending(originalText)
        case 0x02: // https://www.
            text = "https://www.".appending(originalText)
        case 0x03: // http://
            text = "http://".appending(originalText)
        case 0x04: // https://
            text = "https://".appending(originalText)
        case 0x05: // tel:
            text = "tel:".appending(originalText)
        case 0x06: // mailto:
            text = "mailto:".appending(originalText)
        case 0x07: // ftp://anonymous:anonymous@
            text = "ftp://anonymous:anonymous@".appending(originalText)
        case 0x08: // ftp://ftp.
            text = "ftp://ftp.".appending(originalText)
        case 0x09: // ftps://
            text = "ftps://".appending(originalText)
        case 0x0A: // sftp://
            text = "sftp://".appending(originalText)
        case 0x0B: // smb://
            text = "smb://".appending(originalText)
        case 0x0C: // nfs://
            text = "nfs://".appending(originalText)
        case 0x0D: // ftp://
            text = "ftp://".appending(originalText)
        case 0x0E: // dav://
            text = "dav://".appending(originalText)
        case 0x0F: // news:
            text = "news:".appending(originalText)
        case 0x10: // telnet://
            text = "telnet://".appending(originalText)
        case 0x11: // imap:
            text = "imap:".appending(originalText)
        case 0x12: // rtsp://
            text = "rtsp://".appending(originalText)
        case 0x13: // urn:
            text = "urn:".appending(originalText)
        case 0x14: // pop:
            text = "pop:".appending(originalText)
        case 0x15: // sip:
            text = "sip:".appending(originalText)
        case 0x16: // sips:
            text = "sips:".appending(originalText)
        case 0x17: // tftp:
            text = "tftp:".appending(originalText)
        case 0x18: // btspp://
            text = "btspp://".appending(originalText)
        case 0x19: // btl2cap://
            text = "btl2cap://".appending(originalText)
        case 0x1A: // btgoep://
            text = "btgoep://".appending(originalText)
        case 0x1B: // tcpobex://
            text = "tcpobex://".appending(originalText)
        case 0x1C: // irdaobex://
            text = "irdaobex://".appending(originalText)
        case 0x1D: // file://
            text = "file://".appending(originalText)
        case 0x1E: // urn:epc:id:
            text = "urn:epc:id:".appending(originalText)
        case 0x1F: // urn:epc:tag:
            text = "urn:epc:tag:".appending(originalText)
        case 0x20: // urn:epc:pat:
            text = "urn:epc:pat:".appending(originalText)
        case 0x21: // urn:epc:raw:
            text = "urn:epc:raw:".appending(originalText)
        case 0x22: // urn:epc:
            text = "urn:epc:".appending(originalText)
        case 0x23: // urn:nfc:
            text = "urn:nfc:".appending(originalText)
        default: // 0x24-0xFF RFU Reserved for Future Use, Not Valid Inputs
            return nil
        }
        let payload = VYNFCNDEFURIPayload(URIString: text)
        return payload
    }
    
    // Smart Poster Record (‘Sp’) Payload Layout:
    // A smart poster is a special kind of NDEF Message, it is a wrapper for other message types. Smart Poster records were
    // initially meant to be used as a hub for information, think put a smart poster tag on a movie poster and it will give
    // you a title for the tag, a link to the movie website, a small image for the movie and maybe some other data. In
    // practice Smart Posters are rarely used, most people prefer to simply use a URI record to send people off to do stuff
    // (the majority of Google Android NFC messages are implemented this way with custom TNF tags).
    // A smart poster must contain:
    //  1+ Text records (there can be multiple in multiple languages)
    //  1 URI record (this is the main record, everything else is metadata
    //  1 Action Record – Specifies Action to do on URI, (Open, Save, Edit)
    // A smart poster may optionally contain:
    //  1+ Icon Records – MIME type image record
    //  a size record – used to tell how large referenced external entity is (ie size of pdf or mp3 the URI points to)
    //  a type record – declares Mime type of external entity
    //  Multiple other record types (it literally can be anything you want)
    // There is no special layout for a Smart Poster record type, the Message Payload is just a series of other messages.
    // You know you have reached the end of a smart poster when you have read in a number of bytes = Payload Length. This is
    // also how you distinguish sub-messages from each other, a whole lot of basic math.
    //  ______________________________
    // |       Message Header         |
    // |         Type = 'Sp'          |
    // |------------------------------|
    // |       Message Payload        |
    // |    ______________________    |
    // |   | sub-message1 header  |   | Could be a Text Record
    // |   |----------------------|   |
    // |   | sub-message1 payload |   |
    // |   |----------------------|   |
    // |                              |
    // |    ______________________    |
    // |   | sub-message2 header  |   | Could be a URI record
    // |   |----------------------|   |
    // |   | sub-message2 payload |   |
    // |   |----------------------|   |
    // |                              |
    // |    ______________________    |
    // |   | sub-message3 header  |   | Could be an Action record
    // |   |----------------------|   |
    // |   | sub-message3 payload |   |
    // |   |----------------------|   |
    // |                              |
    // |------------------------------|
    class func parseSmartPosterPayload(payloadBytes payLoadB: [CUnsignedChar], length ln: Int) -> Any? {
        var payloadTexts = [Any]()
        var header: VYNFCNDEFMessageHeader? = nil
        
        var length = ln
        var payloadBytes = payLoadB
        
        var payloadURI: IVYNFCNDEFURIPayload? = nil
        
        while true {
            
            header = VYNFCNDEFPayloadParser.parseMessageHeader(payloadBytes: payloadBytes, length: length)
            guard let header = header else { break }
            
            guard let payloadOffset = header.payloadOffset,
                let payloadLength = header.payloadLength else { continue }
            
            
            length -= payloadOffset
            payloadBytes = subArray(array: payloadBytes, from: payloadOffset, length: length)
            
            if header.type == "U" {
                // Parse URI payload.
                let _parsedPayload = VYNFCNDEFPayloadParser.parseURIPayload(payloadBytes: payloadBytes, length: payloadLength)
                guard let parsedPayload = _parsedPayload else {
                    return nil
                }
                
                payloadURI = (parsedPayload as! IVYNFCNDEFURIPayload)
                
            } else if header.type == "T" {
                // Parse text payload.
                let _parsedPayload = VYNFCNDEFPayloadParser.parseTextPayload(payloadBytes: payloadBytes, length: Int(payloadLength))
                guard let parsedPayload = _parsedPayload else {
                    return nil
                }
                payloadTexts.append(parsedPayload)
                
            } else {
                // Currently other records are not supported.
                return nil
            }
            length -= payloadLength
            payloadBytes = subArray(array: payloadBytes, from: Int(payloadLength), length: length)
            if let isMessageEnd = header.isMessageEnd, (isMessageEnd || length == 0) {
                break
            }
        }
        
        // Must have at least one text load.
        if payloadTexts.count == 0 {
            return nil
        }
        let smartPoster = VYNFCNDEFSmartPosterPayload(payloadURI: payloadURI, payloadTexts: payloadTexts)
        return smartPoster
    }
    
    // The fields in an NDEF Message header are as follows:
    //  ______________________________
    // | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0|
    // |------------------------------|
    // | MB| ME| CF| SR| IL|    TNF   |  NDEF StatusByte, 1 byte
    // |------------------------------|
    // |        TYPE_LENGTH           |  1 byte, hex value
    // |------------------------------|
    // |        PAYLOAD_LENGTH        |  1 or 4 bytes (determined by SR) (LSB first)
    // |------------------------------|
    // |        ID_LENGTH             |  0 or 1 bytes (determined by IL)
    // |------------------------------|
    // |        TYPE                  |  2 or 5 bytes (determined by TYPE_LENGTH)
    // |------------------------------|
    // |        ID                    |  0 or 1 byte  (determined by IL & ID_LENGTH) (Note by vince: maybe it could be longer.)
    // |------------------------------|
    // |        PAYLOAD               |  X bytes (determined by PAYLOAD_LENGTH)
    // |------------------------------|
    // NDEF Status Byte : size = 1byte : has multiple bit fields that contain meta data bout the rest of the header fields.
    //  MB : Message Begin flag
    //  ME : Message End flag
    //  CF : Chunk Flag (1 = Record is chunked up across multiple messages)
    //  SR : Short Record flag ( 1 = Record is contained in 1 message)
    //  IL : ID Length present flag ( 0 = ID field not present, 1 = present)
    //  TNF: Type Name Format code – one of the following
    //      0x00 : Empty
    //      0x01 : NFC Well Known Type [NFC RTD] (Use This One)
    //      0x02 : Media Type [RFC 2046]
    //      0x03 : Absolute URI [RFC 3986]
    //      0x04 : External Type [NFC RTD]
    //      0x05 : UnKnown
    //      0x06 : UnChanged
    //      0x07 : Reserved
    // TYPE_LENGTH : size = 1byte : contains the length in bytes of the TYPE field. Current NDEF standard dictates TYPE to be 2 or 5 bytes long.
    // PAYLOAD_LENGTH : size = 1 or 4 bytes (determined by StatusByte.SR field, if SR=1 then PAYLOAD_LENGTH is 1 byte, else 4 bytes) : contains the length in bytes of the NDEF message payload section.
    // ID_LENGTH : size = 1 byte : determines the size in bytes of the ID field. Typically 1 or 0. If 0 then there is no ID field.
    // TYPE : size =determined by TYPE_LENGTH : contains ASCII characters that determine the type of the message, used with the StatusByte.TNF section to determine the message type (ie a TNF of 0x01 for Well Known Type and a TYPE field of ‘T’ would tell us that the NDEF message payload is a Text record. A Type of “U” means URI, and a Type of “Sp” means SmartPoster).
    // ID : size = determined by ID_LENGTH field : holds unique identifier for the message. Usually used with message chunking to identify sections of data, or for custom implementations.
    // PAYLOAD : size = determined by PAYLOAD_LENGTH : contains the payload for the message. The payload is where the actual data transfer happens.
    class func parseMessageHeader(payloadBytes: [CUnsignedChar], length: Int) -> VYNFCNDEFMessageHeader? {
        if (length == 0) {
            return nil
        }
        
        var index = 0
        let header = VYNFCNDEFMessageHeader()
        
        // Parse status byte.
        let statusByte = CUnsignedChar(payloadBytes[index])
        index += 1
        header.isMessageBegin = (statusByte & 0x80) != 0
        header.isMessageEnd = (statusByte & 0x40) != 0
        header.isChunkedUp = (statusByte & 0x20) != 0
        header.isShortRecord = (statusByte & 0x10) != 0
        header.isIdentifierPresent = (statusByte & 0x08) != 0
        header.typeNameFormatCode = NFCTypeNameFormat.init(rawValue: UInt8(statusByte & 0x07)) ?? .empty
        
        // Parse type length.
        if (index + 1 > length) {
            return nil
        }
        let typeLength = CUnsignedChar(payloadBytes[index])
        index += 1
        // Parse payload length.
        if let isShortRecord = header.isShortRecord, (isShortRecord && UInt(index) + 1 > length) || (!isShortRecord && UInt(index) + 4 > length) {
            return nil
        }
        if let isShortRecord = header.isShortRecord, isShortRecord {
            header.payloadLength = Int(payloadBytes[index])
            index += 1
        } else {
            header.payloadLength = Int(payloadBytes[index])
            index += 4
        }
        
        // Parse ID length if ID is present.
        var identifierLength = 0
        if let isIdentifierPresent = header.isIdentifierPresent, isIdentifierPresent {
            if UInt(index) + 1 > length {
                return nil
            }
            identifierLength = Int(payloadBytes[index])
            index += 1
        }
        
        // Parse type.
        if (index + Int(typeLength) > length) {
            return nil
        }
        header.type = String(cString: subArray(array: payloadBytes, from: index, length: Int(typeLength)))//typeLength
        if header.type == nil {
            return nil
        }
        index += Int(typeLength)
        
        // Parse ID if ID is present.
        if (identifierLength > 0) {
            if Int(index) + 1 > Int(length) {
                return nil
            }
            header.identifer = Int(payloadBytes[index]) // Note by vince: maybe it could be longer.
            index += identifierLength
        }
        
        header.payloadOffset = index
        return header
    }
    
    // pragma mark - Parse Media Type
    class func parseTextXVCardPayload(payloadBytes: [CUnsignedChar], length: Int) -> Any? {
        let text = String(cString: subArray(array: payloadBytes, from: 0, length: length))
        if text.isEmpty {
            return nil
        }
        let payload = VYNFCNDEFTextXVCardPayload(text: text)
        return payload
    }
    
    
    static let CREDENTIAL: [CUnsignedChar] = [0x10, 0x0e]
    static let SSID: [CUnsignedChar] = [0x10, 0x45]
    static let MAC_ADDRESS: [CUnsignedChar] = [0x10, 0x20]
    static let NETWORK_INDEX: [CUnsignedChar] = [0x10, 0x26]
    static let NETWORK_KEY: [CUnsignedChar] = [0x10, 0x27]
    static let AUTH_TYPE: [CUnsignedChar] = [0x10, 0x03]
    static let ENCRYPT_TYPE: [CUnsignedChar] = [0x10, 0x0f]
    static let VENDOR_EXT: [CUnsignedChar] = [0x10, 0x49]
    
    static let VENDOR_ID_WFA: [CUnsignedChar] = [0x00, 0x37, 0x2a]
    static let WFA_VERSION2: [CUnsignedChar] = [0x00]
    
    static let AUTH_OPEN: [CUnsignedChar] = [0x00, 0x01]
    static let AUTH_WPA_PERSONAL: [CUnsignedChar] = [0x00, 0x02]
    static let AUTH_SHARED: [CUnsignedChar] = [0x00, 0x04]
    static let AUTH_WPA_ENTERPRISE: [CUnsignedChar] = [0x00, 0x08]
    static let AUTH_WPA2_ENTERPRISE: [CUnsignedChar] = [0x00, 0x10]
    static let AUTH_WPA2_PERSONAL: [CUnsignedChar] = [0x00, 0x20]
    static let AUTH_WPA_WPA2_PERSONAL: [CUnsignedChar] = [0x00, 0x22]
    
    static let ENCRYPT_NONE: [CUnsignedChar] = [0x00, 0x01]
    static let ENCRYPT_WEP: [CUnsignedChar] = [0x00, 0x02]
    static let ENCRYPT_TKIP: [CUnsignedChar] = [0x00, 0x04]
    static let ENCRYPT_AES: [CUnsignedChar] = [0x00, 0x08]
    static let ENCRYPT_AES_TKIP: [CUnsignedChar] = [0x00, 0x0C]
    
    // ----Attribute types and sizes defined for Wi-Fi Simple Configuration----
    // Description                      ID              Length
    // Credential                       0x100E          unlimited
    // SSID                             0x1045          <= 32B
    // MAC Address                      0x1020          6B
    // Network Index                    0x1026          1B
    // Network Key                      0x1027          <= 64B
    // Authentication Type              0x1003          2B
    // Encryption Type                  0x100F          2B
    // Vendor Extension                 0x1049          <= 1024B
    //
    class func parseWifiSimpleConfigPayload(payloadBytes: [CUnsignedChar], length: Int) -> Any? {
        if (length < 2) {
            return nil
        }
        
        var index = 0
        var credentials = [IVYNFCNDEFWifiSimpleConfigCredential]()
        var version2: IVYNFCNDEFWifiSimpleConfigVersion2?
        while index <= length - 2 {
            if (memcmp(UnsafePointer(payloadBytes)+index, VENDOR_EXT, 2) == 0) {
                // Parse vendor extension
                index += 2
                if (index + 2 > length) {
                    return nil
                }
                let ext_length = VYNFCNDEFPayloadParser.uint16FromBigEndian(payloadBytes, offset:index)
                index += 2
                version2 = VYNFCNDEFPayloadParser.parseWifiSimpleConfigVersion2(
                    payloadBytes: subArray(
                        array: payloadBytes,
                        from: index,
                        length: length-index),
                    length: ext_length
                )
                index += Int(ext_length)
                
            } else if (memcmp(UnsafePointer(payloadBytes)+index, CREDENTIAL, 2) == 0) {
                // Parse credential
                index += 2
                let credential_length = VYNFCNDEFPayloadParser.uint16FromBigEndian(payloadBytes, offset:index)
                index += 2
                let credential_ =
                    VYNFCNDEFPayloadParser.parseWifiSimpleConfigCredential(payloadBytes:subArray(array: payloadBytes, from: index, length: length-index), length: credential_length)
                guard let credential = credential_ else {
                    return nil
                }
                credentials.append(credential)
                index += Int(credential_length)
                
            } else {
                break
            }
        }
        
        let payload = VYNFCNDEFWifiSimpleConfigPayload(version2: version2)
        payload.credentials.append(contentsOf: credentials)
        return payload
    }
    
    class func parseWifiSimpleConfigCredential(payloadBytes: [CUnsignedChar], length: Int) -> VYNFCNDEFWifiSimpleConfigCredential? {
        
        if (length < 2) {
            return nil
        }
        
        var ssid: String? = nil
        
        var macAddress: String? = nil
        
        var networkIndex: UInt8? = nil
        
        var networkKey: String? = nil
        
        var authType: VYNFCNDEFWifiSimpleConfigAuthType? = nil
        
        var encryptType: VYNFCNDEFWifiSimpleConfigEncryptType? = nil
        
        
        var index = 0
        while (index <= length - 2) {
            if (memcmp(UnsafePointer(payloadBytes)+index, SSID, 2) == 0) {
                // Parse SSID
                index += 2
                let sublength = VYNFCNDEFPayloadParser.uint16FromBigEndian(payloadBytes, offset:index)
                index += 2
                let text = String(cString:subArray(array: payloadBytes, from: index, length: sublength)) //length:sublength
                if text.isEmpty {
                    return nil
                }
                ssid = text
                index += Int(sublength)
                
            } else if memcmp(UnsafePointer(payloadBytes)+index, MAC_ADDRESS, 2) == 0 {
                // Parse MAC address
                index += 2
                index += 2 // Skip length
                macAddress =
                    String(format:"%02x:%02x:%02x:%02x:%02x:%02x",
                           payloadBytes[index], payloadBytes[index+1], payloadBytes[index+2],
                           payloadBytes[index+3], payloadBytes[index+4], payloadBytes[index+5])
                index += 6
                
            } else if memcmp(UnsafePointer(payloadBytes)+index, NETWORK_INDEX, 2) == 0 {
                // Parse network index (there could be more than one network).
                index += 2
                let netIndex = payloadBytes[index]
                networkIndex = netIndex
                index += 1
                
            } else if memcmp(UnsafePointer(payloadBytes)+index, NETWORK_KEY, 2) == 0 {
                // Parse network key (password)
                index += 2
                let sublength = VYNFCNDEFPayloadParser.uint16FromBigEndian(payloadBytes, offset:index)
                index += 2
                let text = String(cString:subArray(array: payloadBytes, from: index, length: sublength)) //length:sublength
                if text.isEmpty {
                    return nil
                }
                networkKey = text
                index += sublength
                
            } else if memcmp(UnsafePointer(payloadBytes)+index, AUTH_TYPE, 2) == 0 {
                // Parse authentication type
                index += 2
                index += 2 // Skip length
                var type: VYNFCNDEFWifiSimpleConfigAuthType = .open
                if memcmp(UnsafePointer(payloadBytes)+index, AUTH_OPEN, 2) == 0 {
                    type = .open
                } else if memcmp(UnsafePointer(payloadBytes)+index, AUTH_WPA_PERSONAL, 2) == 0 {
                    type = .wpaPersonal
                } else if memcmp(UnsafePointer(payloadBytes)+index, AUTH_SHARED, 2) == 0 {
                    type = .shared
                } else if memcmp(UnsafePointer(payloadBytes)+index, AUTH_WPA_ENTERPRISE, 2) == 0 {
                    type = .wpaEnterprise
                } else if memcmp(UnsafePointer(payloadBytes)+index, AUTH_WPA2_ENTERPRISE, 2) == 0 {
                    type = .wpa2Enterprise
                } else if memcmp(UnsafePointer(payloadBytes)+index, AUTH_WPA2_PERSONAL, 2) == 0 {
                    type = .wpa2Personal
                } else if memcmp(UnsafePointer(payloadBytes)+index, AUTH_WPA_WPA2_PERSONAL, 2) == 0 {
                    type = .wpaWpa2Personal
                } else {
                    // Unhandled auth type.
                }
                authType = type
                index += 2
                
            } else
                if memcmp(UnsafePointer(payloadBytes)+index, ENCRYPT_TYPE, 2) == 0 {
                // Parse encryption type
                index += 2
                index += 2 // Skip length
                var type: VYNFCNDEFWifiSimpleConfigEncryptType = .none
                if memcmp(UnsafePointer(payloadBytes)+index, ENCRYPT_NONE, 2) == 0 {
                    type = .none
                } else if memcmp(UnsafePointer(payloadBytes)+index, ENCRYPT_WEP, 2) == 0 {
                    type = .wep
                } else if memcmp(UnsafePointer(payloadBytes)+index, ENCRYPT_TKIP, 2) == 0 {
                    type = .tkip
                } else if memcmp(UnsafePointer(payloadBytes)+index, ENCRYPT_AES, 2) == 0 {
                    type = .aes
                } else if memcmp(UnsafePointer(payloadBytes)+index, ENCRYPT_AES_TKIP, 2) == 0 {
                    type = .aesTkip
                } else {
                    // Unhandled encryption type.
                }
                encryptType = type
                index += 2
                
            } else { // Unknown attribute
                // In "Wi-Fi Simple Configuration Technical Specification v2.0.4", page 100 (Configuration Token
                // - Credential - Data Element Definitions), it says "Note: Unrecognized attributes in messages
                // shall beignored they shall not cause the message to be rejected."
                // Currently we found unknown attribute: 0x0101
                index += 2
            }
        }
        
        if ssid != nil, macAddress != nil, networkKey != nil {
            let credential = VYNFCNDEFWifiSimpleConfigCredential(ssid: ssid!, macAddress: macAddress!, networkIndex: networkIndex, networkKey: networkKey!, authType: authType, encryptType: encryptType)
            return credential
        } else {
            return nil
        }
        
    }
    
    class func subArray(array: [CUnsignedChar], from: Int, length: Int) -> [CUnsignedChar] {
        if length > 0, array.count-1 >= from+length-1 {
            var subArray = Array(array[from...from+length-1]) as [CUnsignedChar]
            subArray.append(0)
            return subArray
        }
        return [0]
    }
    // ---------------WFA Vendor Extension Subelements-------------------------
    // Description                      ID              Length
    // Version2                         0x00            1B
    // AuthorizedMACs                   0x01            <=30B
    // Network Key Shareable            0x02            Bool
    // Request to Enroll                0x03            Bool
    // Settings Delay Time              0x04            1B
    // Registrar Configuration  Methods 0x05            2B
    // Reserved for future use          0x06 to 0xFF
    
    // Version2 value: 0x20 = version 2.0, 0x21 = version 2.1, etc. Shall be included in protocol version 2.0 and higher.
    // If Version2 does not exist, assume version is "1.0h".
    class func parseWifiSimpleConfigVersion2(payloadBytes: [CUnsignedChar], length: Int) -> VYNFCNDEFWifiSimpleConfigVersion2? {
        var index = 0
        if (UInt(index) + 3 > length) {
            return nil
        }
        
        var version: String? = nil
        
        if memcmp(UnsafePointer(payloadBytes)+index, VENDOR_ID_WFA, 3) == 0 {
            // Parse vendor extension wfa
            index += 3
            if (UInt(index) + 1 > length) {
                return nil
            }
            if memcmp(UnsafePointer(payloadBytes)+index, WFA_VERSION2, 1) == 0 {
                index += 1
                // Parse Version2
                let ver2_length = payloadBytes[index]
                if (ver2_length != 1) {
                    return nil
                }
                index += 1
                let ver = payloadBytes[index]
                if ver == 0x20 {
                    version = "2.0"
                } else if ver == 0x21 {
                    version = "2.1"
                } else {
                    return nil
                }
                index += 1
            }
        }
        if version != nil {
            let version2 = VYNFCNDEFWifiSimpleConfigVersion2(version: version!)
            return version2
        } else {
            return nil
        }
        
    }
    
}
