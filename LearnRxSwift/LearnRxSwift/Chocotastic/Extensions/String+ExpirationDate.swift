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
  
  func rw_addSlash() -> String {
    guard self.characters.count > 2 else {
      //Nothing to add
      return self
    }
    
    let index2 = self.index(self.startIndex, offsetBy: 2)
    let firstTwo = self.substring(to: index2)
    let rest = self.substring(from: index2)
    
    return firstTwo + " / " + rest
  }
  
  func rw_removeSlash() -> String {
    let removedSpaces = self.rw_removeSpaces()
    return removedSpaces.replacingOccurrences(of: "/", with: "")
  }
  
  func rw_isValidExpirationDate() -> Bool {
    let noSlash = self.rw_removeSlash()
    
    guard noSlash.characters.count == 6 //Must be mmyyyy
      && noSlash.rw_allCharactersAreNumbers() else { //must be all numbers
        return false
    }
    
    let index2 = self.index(self.startIndex, offsetBy: 2)
    let monthString = self.substring(to: index2)
    let yearString = self.substring(from: index2)
    
    guard
      let month = Int(monthString),
      let year = Int(yearString) else {
        //We can't even check.
        return false
    }
    
    //Month must be between january and december.
    guard (month >= 1 && month <= 12) else {
      return false
    }
    
    let now = Date()
    let currentYear = now.rw_currentYear()
    
    guard year >= currentYear else {
      //Year is before current: Not valid.
      return false
    }
    
    if year == currentYear {
      let currentMonth = now.rw_currentMonth()
      guard month >= currentMonth else {
        //Month is before current in current year: Not valid.
        return false
      }
    }
    
    //If we made it here: Woo!
    return true
  }
}
