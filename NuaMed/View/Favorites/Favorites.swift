import Foundation

struct FavoriteProduct{
    let name: String
    let safetyScore: Int
    let ingredientInfoJSON: String
    let safetyJSON: String
}

final class Favorites{
    static let shared = Favorites()
    private init() {}
    
    private(set) var products: [FavoriteProduct] = []
    
    func addProduct(_ product: FavoriteProduct) {
        //Check for duplicates
        if !products.contains(where: { $0.name == product.name }) {
            products.append(product)
        }
    }

    // Remove product from favorites by name
    func removeProduct(named name: String) {
        products.removeAll { $0.name == name }
    }
    
    //Is it already clicked/favorited?
    func checkIfFavorited(named name: String) -> Bool {
        return products.contains(where: { $0.name == name })
    }
}
