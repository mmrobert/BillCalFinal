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
        describe("Tax view model testing.") {
            beforeEach {
                for i in 0..<taxes.count {
                    taxes[i].isEnabled = true
                }
            }
            context("Section title - only 1 section") {
                it("should return section title string") {
                    expect(self.taxViewModel.title(for: 0)).to(equal("Taxes"))
                }
            }
            context("Number of sections - only 1 section") {
                it("should return 1") {
                    expect(self.taxViewModel.numberOfSections()).to(equal(1))
                }
            }
            context("Number of rows in section - only 1 section") {
                it("should return total numbers of taxes specified") {
                    expect(self.taxViewModel.numberOfRows(in: 0)).to(equal(3))
                }
            }
            context("Tax label") {
                it("should return label string for a tax") {
                    let indexP = IndexPath(row: 1, section: 0)
                    expect(self.taxViewModel.labelForTax(at: indexP)).to(equal("Tax 2 (8%)"))
                }
            }
            context("Toggling tax to check or uncheck") {
                let indexP = IndexPath(row: 1, section: 0)
                it("Initial condition, which is checked") {
                    expect(self.taxViewModel.accessoryType(at: indexP)).to(equal(.checkmark))
                }
                it("Become unchecked when toggled one time") {
                    self.taxViewModel.toggleTax(at: indexP)
                    expect(self.taxViewModel.accessoryType(at: indexP).rawValue).to(equal(0))
                }
                it("Become checked when toggled two times") {
                    self.taxViewModel.toggleTax(at: indexP)
                    self.taxViewModel.toggleTax(at: indexP)
                    expect(self.taxViewModel.accessoryType(at: indexP)).to(equal(.checkmark))
                }
            }
        }
    }
}
