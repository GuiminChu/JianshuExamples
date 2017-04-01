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
import RxSwift
import RxCocoa

class BillingInfoViewController: UIViewController {
  
    @IBOutlet private var creditCardNumberTextField: ValidatingTextField!
    @IBOutlet private var creditCardImageView: UIImageView!
    @IBOutlet private var expirationDateTextField: ValidatingTextField!
    @IBOutlet private var cvvTextField: ValidatingTextField!
    @IBOutlet private var purchaseButton: UIButton!
  
    private let cardType: Variable<CardType> = Variable(.Unknown)
    private let disposeBag = DisposeBag()
    private let throttleInterval = 0.1
  
  // MARK: - View Lifecycle
  
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "💳 Info"
        
        setupCardImageDisplay()
        setupTextChangeHandling()
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = identifierForSegue(segue: segue)
        switch identifier {
        case .PurchaseSuccess:
            guard let destination = segue.destination as? ChocolateIsComingViewController else {
                assertionFailure("Couldn't get chocolate is coming VC!")
                return
            }
      
            destination.cardType = cardType.value
        }
    }
  
    // MARK: - RX Setup
    
    private func setupCardImageDisplay() {
        cardType.asObservable().subscribe(onNext: { [weak self] cardType in
            self?.creditCardImageView.image = cardType.image
        }).addDisposableTo(disposeBag)
    }
  
    private func setupTextChangeHandling() {
        let creditCardValid = creditCardNumberTextField.rx.text.throttle(throttleInterval, scheduler: MainScheduler.instance).map({ self.validate(cardText: $0!) })
        creditCardValid.subscribe(onNext: { valid in
            self.creditCardNumberTextField.valid = valid
        }).addDisposableTo(disposeBag)
        
        let expirationValid = expirationDateTextField.rx.text.throttle(throttleInterval, scheduler: MainScheduler.instance).map({ self.validate(expirationDateText: $0!) })
        expirationValid.subscribe(onNext: { valid in
            self.expirationDateTextField.valid = valid
        }).addDisposableTo(disposeBag)
        
        let cvvValid = cvvTextField.rx.text.map { self.validate(cvvText: $0!) }
        cvvValid.subscribe(onNext: { self.cvvTextField.valid = $0 }).addDisposableTo(disposeBag)
        
        let everythingValid = Observable.combineLatest(creditCardValid, expirationValid, cvvValid) { $0 && $1 && $2 }
        everythingValid.bindTo(purchaseButton.rx.isEnabled).addDisposableTo(disposeBag)
    }

  //MARK: - Validation methods
  
  func validate(cardText: String) -> Bool {
    let noWhitespace = cardText.rw_removeSpaces()
    
    updateCardType(using: noWhitespace)
    formatCardNumber(using: noWhitespace)
    advanceIfNecessary(noSpacesCardNumber: noWhitespace)
    
    guard cardType.value != .Unknown else {
      //Definitely not valid if the type is unknown.
      return false
    }
    
    guard noWhitespace.rw_isLuhnValid() else {
      //Failed luhn validation
      return false
    }
    
    return noWhitespace.characters.count == self.cardType.value.expectedDigits
  }
  
  func validate(expirationDateText expiration: String) -> Bool {
    let strippedSlashExpiration = expiration.rw_removeSlash()
    
    formatExpirationDate(using: strippedSlashExpiration)
    advanceIfNecessary(expirationNoSpacesOrSlash:  strippedSlashExpiration)
    
    return strippedSlashExpiration.rw_isValidExpirationDate()
  }
  
  func validate(cvvText cvv: String) -> Bool {
    guard cvv.rw_allCharactersAreNumbers() else {
      //Someone snuck a letter in here.
      return false
    }
    dismissIfNecessary(cvv: cvv)
    return cvv.characters.count == self.cardType.value.cvvDigits
  }
  
  //MARK: Single-serve helper functions
  
  private func updateCardType(using noSpacesNumber: String) {
    cardType.value = CardType.fromString(string: noSpacesNumber)
  }
  
  private func formatCardNumber(using noSpacesCardNumber: String) {
    creditCardNumberTextField.text = self.cardType.value.format(noSpaces: noSpacesCardNumber)
  }
  
  func advanceIfNecessary(noSpacesCardNumber: String) {
    if noSpacesCardNumber.characters.count == self.cardType.value.expectedDigits {
      self.expirationDateTextField.becomeFirstResponder()
    }
  }
  
  func formatExpirationDate(using expirationNoSpacesOrSlash: String) {
    expirationDateTextField.text = expirationNoSpacesOrSlash.rw_addSlash()
  }
  
  func advanceIfNecessary(expirationNoSpacesOrSlash: String) {
    if expirationNoSpacesOrSlash.characters.count == 6 { //mmyyyy
      self.cvvTextField.becomeFirstResponder()
    }
  }
  
  func dismissIfNecessary(cvv: String) {
    if cvv.characters.count == self.cardType.value.cvvDigits {
      let _ = self.cvvTextField.resignFirstResponder()
    }
  }
}

// MARK: - SegueHandler 
extension BillingInfoViewController: SegueHandler {
    enum SegueIdentifier: String {
        case PurchaseSuccess
    }
}
