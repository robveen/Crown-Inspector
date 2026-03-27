import Foundation

/// Generates persons with varying levels of deception based on event difficulty
struct PersonGenerator {
    let event: Event

    private let firstNames = [
        "Alice", "Bob", "Charlie", "Diana", "Edgar", "Fiona",
        "George", "Hannah", "Ivan", "Julia", "Karl", "Luna",
        "Marcus", "Nora", "Oscar", "Penny", "Quinn", "Rosa",
        "Simon", "Tara", "Ulrich", "Vera", "Walter", "Xena",
        "Yuri", "Zara"
    ]

    private let lastNames = [
        "Smith", "Johnson", "Brown", "Taylor", "Anderson", "Clark",
        "Wright", "King", "Scott", "Green", "Baker", "Hall",
        "Young", "Allen", "Hill", "Moore", "White", "Martin",
        "Stone", "Fox", "Cross", "Bell", "Wood", "Rose"
    ]

    func generate() -> Person {
        let isDeceiver = Double.random(in: 0...1) < event.deceiverRate

        let realFirstName = firstNames.randomElement()!
        let realLastName = lastNames.randomElement()!
        let realDOB = randomDateOfBirth()
        let realAppearance = randomAppearance()

        let document: Document

        if isDeceiver {
            document = generateFakeDocument(
                realFirst: realFirstName,
                realLast: realLastName,
                realDOB: realDOB,
                realAppearance: realAppearance
            )
        } else {
            document = Document(
                firstName: realFirstName,
                lastName: realLastName,
                dateOfBirth: realDOB,
                photo: realAppearance
            )
        }

        return Person(
            firstName: realFirstName,
            lastName: realLastName,
            dateOfBirth: realDOB,
            appearance: realAppearance,
            document: document
        )
    }

    // MARK: - Private

    private func randomDateOfBirth() -> Date {
        let calendar = Calendar.current
        let now = Date()

        // Generate ages between 14 and 60
        let age = Int.random(in: 14...60)
        let dayOffset = Int.random(in: 0...364)

        var components = DateComponents()
        components.year = -age
        components.day = -dayOffset

        return calendar.date(byAdding: components, to: now) ?? now
    }

    private func randomAppearance() -> Appearance {
        Appearance(
            hairColor: Appearance.HairColor.allCases.randomElement()!,
            hairStyle: Appearance.HairStyle.allCases.randomElement()!,
            accessory: Bool.random() ? Appearance.Accessory.allCases.randomElement()! : nil
        )
    }

    private func generateFakeDocument(
        realFirst: String,
        realLast: String,
        realDOB: Date,
        realAppearance: Appearance
    ) -> Document {
        // Pick 1 to maxDiscrepancies things to change
        let discrepancyCount = Int.random(in: 1...event.maxDiscrepancies)
        var discrepancies = Set<DiscrepancyType>()

        while discrepancies.count < discrepancyCount {
            discrepancies.insert(DiscrepancyType.allCases.randomElement()!)
        }

        var docFirst = realFirst
        var docLast = realLast
        var docDOB = realDOB
        var docAppearance = realAppearance

        for discrepancy in discrepancies {
            switch discrepancy {
            case .firstName:
                docFirst = firstNames.filter { $0 != realFirst }.randomElement()!
            case .lastName:
                docLast = lastNames.filter { $0 != realLast }.randomElement()!
            case .dateOfBirth:
                // Shift DOB to make them appear older/younger
                let shift = Int.random(in: 1...5) * (Bool.random() ? 1 : -1)
                let calendar = Calendar.current
                docDOB = calendar.date(byAdding: .year, value: shift, to: realDOB) ?? realDOB
            case .appearance:
                // Change one appearance trait
                let traitToChange = Int.random(in: 0...2)
                switch traitToChange {
                case 0:
                    docAppearance = Appearance(
                        hairColor: Appearance.HairColor.allCases.filter { $0 != realAppearance.hairColor }.randomElement()!,
                        hairStyle: realAppearance.hairStyle,
                        accessory: realAppearance.accessory
                    )
                case 1:
                    docAppearance = Appearance(
                        hairColor: realAppearance.hairColor,
                        hairStyle: Appearance.HairStyle.allCases.filter { $0 != realAppearance.hairStyle }.randomElement()!,
                        accessory: realAppearance.accessory
                    )
                default:
                    let newAccessory: Appearance.Accessory?
                    if realAppearance.accessory != nil {
                        newAccessory = nil // Remove accessory
                    } else {
                        newAccessory = Appearance.Accessory.allCases.randomElement()!
                    }
                    docAppearance = Appearance(
                        hairColor: realAppearance.hairColor,
                        hairStyle: realAppearance.hairStyle,
                        accessory: newAccessory
                    )
                }
            }
        }

        return Document(
            firstName: docFirst,
            lastName: docLast,
            dateOfBirth: docDOB,
            photo: docAppearance
        )
    }
}

// MARK: - Discrepancy Types

private enum DiscrepancyType: CaseIterable {
    case firstName
    case lastName
    case dateOfBirth
    case appearance
}
