//
//  KitSwiftTests.swift
//  KitTests
//
//  Created by Vince Yuan on 7/8/17.
//  Copyright © 2017 Vince Yuan. All rights reserved.
//

import XCTest
import NFCSwift
import CoreNFC

class NFCSwiftTests: XCTestCase {
    
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
        let payloadEn = KitTestsHelper.correctTextPayloadEnglish()
        let parsedPayloadEnUntyped = NDEFPayloadParser.parse(payload: payloadEn)
        XCTAssertNotNil(parsedPayloadEnUntyped)
        XCTAssertTrue(parsedPayloadEnUntyped is NDEFTextPayload)
        let parsedPayloadEn = parsedPayloadEnUntyped as! NDEFTextPayload
        XCTAssertEqual(parsedPayloadEn.langCode, "en")
        XCTAssertEqual(parsedPayloadEn.text, "This is text.")
    }
    
    func testTextPayloadCN() {
        
        let payloadCn = KitTestsHelper.correctTextPayloadChinese()
        let parsedPayloadCnUntyped = NDEFPayloadParser.parse(payload: payloadCn)
        XCTAssertNotNil(parsedPayloadCnUntyped)
        XCTAssertTrue(parsedPayloadCnUntyped is NDEFTextPayload)
        let parsedPayloadCn = parsedPayloadCnUntyped as! NDEFTextPayload
        XCTAssertEqual(parsedPayloadCn.langCode, "cn")
        XCTAssertEqual(parsedPayloadCn.text, "你好hello")

    }

    func testURIPayload() {
        let payload = KitTestsHelper.correctURIPayload()
        let parsedPayloadUntyped = NDEFPayloadParser.parse(payload: payload)
        XCTAssertNotNil(parsedPayloadUntyped)
        XCTAssertTrue(parsedPayloadUntyped is NDEFURIPayload)
        let parsedPayload = parsedPayloadUntyped as! NDEFURIPayload
        XCTAssertEqual(parsedPayload.uriString, "https://example.com")
    }

    func testTextXVCardPayload() {
        let payload = KitTestsHelper.correctTextXVCardPayload()
        let parsedPayloadUntyped = NDEFPayloadParser.parse(payload: payload)
        XCTAssertNotNil(parsedPayloadUntyped)
        XCTAssertTrue(parsedPayloadUntyped is NDEFTextXVCardPayload)
        let parsedPayload = parsedPayloadUntyped as! NDEFTextXVCardPayload
        XCTAssertEqual(parsedPayload.text, "BEGIN:VCARD\r\nVERSION:2.1\r\nN:;香港客服;;;\r\nFN:香港客服\r\nTEL;CELL:+85221221188\r\nEND:VCARD")
    }

    func testTextSmartPosterPayloadPhoneNumber() {
        let payload = KitTestsHelper.correctSmartPosterPayloadPhoneNumber()
        let parsedPayloadUntyped = NDEFPayloadParser.parse(payload: payload)
        XCTAssertNotNil(parsedPayloadUntyped)
        XCTAssertTrue(parsedPayloadUntyped is NDEFSmartPosterPayload)
        let parsedPayload = parsedPayloadUntyped as! NDEFSmartPosterPayload
        XCTAssertNotNil(parsedPayload.payloadURI)
        XCTAssertEqual(parsedPayload.payloadURI!.uriString, "tel:5551236666")
        XCTAssertNotNil(parsedPayload.payloadTexts)
        XCTAssertEqual(parsedPayload.payloadTexts.count, 1)
        let textPayload = parsedPayload.payloadTexts.first as! NDEFTextPayload
        XCTAssertEqual(textPayload.isUTF16, false)
        XCTAssertEqual(textPayload.langCode, "en")
        XCTAssertEqual(textPayload.text, "Vince Yuan")
    }

    func testTextSmartPosterPayloadPhoneNumberLong() {
        let payload = KitTestsHelper.correctSmartPosterPayloadPhoneNumberLong()
        let parsedPayloadUntyped = NDEFPayloadParser.parse(payload: payload)
        XCTAssertNotNil(parsedPayloadUntyped)
        XCTAssertTrue(parsedPayloadUntyped is NDEFSmartPosterPayload)
        let parsedPayload = parsedPayloadUntyped as! NDEFSmartPosterPayload
        XCTAssertNotNil(parsedPayload.payloadURI)
        XCTAssertEqual(parsedPayload.payloadURI!.uriString, "tel:5551236666")
        XCTAssertNotNil(parsedPayload.payloadTexts)
        XCTAssertEqual(parsedPayload.payloadTexts.count, 1)
        let textPayload = parsedPayload.payloadTexts.first as! NDEFTextPayload
        XCTAssertEqual(textPayload.isUTF16, false)
        XCTAssertEqual(textPayload.langCode, "en")
        XCTAssertEqual(textPayload.text, "This phone number owner's name is very long and contains Hello World in simplified Chinese 你好世界")
    }

    func testTextSmartPosterPayloadGeoLocation() {
        let payload = KitTestsHelper.correctSmartPosterPayloadGeoLocation()
        let parsedPayloadUntyped = NDEFPayloadParser.parse(payload: payload)
        XCTAssertNotNil(parsedPayloadUntyped)
        XCTAssertTrue(parsedPayloadUntyped is NDEFSmartPosterPayload)
        let parsedPayload = parsedPayloadUntyped as! NDEFSmartPosterPayload
        XCTAssertNotNil(parsedPayload.payloadURI)
        XCTAssertEqual(parsedPayload.payloadURI!.uriString, "geo:1.351210,103.868856")
        XCTAssertNotNil(parsedPayload.payloadTexts)
        XCTAssertEqual(parsedPayload.payloadTexts.count, 1)
        let textPayload = parsedPayload.payloadTexts.first as! NDEFTextPayload
        XCTAssertEqual(textPayload.isUTF16, false)
        XCTAssertEqual(textPayload.langCode, "en")
        XCTAssertEqual(textPayload.text, "Singapore")
    }

    func testTextSmartPosterPayloadSms() {
        let payload = KitTestsHelper.correctSmartPosterPayloadSms()
        let parsedPayloadUntyped = NDEFPayloadParser.parse(payload: payload)
        XCTAssertNotNil(parsedPayloadUntyped)
        XCTAssertTrue(parsedPayloadUntyped is NDEFSmartPosterPayload)
        let parsedPayload = parsedPayloadUntyped as! NDEFSmartPosterPayload
        XCTAssertNotNil(parsedPayload.payloadURI)
        XCTAssertEqual(parsedPayload.payloadURI!.uriString, "sms:5551236666?body=This is a long text message with some simplifed Chinese characters 你好世界")
        XCTAssertNotNil(parsedPayload.payloadTexts)
        XCTAssertEqual(parsedPayload.payloadTexts.count, 1)
        let textPayload = parsedPayload.payloadTexts.first as! NDEFTextPayload
        XCTAssertEqual(textPayload.isUTF16, false)
        XCTAssertEqual(textPayload.langCode, "en")
        XCTAssertEqual(textPayload.text, "Description: send sms")
    }

    func testWifiSimpleConfigPayloadWith1Credential() {
        let payload = KitTestsHelper.correctWifiSimpleConfigPayloadWith1Credential()
        let parsedPayloadUntyped = NDEFPayloadParser.parse(payload: payload)
        XCTAssertNotNil(parsedPayloadUntyped)
        XCTAssertTrue(parsedPayloadUntyped is NDEFWifiSimpleConfigPayload)
        let parsedPayload = parsedPayloadUntyped as! NDEFWifiSimpleConfigPayload
        XCTAssertNotNil(parsedPayload.credentials)
        XCTAssertEqual(parsedPayload.credentials.count, 1)
        let credential = parsedPayload.credentials.first!
        XCTAssertEqual(credential.ssid, "MyWifiSSID")
        XCTAssertEqual(credential.macAddress, "ff:ff:ff:ff:ff:ff")
        XCTAssertEqual(credential.networkKey, "p@ssW0rd")
        XCTAssertEqual(credential.authType, NDEFWifiSimpleConfigAuthType.wpa2Personal)
        XCTAssertEqual(credential.encryptType, NDEFWifiSimpleConfigEncryptType.aes)
        XCTAssertNotNil(parsedPayload.version2)
        XCTAssertEqual(parsedPayload.version2!.version, "2.0")
    }

    func testWifiSimpleConfigPayloadWith2Credentials() {
        let payload = KitTestsHelper.correctWifiSimpleConfigPayloadWith2Credetnials()
        let parsedPayloadUntyped = NDEFPayloadParser.parse(payload: payload)
        XCTAssertNotNil(parsedPayloadUntyped)
        XCTAssertTrue(parsedPayloadUntyped is NDEFWifiSimpleConfigPayload)
        let parsedPayload = parsedPayloadUntyped as! NDEFWifiSimpleConfigPayload
        XCTAssertNotNil(parsedPayload.credentials)
        XCTAssertEqual(parsedPayload.credentials.count, 2)
        let credential0 = parsedPayload.credentials.first!
        XCTAssertEqual(credential0.ssid, "WLAN-X66666")
        XCTAssertEqual(credential0.macAddress, "c4:f0:81:83:0a:14")
        XCTAssertEqual(credential0.networkKey, "1358455229043333")
        XCTAssertEqual(credential0.authType, .wpa2Personal)
        XCTAssertEqual(credential0.encryptType, .aes)
        let credential1 = parsedPayload.credentials.last!
        XCTAssertEqual(credential1.ssid, "WLAN-X66666")
        XCTAssertEqual(credential1.macAddress, "c4:f0:81:83:0a:17")
        XCTAssertEqual(credential1.networkKey, "1358455229043333")
        XCTAssertEqual(credential1.authType, .wpa2Personal)
        XCTAssertEqual(credential1.encryptType, .aes)
        XCTAssertNil(parsedPayload.version2)
    }
    
}
