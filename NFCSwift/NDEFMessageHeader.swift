//
//  VYNFCNDEFMessageHeader.m
//  VYNFCKit
//
//  Created by Vince Yuan on 7/14/17.
//  Copyright © 2017 Vince Yuan. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//
import Foundation
import CoreNFC

class NDEFMessageHeader : NSObject {
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

