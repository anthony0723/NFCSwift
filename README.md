# NFCSwift

NFCSwift is an iOS library used to parse Near Field Communication (NFC) NDEF message payload.

NDEF (NFC Data Exchange Format) is a standardized data format specification by the NFC Forum which is used to describe how a set of actions are to be encoded onto a NFC tag or to be exchanged between two active NFC devices. The vast majority of NFC enabled devices (readers, phones, tablets…) support reading NDEF messages from NFC tags. On iPhone 7 and iPhone 7 plus with iOS 11, the third-party apps can read NFC tags. _Using Core NFC, you can read Near Field Communication (NFC) tags of types 1 through 5 that contain data in the NFC Data Exchange Format (NDEF)._ An NDEF message consists of header and payload. Core NFC parses message header, but does not parse message payload. This library **NFCSwift** parses NFC NDEF message payload for you. 
