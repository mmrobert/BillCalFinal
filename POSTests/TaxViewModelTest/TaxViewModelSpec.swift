//
//  TaxViewModelTest.swift
//  POSTests
//
//  Created by boqian cheng on 2019-07-08.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import Foundation

import Quick
import Nimble

@testable import POS

class TaxViewModelSpec: QuickSpec {
    
    let taxViewModel = TaxViewModel()
    
    override func spec() {
        describe("Tax view model testing") {
            
            beforeEach {
                for i in 0..<taxes.count {
                    taxes[i].isEnabled = true
                }
            }
            
            context("for tax table loading.") {
                it("Return section title string:") {
                    expect(self.taxViewModel.title(for: 0)).to(equal("Taxes"))
                }
                it("Return number of sections - only 1 section:") {
                    expect(self.taxViewModel.numberOfSections()).to(equal(1))
                }
                it("Return number of taxes:") {
                    expect(self.taxViewModel.numberOfRows(in: 0)).to(equal(taxes.count))
                }
                it("Return label string for a tax:") {
                    let indexP = IndexPath(row: 1, section: 0)
                    expect(self.taxViewModel.labelForTax(at: indexP)).to(equal("Tax 2 (8%)"))
                }
            }
            
            context("for toggling tax to check or uncheck it.") {
                let indexP = IndexPath(row: 1, section: 0)
                it("Initial condition, which is checked:") {
                    expect(self.taxViewModel.accessoryType(at: indexP)).to(equal(.checkmark))
                }
                it("Become unchecked when toggled one time:") {
                    self.taxViewModel.toggleTax(at: indexP)
                    expect(self.taxViewModel.accessoryType(at: indexP).rawValue).to(equal(0))
                }
                it("Become checked when toggled two times:") {
                    self.taxViewModel.toggleTax(at: indexP)
                    self.taxViewModel.toggleTax(at: indexP)
                    expect(self.taxViewModel.accessoryType(at: indexP)).to(equal(.checkmark))
                }
            }
        }
    }
}
