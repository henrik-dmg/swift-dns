//
//  DNSHeader.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

//#[derive(Clone, Debug)]
//pub struct DnsHeader {
//    pub id: u16, // 16 bits
//
//    pub recursion_desired: bool,    // 1 bit
//    pub truncated_message: bool,    // 1 bit
//    pub authoritative_answer: bool, // 1 bit
//    pub opcode: u8,                 // 4 bits
//    pub response: bool,             // 1 bit
//
//    pub rescode: ResultCode,       // 4 bits
//    pub checking_disabled: bool,   // 1 bit
//    pub authed_data: bool,         // 1 bit
//    pub z: bool,                   // 1 bit
//    pub recursion_available: bool, // 1 bit
//
//    pub questions: u16,             // 16 bits
//    pub answers: u16,               // 16 bits
//    pub authoritative_entries: u16, // 16 bits
//    pub resource_entries: u16,      // 16 bits
//}

public struct DNSHeader {

    public let id: UInt16
    public let isRecursionDesired: Bool
    public let isMessageTruncated: Bool
    public let isAnswerAuthorative: Bool
    public let opCode: UInt8
    public let isResponse: Bool

    public let resultCode: DNSResultCode
    public let isCheckingDisabled: Bool
    public let isAuthedData: Bool
    public let z: Bool // I dont know what this is
    public let isRecursionAvailable: Bool

    public let numberOfQuestions: UInt16
    public let numberOfAnswers: UInt16
    public let numberOfAuthorativeEntries: UInt16
    public let numberOfResourceEntries: UInt16

}
