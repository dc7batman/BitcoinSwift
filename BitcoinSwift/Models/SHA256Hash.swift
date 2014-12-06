//
//  SHA256Hash.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 12/6/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: SHA256Hash, rhs: SHA256Hash) -> Bool {
  return lhs.data == rhs.data
}

public struct SHA256Hash: Equatable {

  public let data: NSData

  public init(data: NSData) {
    precondition(data.length == 32)
    self.data = data
  }
}

extension SHA256Hash: BitcoinSerializable {

  public var bitcoinData: NSData {
    // Hashes are encoded little-endian on the wire.
    return data.reversedData
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> SHA256Hash? {
    let hashData = stream.readData(length: 32)
    if hashData == nil {
      Logger.warn("Failed to parse hashData from SHA256Hash")
      return nil
    }
    // Hashes are encoded little-endian on the wire.
    return SHA256Hash(data: hashData!.reversedData)
  }
}