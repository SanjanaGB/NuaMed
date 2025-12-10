import Foundation

struct BarcodeResult {
    let name: String
    let description: String
    let ingredients: String?
}

final class BarcodeLookupService {
    static let shared = BarcodeLookupService()

    func lookup(upc: String) async throws -> BarcodeResult {
        let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(upc).json")!
        let (data, _) = try await URLSession.shared.data(from: url)

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let product = json?["product"] as? [String: Any]

        let name = product?["product_name"] as? String ?? "Unknown Product"
        let desc = product?["generic_name"] as? String ?? "No description"
        let ingredients = product?["ingredients_text"] as? String

        return BarcodeResult(
            name: name,
            description: desc,
            ingredients: ingredients
        )
    }
}
