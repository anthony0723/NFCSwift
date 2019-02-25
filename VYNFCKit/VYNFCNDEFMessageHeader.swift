//
//  VYNFCNDEFMessageHeader.swift
//  VYNFCKit
//
//  Created by Ahmed Adouani on 25/02/2019.
//  Copyright © 2019 Vince Yuan. All rights reserved.
//

import Foundation
import CoreNFC

class VYNFCNDEFMessageHeader : NSObject {
    var isMessageBegin: Bool?
    var isMessageEnd: Bool?
    var isChunkedUp: Bool?
    var isShortRecord: Bool?
    var isIdentifierPresent: Bool?
    var typeNameFormatCode: NFCTypeNameFormat = .unknown
    
    var type: String?
    var identifer: Int?
    var payloadLength: Int?
    
    var payloadOffset: Int? // Length of parsed bytes before payload
}

