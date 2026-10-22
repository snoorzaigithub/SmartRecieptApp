//
//  HomeViewController.swift
//  SmartReceiptApp
//
//  Created by Chelsea Carter on 4/28/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapScanReceipt(_ sender: UIButton) {
        print("Scan Receipt button tapped!")
    }

    @IBAction func didTapViewHistory(_ sender: UIButton) {
        print("View History button tapped!")
    }

}
