//
//  VYNFCKitSwiftTests.swift
//  VYNFCKitTests
//
//  Created by Vince Yuan on 7/8/17.
//  Copyright © 2017 Vince Yuan. All rights reserved.
//

import XCTest
import VYNFCKit
import CoreNFC

class VYNFCKitSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTextPayloadEN() {
        let payloadEn = VYNFCKitTestsHelper.correctTextPayloadEnglish()
        let parsedPayloadEnUntyped = VYNFCNDEFPayloadParser.parse(payload: payloadEn)
        XCTAssertNotNil(parsedPayloadEnUntyped)
        XCTAssertTrue(parsedPayloadEnUntyped is VYNFCNDEFTextPayload)
        let parsedPayloadEn = parsedPayloadEnUntyped as! VYNFCNDEFTextPayload
        XCTAssertEqual(parsedPayloadEn.langCode, "en")
        XCTAssertEqual(parsedPayloadEn.text, "This is text.")
    }
    
    func testTextPayloadCN() {
        
        let payloadCn = VYNFCKitTestsHelper.correctTextPayloadChinese()
        let parsedPayloadCnUntyped = VYNFCNDEFPayloadParser.parse(payload: payloadCn)
        XCTAssertNotNil(parsedPayloadCnUntyped)
        XCTAssertTrue(parsedPayloadCnUntyped is VYNFCNDEFTextPayload)
        let parsedPayloadCn = parsedPayloadCnUntyped as! VYNFCNDEFTextPayload
        XCTAssertEqual(parsedPayloadCn.langCode, "cn")
        XCTAssertEqual(parsedPayloadCn.text, "你好hello")

    }

    func testURIPayload() {
        let payload = VYNFCKitTestsHelper.correctURIPayload()
        let parsedPayloadUntyped = VYNFCNDEFPayloadParser.parse(payload: payload)
        XCTAssertNotNil(parsedPayloadUntyped)
        XCTAssertTrue(parsedPayloadUntyped is VYNFCNDEFURIPayload)
        let parsedPayload = parsedPayloadUntyped as! VYNFCNDEFURIPayload
        XCTAssertEqual(parsedPayload.uriString, "https://example.com")
    }

    func testTextXVCardPayload() {
        let payload = VYNFCKitTestsHelper.correctTextXVCardPayload()
        let parsedPayloadUntyped = VYNFCNDEFPayloadParser.parse(payload: payload)
        XCTAssertNotNil(parsedPayloadUntyped)
        XCTAssertTrue(parsedPayloadUntyped is VYNFCNDEFTextXVCardPayload)
        let parsedPayload = parsedPayloadUntyped as! VYNFCNDEFTextXVCardPayload
        XCTAssertEqual(parsedPayload.text, "BEGIN:VCARD\r\nVERSION:2.1\r\nN:;香港客服;;;\r\nFN:香港客服\r\nTEL;CELL:+85221221188\r\nEND:VCARD")
    }

    func testTextSmartPosterPayloadPhoneNumber() {
        let payload = VYNFCKitTestsHelper.correctSmartPosterPayloadPhoneNumber()
        let parsedPayloadUntyped = VYNFCNDEFPayloadParser.parse(payload: payload)
        XCTAssertNotNil(parsedPayloadUntyped)
        XCTAssertTrue(parsedPayloadUntyped is VYNFCNDEFSmartPosterPayload)
        let parsedPayload = parsedPayloadUntyped as! VYNFCNDEFSmartPosterPayload
        XCTAssertNotNil(parsedPayload.payloadURI)
        XCTAssertEqual(parsedPayload.payloadURI!.uriString, "tel:5551236666")
        XCTAssertNotNil(parsedPayload.payloadTexts)
        XCTAssertEqual(parsedPayload.payloadTexts.count, 1)
        let textPayload = parsedPayload.payloadTexts.first as! VYNFCNDEFTextPayload
        XCTAssertEqual(textPayload.isUTF16, false)
        XCTAssertEqual(textPayload.langCode, "en")
        XCTAssertEqual(textPayload.text, "Vince Yuan")
    }

    func testTextSmartPosterPayloadPhoneNumberLong() {
        let payload = VYNFCKitTestsHelper.correctSmartPosterPayloadPhoneNumberLong()
        let parsedPayloadUntyped = VYNFCNDEFPayloadParser.parse(payload: payload)
        XCTAssertNotNil(parsedPayloadUntyped)
        XCTAssertTrue(parsedPayloadUntyped is VYNFCNDEFSmartPosterPayload)
        let parsedPayload = parsedPayloadUntyped as! VYNFCNDEFSmartPosterPayload
        XCTAssertNotNil(parsedPayload.payloadURI)
        XCTAssertEqual(parsedPayload.payloadURI!.uriString, "tel:5551236666")
        XCTAssertNotNil(parsedPayload.payloadTexts)
        XCTAssertEqual(parsedPayload.payloadTexts.count, 1)
        let textPayload = parsedPayload.payloadTexts.first as! VYNFCNDEFTextPayload
        XCTAssertEqual(textPayload.isUTF16, false)
        XCTAssertEqual(textPayload.langCode, "en")
        XCTAssertEqual(textPayload.text, "This phone number owner's name is very long and contains Hello World in simplified Chinese 你好世界")
    }

    func testTextSmartPosterPayloadGeoLocation() {
        let payload = VYNFCKitTestsHelper.correctSmartPosterPayloadGeoLocation()
        let parsedPayloadUntyped = VYNFCNDEFPayloadParser.parse(payload: payload)
        XCTAssertNotNil(parsedPayloadUntyped)
        XCTAssertTrue(parsedPayloadUntyped is VYNFCNDEFSmartPosterPayload)
        let parsedPayload = parsedPayloadUntyped as! VYNFCNDEFSmartPosterPayload
        XCTAssertNotNil(parsedPayload.payloadURI)
        XCTAssertEqual(parsedPayload.payloadURI!.uriString, "geo:1.351210,103.868856")
        XCTAssertNotNil(parsedPayload.payloadTexts)
        XCTAssertEqual(parsedPayload.payloadTexts.count, 1)
        let textPayload = parsedPayload.payloadTexts.first as! VYNFCNDEFTextPayload
        XCTAssertEqual(textPayload.isUTF16, false)
        XCTAssertEqual(textPayload.langCode, "en")
        XCTAssertEqual(textPayload.text, "Singapore")
    }

    func testTextSmartPosterPayloadSms() {
        let payload = VYNFCKitTestsHelper.correctSmartPosterPayloadSms()
        let parsedPayloadUntyped = VYNFCNDEFPayloadParser.parse(payload: payload)
        XCTAssertNotNil(parsedPayloadUntyped)
        XCTAssertTrue(parsedPayloadUntyped is VYNFCNDEFSmartPosterPayload)
        let parsedPayload = parsedPayloadUntyped as! VYNFCNDEFSmartPosterPayload
        XCTAssertNotNil(parsedPayload.payloadURI)
        XCTAssertEqual(parsedPayload.payloadURI!.uriString, "sms:5551236666?body=This is a long text message with some simplifed Chinese characters 你好世界")
        XCTAssertNotNil(parsedPayload.payloadTexts)
        XCTAssertEqual(parsedPayload.payloadTexts.count, 1)
        let textPayload = parsedPayload.payloadTexts.first as! VYNFCNDEFTextPayload
        XCTAssertEqual(textPayload.isUTF16, false)
        XCTAssertEqual(textPayload.langCode, "en")
        XCTAssertEqual(textPayload.text, "Description: send sms")
    }

    func testWifiSimpleConfigPayloadWith1Credential() {
        let payload = VYNFCKitTestsHelper.correctWifiSimpleConfigPayloadWith1Credential()
        let parsedPayloadUntyped = VYNFCNDEFPayloadParser.parse(payload: payload)
        XCTAssertNotNil(parsedPayloadUntyped)
        XCTAssertTrue(parsedPayloadUntyped is VYNFCNDEFWifiSimpleConfigPayload)
        let parsedPayload = parsedPayloadUntyped as! VYNFCNDEFWifiSimpleConfigPayload
        XCTAssertNotNil(parsedPayload.credentials)
        XCTAssertEqual(parsedPayload.credentials.count, 1)
        let credential = parsedPayload.credentials.first as! VYNFCNDEFWifiSimpleConfigCredential
        XCTAssertEqual(credential.ssid, "MyWifiSSID")
        XCTAssertEqual(credential.macAddress, "ff:ff:ff:ff:ff:ff")
        XCTAssertEqual(credential.networkKey, "p@ssW0rd")
        XCTAssertEqual(credential.authType, VYNFCNDEFWifiSimpleConfigAuthType.wpa2Personal)
        XCTAssertEqual(credential.encryptType, VYNFCNDEFWifiSimpleConfigEncryptType.aes)
        XCTAssertNotNil(parsedPayload.version2)
        XCTAssertEqual(parsedPayload.version2!.version, "2.0")
    }

    func testWifiSimpleConfigPayloadWith2Credentials() {
        let payload = VYNFCKitTestsHelper.correctWifiSimpleConfigPayloadWith2Credetnials()
        let parsedPayloadUntyped = VYNFCNDEFPayloadParser.parse(payload: payload)
        XCTAssertNotNil(parsedPayloadUntyped)
        XCTAssertTrue(parsedPayloadUntyped is VYNFCNDEFWifiSimpleConfigPayload)
        let parsedPayload = parsedPayloadUntyped as! VYNFCNDEFWifiSimpleConfigPayload
        XCTAssertNotNil(parsedPayload.credentials)
        XCTAssertEqual(parsedPayload.credentials.count, 2)
        let credential0 = parsedPayload.credentials.first as! VYNFCNDEFWifiSimpleConfigCredential
        XCTAssertEqual(credential0.ssid, "WLAN-X66666")
        XCTAssertEqual(credential0.macAddress, "c4:f0:81:83:0a:14")
        XCTAssertEqual(credential0.networkKey, "1358455229043333")
        XCTAssertEqual(credential0.authType, .wpa2Personal)
        XCTAssertEqual(credential0.encryptType, .aes)
        let credential1 = parsedPayload.credentials.last as! VYNFCNDEFWifiSimpleConfigCredential
        XCTAssertEqual(credential1.ssid, "WLAN-X66666")
        XCTAssertEqual(credential1.macAddress, "c4:f0:81:83:0a:17")
        XCTAssertEqual(credential1.networkKey, "1358455229043333")
        XCTAssertEqual(credential1.authType, .wpa2Personal)
        XCTAssertEqual(credential1.encryptType, .aes)
        XCTAssertNil(parsedPayload.version2)
    }
    
}
