import Foundation

/// Generates persons with varying levels of deception based on event difficulty
struct PersonGenerator {
    let event: Event
    let vipNames: [String]
    let blacklistedNames: [String]

    init(event: Event, vipNames: [String] = [], blacklistedNames: [String] = []) {
        self.event = event
        self.vipNames = vipNames
        self.blacklistedNames = blacklistedNames
    }

    // MARK: - Name pools (with subtle similar names for deception)

    private static let firstNames = [
        "Alice", "Bob", "Charlie", "Diana", "Edgar", "Fiona",
        "George", "Hannah", "Ivan", "Julia", "Karl", "Luna",
        "Marcus", "Nora", "Oscar", "Penny", "Quinn", "Rosa",
        "Simon", "Tara", "Ulrich", "Vera", "Walter", "Xena",
        "Yuri", "Zara", "Thomas", "Sarah", "James", "Emily"
    ]

    /// Names that look very similar — used for subtle discrepancies
    private static let confusableFirstNames: [String: [String]] = [
        "Alice": ["Alise", "Alyce", "Aliice"],
        "Bob": ["Rob", "Bab", "Bob "], // trailing space!
        "Charlie": ["Charley", "Charly", "Gharlie"],
        "Diana": ["Dianna", "Dlana", "Dianа"], // last one has Cyrillic 'а'
        "Edgar": ["Edger", "Edgard", "Еdgar"], // Cyrillic 'E'
        "Fiona": ["Fionna", "Fíona", "Fioona"],
        "George": ["Gorge", "Geroge", "Gеorge"],
        "Hannah": ["Hanna", "Hannаh", "Hanah"],
        "Julia": ["Julía", "Juliа", "Julla"],
        "Karl": ["Carl", "Kаrl", "Karrl"],
        "Luna": ["Lunа", "Luma", "Lunna"],
        "Marcus": ["Markus", "Marсus", "Marcas"],
        "Nora": ["Norah", "Norа", "Noora"],
        "Oscar": ["Oskar", "Оscar", "Oscаr"],
        "Simon": ["Simоn", "Sirnon", "Simmon"], // 'rn' looks like 'm'
        "Thomas": ["Thoams", "Тhomas", "Thomаs"],
        "Sarah": ["Sara", "Sаrah", "Sarrah"],
        "James": ["Janes", "Jamеs", "Jarnes"], // 'rn' trick
        "Emily": ["Ernily", "Emíly", "Emilly"],
    ]

    private static let lastNames = [
        "Smith", "Johnson", "Brown", "Taylor", "Anderson", "Clark",
        "Wright", "King", "Scott", "Green", "Baker", "Hall",
        "Young", "Allen", "Hill", "Moore", "White", "Martin",
        "Stone", "Fox", "Cross", "Bell", "Wood", "Rose"
    ]

    private static let confusableLastNames: [String: [String]] = [
        "Smith": ["Srnith", "Smlth", "Smiith"],
        "Johnson": ["Jonhson", "Johnsen", "Jоhnson"],
        "Brown": ["Browm", "Brоwn", "Broown"],
        "Taylor": ["Talyor", "Taylоr", "Tayler"],
        "Anderson": ["Andersen", "Аnderson", "Andersson"],
        "Clark": ["Clarke", "Сlark", "Clаrk"],
        "Wright": ["Wrlght", "Wrіght", "Wight"],
        "King": ["Klng", "Кing", "Kinng"],
        "Scott": ["Scоtt", "Scatt", "Scot"],
        "Green": ["Greem", "Greеn", "Greeen"],
        "Baker": ["Вaker", "Bаker", "Bakerr"],
        "Moore": ["Moоre", "Мoore", "Moorе"],
        "Martin": ["Martín", "Маrtin", "Martln"],
        "Stone": ["Stоne", "Stonе", "Stome"],
        "Bell": ["Вell", "Bеll", "Belll"],
    ]

    // MARK: - Generate

