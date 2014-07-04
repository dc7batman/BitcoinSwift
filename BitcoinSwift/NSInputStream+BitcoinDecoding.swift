//
//  NSInputStream+BitcoinDecoding.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

extension NSInputStream {

  func readUInt32(endianness: Endianness = .LittleEndian) -> UInt32? {
    var readBuffer = Array<UInt8>(count:sizeof(UInt32), repeatedValue:0)
    let numberOfBytesRead = self.read(&readBuffer, maxLength:readBuffer.count)
    if numberOfBytesRead != sizeof(UInt32) {
      return nil
    }
    var int: UInt32 = 0
    for i in 0..sizeof(UInt32) {
      switch endianness {
        case .LittleEndian:
          int |= UInt32(readBuffer[i]) << UInt32(i * 8)
        case .BigEndian:
          int |= UInt32(readBuffer[i]) << UInt32((sizeof(UInt32) - 1 - i) * 8)
      }
    }
    return int
  }

  func readASCIIStringWithLength(var length:Int) -> String? {
    var readBuffer = Array<UInt8>(count:length, repeatedValue:0)
    let numberOfBytesRead = self.read(&readBuffer, maxLength:readBuffer.count)
    if numberOfBytesRead != length {
      return nil
    }
    // Remove the trailing 0's or else the string has a bunch of garbage at the end of it.
    for var i = numberOfBytesRead - 1; i >= 0; --i {
      if readBuffer[i] != 0 {
        break
      }
      --length
    }
    return NSString(bytes:readBuffer, length:length, encoding:NSASCIIStringEncoding)
  }

  // Reads the number of bytes provided by |length|, or the rest of the remaining bytes if length
  // is not provided.
  // Returns nil if there is no data remaining to parse, or if parsing fails for another reason.
  func readData(var length: Int = 0) -> NSData? {
    let data = NSMutableData()
    var readBuffer = Array<UInt8>(count:256, repeatedValue:0)
    if length == 0 {
      while hasBytesAvailable {
        var numberOfBytesRead = self.read(&readBuffer, maxLength:readBuffer.count)
        if numberOfBytesRead == 0 {
          return nil
        }
        data.appendBytes(readBuffer[0..numberOfBytesRead], length:numberOfBytesRead)
      }
    } else {
      while hasBytesAvailable && length > 0 {
        let numberOfBytesToRead = min(length, readBuffer.count)
        var numberOfBytesRead = self.read(&readBuffer, maxLength:numberOfBytesToRead)
        if numberOfBytesRead != numberOfBytesToRead {
          return nil
        }
        data.appendBytes(readBuffer[0..numberOfBytesRead], length:numberOfBytesRead)
        length -= numberOfBytesRead
      }
    }
    return data
  }
}