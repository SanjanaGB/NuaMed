struct WarningModel {
        let ingredient: String
        let issue: String
    }

    func extractSafetyAlerts(from json: String) -> (allergens: [String], warnings: [WarningModel]) {

        guard let dict = json.toJSONDict() else {
            return ([], [])
        }

        let allergenMatches = dict["allergenMatches"] as? [String] ?? []
        var warningsList: [WarningModel] = []

        if let warningArray = dict["warnings"] as? [[String: Any]] {
            for entry in warningArray {
                let ingredient = entry["ingredient"] as? String ?? ""
                let issue = entry["issue"] as? String ?? ""

                if !ingredient.isEmpty && !issue.isEmpty {
                    warningsList.append(WarningModel(ingredient: ingredient, issue: issue))
                }
            }
        }

        return (allergenMatches, warningsList)
    }
