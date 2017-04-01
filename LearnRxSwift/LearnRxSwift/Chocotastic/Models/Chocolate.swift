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

// MARK: - Equatable Protocol implementation

func ==(lhs: Chocolate, rhs: Chocolate) -> Bool {
    return (lhs.countryName == rhs.countryName
        && lhs.priceInDollars == rhs.priceInDollars
        && lhs.countryFlagEmoji == rhs.countryFlagEmoji)
}

// MARK: - Mmmm...chocolate...

struct Chocolate: Equatable {
    let priceInDollars: Float
    let countryName: String
    let countryFlagEmoji: String
  
    // An array of chocolate from europe
    static let ofEurope: [Chocolate] = {
        let belgian = Chocolate(priceInDollars: 8, countryName: "Belgium", countryFlagEmoji: "🇧🇪")
        let british = Chocolate(priceInDollars: 7, countryName: "Great Britain", countryFlagEmoji: "🇬🇧")
        let dutch   = Chocolate(priceInDollars: 8, countryName: "The Netherlands", countryFlagEmoji: "🇳🇱")
        let german  = Chocolate(priceInDollars: 7, countryName: "Germany", countryFlagEmoji: "🇩🇪")
        let swiss   = Chocolate(priceInDollars: 10, countryName: "Switzerland", countryFlagEmoji: "🇨🇭")
    
        return [belgian, british, dutch, german, swiss]
    }()
}

extension Chocolate: Hashable {
    var hashValue: Int {
        return self.countryFlagEmoji.hashValue
    }
}
