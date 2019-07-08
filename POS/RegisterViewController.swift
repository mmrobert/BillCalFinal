//
//  RegisterViewController.swift
//  POS
//
//  Created by Tayson Nguyen on 2019-04-23.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import UIKit
import BillCalFramework

class RegisterViewController: UIViewController {
    let cellIdentifier = "Cell"
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var orderTableView: UITableView!
    
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var discountsLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    let viewModel = RegisterViewModel()
    
    let billCalculation = BillCalculation.shared
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.dataSource = self
        orderTableView.dataSource = self
        menuTableView.delegate = self
        orderTableView.delegate = self
        
        self.addDiscountsAndTaxToBillEngine()
    }
    
    @IBAction func showTaxes() {
        let rootVC = TaxViewController(style: .grouped)
        rootVC.delegate = self
        let vc = UINavigationController(rootViewController: rootVC)
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func showDiscounts() {
        let rootVC = DiscountViewController(style: .grouped)
        rootVC.delegate = self
        let vc = UINavigationController(rootViewController: rootVC)
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
    }
    
    private func addDiscountsAndTaxToBillEngine() {
        let discount5DollarsValue = Discount.DiscountValue.dollar(value: 5)
        let discount5Dollars = Discount(identifier: "$5.00", discountValue: discount5DollarsValue, priority: 300)
        let discount10PercentValue = Discount.DiscountValue.percentage(value: 10)
        let discount10Percent = Discount(identifier: "10%", discountValue: discount10PercentValue, priority: 200)
        let discount20PercentValue = Discount.DiscountValue.percentage(value: 20)
        let discount20Percent = Discount(identifier: "20%", discountValue: discount20PercentValue, priority: 100)
        
        billCalculation.addGroupDiscounts(discounts: [discount5Dollars, discount10Percent, discount20Percent])
        
        let tax1 = Tax(identifier: "Tax 1 (5%)", value: 5, applyToCategory: nil)
        let tax2 = Tax(identifier: "Tax 2 (8%)", value: 8, applyToCategory: nil)
        let alcoholTax = Tax(identifier: "Alcohol Tax (10%)", value: 10, applyToCategory: ["Alcohol"])
        
        billCalculation.addGroupTax(taxes: [tax1, tax2, alcoholTax])
        billCalculation.enableTax(forTax: "Tax 1 (5%)")
        billCalculation.enableTax(forTax: "Tax 2 (8%)")
        billCalculation.enableTax(forTax: "Alcohol Tax (10%)")
    }
    
    private func reCalculation() {
        let _result = billCalculation.getBillResult()
        self.subtotalLabel.text = formatter.string(from: NSDecimalNumber(value: _result.subTotal))
        self.discountsLabel.text = formatter.string(from: NSDecimalNumber(value: _result.discounts))
        self.taxLabel.text = formatter.string(from: NSDecimalNumber(value: _result.tax))
        self.totalLabel.text = formatter.string(from: NSDecimalNumber(value: _result.total))
    }
 
    deinit {
        billCalculation.removeAllDiscounts()
        billCalculation.removeAllTax()
        billCalculation.removeAllItems()
    }
}

extension RegisterViewController: TaxSettingDone {
    
    func taxSettingDone() {
        for _tax in taxes {
            let _taxIdentifer = _tax.label
            if _tax.isEnabled {
                billCalculation.enableTax(forTax: _taxIdentifer)
            } else {
                billCalculation.disEnableTax(forTax: _taxIdentifer)
            }
        }
        self.reCalculation()
    }
}

extension RegisterViewController: DiscountSettingDone {
    func discountSettingDone() {
        for _discount in discounts {
            let _discountIdentifer = _discount.label
            if _discount.isEnabled {
                billCalculation.enableDiscount(forDiscount: _discountIdentifer)
            } else {
                billCalculation.disEnableDiscount(forDiscount: _discountIdentifer)
            }
        }
        self.reCalculation()
    }
}

