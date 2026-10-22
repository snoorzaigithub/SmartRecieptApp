//
//  ViewController.swift
//  SmartReceiptApp
//
//  Created by Chelsea Carter on 4/23/25.
//

import UIKit
import Vision
import CoreML
import CoreData

class ScanReceiptViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var receiptImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapUploadReceipt(_ sender: UIButton) {
        presentImagePicker()
    }
    
    func presentImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("❌ Camera not available. Try .photoLibrary.")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary // change to .photoLibrary if testing on simulator
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            print("📸 Got image!")
            receiptImageView.image = image
            performOCR(on: image) // ✅ OCR here
        }
    }


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        print("❌ User cancelled image picker.")
    }
    
    func performOCR(on image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("❌ Failed to convert UIImage to CGImage")
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("❌ OCR error: \(error)")
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

            let fullText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            print("🧾 OCR Text:\n\(fullText)")

            let predictedCategory = self.predictCategory(from: fullText)
            print("🧠 Predicted Category: \(predictedCategory)")

            // 👇 ADD THESE EXTRACTIONS
            let vendor = self.extractVendor(from: fullText)
            let date = self.extractDate(from: fullText)
            let total = self.extractTotal(from: fullText)

            DispatchQueue.main.async {
                // Convert the date string to a Date object
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                let dateObj = formatter.date(from: date) ?? Date()

                // Convert the total to Double
                let cleanedTotal = total.replacingOccurrences(of: "$", with: "")
                let totalDouble = Double(cleanedTotal) ?? 0.0

                // Save to Core Data via ReceiptManager
                ReceiptManager.shared.saveReceipt(
                    vendor: vendor,
                    total: totalDouble,
                    date: dateObj,
                    category: predictedCategory,
                    image: image
                )

                // Then continue to Result screen
                self.goToResultScreen(image: image, vendor: vendor, date: date, total: total, category: predictedCategory)
            }
        }

        request.recognitionLevel = .accurate

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("❌ Failed to perform OCR: \(error)")
            }
        }
    }
    
    func predictCategory(from text: String) -> String {
        do {
            let model = try ReceiptCategoryClassifier(configuration: MLModelConfiguration())
            let prediction = try model.prediction(text: text)
            return prediction.label
        } catch {
            print("❌ CoreML prediction error: \(error)")
            return "Other"
        }
    }
    
    func goToResultScreen(image: UIImage, vendor: String, date: String, total: String, category: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let resultVC = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController {
            resultVC.receiptImage = image
            resultVC.vendor = vendor
            resultVC.date = date
            resultVC.total = total
            resultVC.predictedCategory = category
            self.navigationController?.pushViewController(resultVC, animated: true)
        }
    }
    
    func extractVendor(from text: String) -> String {
        let lines = text.components(separatedBy: "\n")
        return lines.first ?? "Unknown Vendor"
    }

    func extractDate(from text: String) -> String {
        let datePatterns = ["\\d{2}/\\d{2}/\\d{4}", "\\d{4}-\\d{2}-\\d{2}"]  // mm/dd/yyyy or yyyy-mm-dd
        for pattern in datePatterns {
            if let match = text.range(of: pattern, options: .regularExpression) {
                return String(text[match])
            }
        }
        return "Unknown Date"
    }

    func extractTotal(from text: String) -> String {
        let lines = text.lowercased().components(separatedBy: "\n")
        for line in lines {
            if line.contains("total") {
                if let match = line.range(of: "\\$\\d+(\\.\\d{2})?", options: .regularExpression) {
                    return String(line[match])
                }
            }
        }
        return "Unknown Total"
    }
}

