import UIKit

protocol ScanDelegate: AnyObject {
    func didScanProduct(
        name: String,
        safetyScore: Int,
        pillColor: UIColor,
        ingredientInfoJSON: String,
        safetyJSON: String
    )
}
