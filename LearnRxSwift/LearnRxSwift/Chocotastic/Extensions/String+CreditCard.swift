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
import Foundation

extension String {
  
  func rw_allCharactersAreNumbers() -> Bool {
    let nonNumberCharacterSet = NSCharacterSet.decimalDigits.inverted
    return (self.rangeOfCharacter(from: nonNumberCharacterSet) == nil)
  }
  
  
  func rw_integerValueOfFirst(characters: Int) -> Int {
    guard rw_allCharactersAreNumbers() else {
      return NSNotFound
    }
    
    if characters > self.characters.count {
      return NSNotFound
    }
    
    let indexToStopAt = self.index(self.startIndex, offsetBy: characters)
    let substring = self.substring(to: indexToStopAt)
    guard let integerValue = Int(substring) else {
      return NSNotFound
    }
    
    return integerValue
  }
  
  
  func rw_isLuhnValid() -> Bool {
    //https://www.rosettacode.org/wiki/Luhn_test_of_credit_card_numbers
    
    guard self.rw_allCharactersAreNumbers() else {
      //Definitely not valid.
      return false
    }
    
    let reversed = self.characters.reversed().map { String($0) }
    
    var sum = 0
    for (index, element) in reversed.enumerated() {
      guard let digit = Int(element) else {
        //This is not a number.
        return false
      }
      
      if index % 2 == 1 {
        //Even digit
        switch digit {
        case 9:
          //Just add nine.
          sum += 9
        default:
          //Multiply by 2, then take the remainder when divided by 9 to get addition of digits.
          sum += ((digit * 2) % 9)
        }
      } else {
        //Odd digit
        sum += digit
      }
    }
    
    //Valid if divisible by 10
    return sum % 10 == 0
  }
  
  func rw_removeSpaces() -> String {
    return self.replacingOccurrences(of: " ", with: "")
  }
}