extension RegisterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == menuTableView {
            return viewModel.menuCategoryTitle(in: section)
            
        } else if tableView == orderTableView {
            return viewModel.orderTitle(in: section)
        }
        
        fatalError()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == menuTableView {
            return viewModel.numberOfMenuCategories()
        } else if tableView == orderTableView {
            return 1
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == menuTableView {
            return viewModel.numberOfMenuItems(in: section)
            
        } else if tableView == orderTableView {
            return viewModel.numberOfOrderItems(in: section)
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        
        if tableView == menuTableView {
            cell.textLabel?.text = viewModel.menuItemName(at: indexPath)
            cell.detailTextLabel?.text = viewModel.menuItemPrice(at: indexPath)
            
        } else if tableView == orderTableView {
            cell.textLabel?.text = viewModel.labelForOrderItem(at: indexPath)
            cell.detailTextLabel?.text = viewModel.orderItemPrice(at: indexPath)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == menuTableView {
            let indexPaths = [viewModel.addItemToOrder(at: indexPath)]
            orderTableView.insertRows(at: indexPaths, with: .automatic)
            
            // calculate bill totals
            let item = categories[indexPath.section].items[indexPath.row]
            
            let frameWorkItem = ItemInOrder(identifier: item.name, name: item.name, price: Double(truncating: item.price), category: item.category, isTaxExempt: item.isTaxExempt)
            let _billResult = billCalculation.addSingleItem(item: frameWorkItem)
            updateBillLabel(result: _billResult)
        
        } else if tableView == orderTableView {
            viewModel.toggleTaxForOrderItem(at: indexPath)
            
            // recalculate bill
            let _orderItems = viewModel.getOrderItems()
            let _orderItemIdentifier = _orderItems[indexPath.row].name
            let _orderItemTaxExempt = _orderItems[indexPath.row].isTaxExempt
            
            billCalculation.isItemTaxExempt(value: _orderItemTaxExempt, forItem: _orderItemIdentifier)
            self.reCalculation()
           //----------
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView == menuTableView {
            return .none
        } else if tableView == orderTableView {
            return .delete
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == orderTableView && editingStyle == .delete {
            // get item before deleting it
            let _itemToDelete = viewModel.getOrderItems()[indexPath.row]
            //
            viewModel.removeItemFromOrder(at: indexPath)
            orderTableView.deleteRows(at: [indexPath], with: .automatic)
            // calculate bill totals
            let _orderItemIdentifier = _itemToDelete.name
            let _result = billCalculation.removeSingleItem(identifier: _orderItemIdentifier)
            updateBillLabel(result: _result)
        }
    }
    
    func updateBillLabel(result: BillCalculation.BillResult) {
        
        self.subtotalLabel.text = formatter.string(from: NSDecimalNumber(value: result.subTotal))
        self.discountsLabel.text = formatter.string(from: NSDecimalNumber(value: result.discounts))
        self.taxLabel.text = formatter.string(from: NSDecimalNumber(value: result.tax))
        self.totalLabel.text = formatter.string(from: NSDecimalNumber(value: result.total))
    }
}


class RegisterViewModel {
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    var orderItems: [Item] = []
    
    func menuCategoryTitle(in section: Int) -> String? {
        return categories[section].name
    }
    
    func orderTitle(in section: Int) -> String? {
        return "Bill"
    }
    
    func numberOfMenuCategories() -> Int {
        return categories.count
    }
    
    func numberOfMenuItems(in section: Int) -> Int {
        return categories[section].items.count
    }
    
    func numberOfOrderItems(in section: Int) -> Int {
        return orderItems.count
    }
    
    func menuItemName(at indexPath: IndexPath) -> String? {
        return categories[indexPath.section].items[indexPath.row].name
    }
    
    func menuItemPrice(at indexPath: IndexPath) -> String? {
        let price = categories[indexPath.section].items[indexPath.row].price
        return formatter.string(from: price)
    }
    
    func labelForOrderItem(at indexPath: IndexPath) -> String? {
        let item = orderItems[indexPath.row]
       
        if item.isTaxExempt {
            return "\(item.name) (No Tax)"
        } else {
            return item.name
        }
    }
    
    func orderItemPrice(at indexPath: IndexPath) -> String? {
        let price = orderItems[indexPath.row].price
        return formatter.string(from: price)
    }
    
    func addItemToOrder(at indexPath: IndexPath) -> IndexPath {
        let item = categories[indexPath.section].items[indexPath.row]
        orderItems.append(item)
        return IndexPath(row: orderItems.count - 1, section: 0)
    }
    
    func removeItemFromOrder(at indexPath: IndexPath) {
        orderItems.remove(at: indexPath.row)
    }
    
    func toggleTaxForOrderItem(at indexPath: IndexPath) {
        orderItems[indexPath.row].isTaxExempt = !orderItems[indexPath.row].isTaxExempt
    }
    
    func getOrderItems() -> [Item] {
        return orderItems
    }
}
