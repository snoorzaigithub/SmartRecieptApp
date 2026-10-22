//
//  ReceiptManager.swift
//  SmartReceiptApp
//
//  Created by Chelsea Carter on 4/23/25.
//


import UIKit
import CoreData

class ReceiptManager {
    static let shared = ReceiptManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // Save a receipt
    func saveReceipt(vendor: String, total: Double, date: Date, category: String, image: UIImage?) {
        let receipt = Receipt(context: context)
        receipt.vendor = vendor
        receipt.total = total
        receipt.date = date
        receipt.category = category
        if let image = image {
            receipt.imageData = image.jpegData(compressionQuality: 0.8)
        }

        do {
            try context.save()
            print("✅ Receipt saved.")
        } catch {
            print("❌ Failed to save receipt: \(error)")
        }
    }

    // Fetch all receipts
    func fetchReceipts() -> [Receipt] {
        let request: NSFetchRequest<Receipt> = Receipt.fetchRequest()

        do {
            let results = try context.fetch(request)
            return results
        } catch {
            print("❌ Failed to fetch receipts: \(error)")
            return []
        }
    }

    // Optional: Delete a receipt
    func deleteReceipt(_ receipt: Receipt) {
        context.delete(receipt)
        do {
            try context.save()
            print("🗑️ Receipt deleted.")
        } catch {
            print("❌ Failed to delete receipt: \(error)")
        }
    }
}
