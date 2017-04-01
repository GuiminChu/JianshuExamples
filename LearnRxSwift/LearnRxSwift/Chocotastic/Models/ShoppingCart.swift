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
import RxSwift

class ShoppingCart {
  
    // 单例
    static let sharedCart = ShoppingCart()
  
    // var chocolates = [Chocolate]()
    let chocolates: Variable<[Chocolate]> = Variable([])
  
    // MARK: Non-Mutating Functions
  
    func totalCost() -> Float {
        return chocolates.value.reduce(0) {
            runningTotal, chocolate in
            return runningTotal + chocolate.priceInDollars
        }
    }
  
    func itemCountString() -> String {
        guard chocolates.value.count > 0 else {
            return "🚫🍫"
        }
    
    // Unique the chocolates
    let setOfChocolates = Set<Chocolate>(chocolates.value)
    
    // Check how many of each exists
    let itemStrings: [String] = setOfChocolates.map { chocolate in
        
        let count: Int = chocolates.value.reduce(0) { runningTotal, reduceChocolate in
            if chocolate == reduceChocolate {
                return runningTotal + 1
            }
        
            return runningTotal
        }
        return "\(chocolate.countryFlagEmoji)🍫: \(count)"
    }
        return itemStrings.joined(separator: "\n")
    }
}
