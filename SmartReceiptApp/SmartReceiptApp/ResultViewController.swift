//
//  ResultViewController.swift
//  SmartReceiptApp
//
//  Created by Chelsea Carter on 4/28/25.
//

import UIKit

class ResultViewController: UIViewController {
    
    var receiptImage: UIImage?
    var date: String?
    var vendor: String?
    var total: String?
    var predictedCategory: String?

    @IBOutlet weak var receiptImageView: UIImageView!
    @IBOutlet weak var vendorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        receiptImageView.image = receiptImage
        vendorLabel.text = vendor != nil ? "Vendor: \(vendor!)" : "Vendor: Unknown"
        dateLabel.text = date != nil ? "Date: \(date!)" : "Date: Unknown"
        totalLabel.text = total != nil ? "Total: \(total!)" : "Total: Unknown"
        categoryLabel.text = predictedCategory != nil ? "Category: \(predictedCategory!)" : "Category: Unknown"
    }
}