    func generate() -> Person {
        let isDeceiver = Double.random(in: 0...1) < event.deceiverRate

        // Small chance of VIP or blacklisted person
        let specialStatus: SpecialStatus?
        let realFirstName: String
        let realLastName: String

        let vipChance = Double(vipNames.count) * 0.05
        let blacklistChance = Double(blacklistedNames.count) * 0.05

        let roll = Double.random(in: 0...1)
        if roll < vipChance, let vipName = vipNames.randomElement() {
            let parts = vipName.split(separator: " ")
            realFirstName = String(parts.first ?? "Lady")
            realLastName = String(parts.last ?? "Unknown")
            specialStatus = .vip
        } else if roll < vipChance + blacklistChance, let blName = blacklistedNames.randomElement() {
            let parts = blName.split(separator: " ")
            realFirstName = String(parts.first ?? "Bad")
            realLastName = String(parts.last ?? "Person")
            specialStatus = .blacklisted
        } else {
            realFirstName = Self.firstNames.randomElement()!
            realLastName = Self.lastNames.randomElement()!
            specialStatus = nil
        }

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
            document: document,
            specialStatus: specialStatus
        )
    }

    // MARK: - Private Helpers

    private func randomDateOfBirth() -> Date {
        let calendar = Calendar.current
        let now = Date()
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
            case .subtleName:
                // Very subtle: use a confusable name variant
                if let variants = Self.confusableFirstNames[realFirst], Bool.random() {
                    docFirst = variants.randomElement()!
                } else if let variants = Self.confusableLastNames[realLast] {
                    docLast = variants.randomElement()!
                } else {
                    // Fallback: swap two adjacent letters
                    docFirst = swapAdjacentLetters(in: realFirst)
                }

            case .obviousName:
                // Completely different name
                docFirst = Self.firstNames.filter { $0 != realFirst }.randomElement()!

            case .subtleDOB:
                // Off by one day or one month — very easy to miss
                let calendar = Calendar.current
                let tweak = [
                    DateComponents(day: Bool.random() ? 1 : -1),
                    DateComponents(month: Bool.random() ? 1 : -1),
                    DateComponents(year: 0, month: 0, day: Int.random(in: 1...3)),
                ].randomElement()!
                docDOB = calendar.date(byAdding: tweak, to: realDOB) ?? realDOB

            case .obviousDOB:
                // Off by years
                let shift = Int.random(in: 1...5) * (Bool.random() ? 1 : -1)
                let calendar = Calendar.current
                docDOB = calendar.date(byAdding: .year, value: shift, to: realDOB) ?? realDOB

            case .subtleAppearance:
                // Very subtle: similar hair shade or accessory swap
                switch Int.random(in: 0...2) {
                case 0:
                    // Slightly different hair color (adjacent in enum)
                    let allColors = Appearance.HairColor.allCases
                    if let idx = allColors.firstIndex(of: realAppearance.hairColor) {
                        let newIdx = min(allColors.count - 1, max(0, idx + (Bool.random() ? 1 : -1)))
                        docAppearance = Appearance(
                            hairColor: allColors[newIdx],
                            hairStyle: realAppearance.hairStyle,
                            accessory: realAppearance.accessory
                        )
                    }
                case 1:
                    // Accessory presence toggled
                    let newAccessory: Appearance.Accessory?
                    if realAppearance.accessory != nil {
                        newAccessory = nil
                    } else {
                        newAccessory = Appearance.Accessory.allCases.randomElement()!
                    }
                    docAppearance = Appearance(
                        hairColor: realAppearance.hairColor,
                        hairStyle: realAppearance.hairStyle,
                        accessory: newAccessory
                    )
                default:
                    // Glasses vs sunglasses swap
                    let newAccessory: Appearance.Accessory?
                    if realAppearance.accessory == .glasses {
                        newAccessory = .sunglasses
                    } else if realAppearance.accessory == .sunglasses {
                        newAccessory = .glasses
                    } else {
                        newAccessory = realAppearance.accessory == nil ? .glasses : nil
                    }
                    docAppearance = Appearance(
                        hairColor: realAppearance.hairColor,
                        hairStyle: realAppearance.hairStyle,
                        accessory: newAccessory
                    )
                }

            case .obviousAppearance:
                // Completely different hair
                docAppearance = Appearance(
                    hairColor: Appearance.HairColor.allCases.filter { $0 != realAppearance.hairColor }.randomElement()!,
                    hairStyle: Appearance.HairStyle.allCases.filter { $0 != realAppearance.hairStyle }.randomElement()!,
                    accessory: realAppearance.accessory
                )
            }
        }

        return Document(
            firstName: docFirst,
            lastName: docLast,
            dateOfBirth: docDOB,
            photo: docAppearance
        )
    }

    /// Swap two adjacent characters — "Alice" -> "Alcie"
    private func swapAdjacentLetters(in name: String) -> String {
        guard name.count >= 3 else { return name }
        var chars = Array(name)
        let idx = Int.random(in: 1..<chars.count - 1)
        chars.swapAt(idx, idx + 1)
        return String(chars)
    }
}

// MARK: - Discrepancy Types

/// Weighted by difficulty — easy events get obvious, hard events get subtle
private enum DiscrepancyType: CaseIterable {
    case subtleName
    case obviousName
    case subtleDOB
    case obviousDOB
    case subtleAppearance
    case obviousAppearance
}
