/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

enum CardType {
  case Unknown, Amex, Mastercard, Visa, Discover
  
  //https://en.wikipedia.org/wiki/Payment_card_number
  static func fromString(string: String) -> CardType {
    if string.isEmpty {
      //We definitely can't determine from an empty string.
      return .Unknown
    }
    
    guard string.rw_allCharactersAreNumbers() else {
      assertionFailure("One of these characters is not a number!")
      return .Unknown
    }
    
    //Visa: Starts with 4
    //Mastercard: Starts with 2221-2720 or 51-55
    //Amex: Starts with 34 or 37
    //Discover: Starts with 6011, 622126-622925, 644-649, or 65
    
    
    if string.hasPrefix("4") {
      //If the first # is a 4, it's a visa
      return .Visa
    } //Else, we need more info, keep going
    
    
    let firstTwo = string.rw_integerValueOfFirst(characters: 2)
    guard firstTwo != NSNotFound else {
      return .Unknown
    }
    
    switch firstTwo {
    case 51...55:
      return .Mastercard
    case 65:
      return .Discover
    case 34, 37:
      return .Amex
    default:
      //Can't determine type yet
      break
    }
    
    let firstThree = string.rw_integerValueOfFirst(characters: 3)
    guard firstThree != NSNotFound else {
      return .Unknown
    }
    
    switch firstThree {
    case 644...649:
      return .Discover
    default:
      //Can't determine type yet
      break
    }
    
    
    let firstFour = string.rw_integerValueOfFirst(characters: 4)
    guard firstFour != NSNotFound else {
      return .Unknown
    }
    
    switch firstFour {
    case 2221...2720:
      return .Mastercard
    case 6011:
      return .Discover
    default:
      //Can't determine type yet
      break
    }
    
    let firstSix = string.rw_integerValueOfFirst(characters: 6)
    guard firstSix != NSNotFound else {
      return .Unknown
    }
    
    switch firstSix {
    case 622126...622925:
      return .Discover
    default:
      //If we've gotten here, ¯\_(ツ)_/¯
      return .Unknown
    }
  }
  
  var expectedDigits: Int {
    switch self {
    case .Amex:
      return 15
    default:
      return 16
    }
  }
  
  var image: UIImage {
    switch self {
    case .Amex:
      return ImageName.Amex.image
    case .Discover:
      return ImageName.Discover.image
    case .Mastercard:
      return ImageName.Mastercard.image
    case .Visa:
      return ImageName.Visa.image
    case .Unknown:
      return ImageName.UnknownCard.image
    }
  }
  
  var cvvDigits: Int {
    switch self {
    case .Amex:
      return 4
    default:
      return 3
    }
  }
  
  func format(noSpaces: String) -> String {
    guard noSpaces.characters.count >= 4 else {
      //No formatting necessary if <= 4
      return noSpaces
    }
    
    
    let startIndex = noSpaces.startIndex

    
    let index4 = noSpaces.index(startIndex, offsetBy: 4)
    //All cards start with four digits before the get to spaces
    let firstFour = noSpaces.substring(to: index4)
    var formattedString = firstFour + " "
    
    switch self {
    case .Amex:
      //Amex format is xxxx xxxxxx xxxxx
      guard noSpaces.characters.count > 10 else {
        //No further formatting required.
        return formattedString + noSpaces.substring(from: index4)
      }
      
      
      let index10 = noSpaces.index(startIndex, offsetBy: 10)
      let nextSixRange = Range(index4..<index10)
      let nextSix = noSpaces.substring(with: nextSixRange)
      let remaining = noSpaces.substring(from: index10)
      return formattedString + nextSix + " " + remaining
    default:
      //Other cards are formatted as xxxx xxxx xxxx xxxx
      guard noSpaces.characters.count > 8 else {
        //No further formatting required.
        return formattedString + noSpaces.substring(from: index4)
      }
      
      let index8 = noSpaces.index(startIndex, offsetBy: 8)
      let nextFourRange = Range(index4..<index8)
      let nextFour = noSpaces.substring(with: nextFourRange)
      formattedString += nextFour + " "
      
      guard noSpaces.characters.count > 12 else {
        //Just add the remaining spaces
        let remaining = noSpaces.substring(from: index8)
        return formattedString + remaining
      }
      
      let index12 = noSpaces.index(startIndex, offsetBy: 12)
      let followingFourRange = Range(index8..<index12)
      let followingFour = noSpaces.substring(with: followingFourRange)
      let remaining = noSpaces.substring(from: index12)
      return formattedString + followingFour + " " + remaining
    }
  }
}
