import Foundation

/// A person approaching the gate for admission
struct Person: Identifiable {
    let id = UUID()
    let firstName: String
    let lastName: String
    let dateOfBirth: Date
    let appearance: Appearance

    /// The document they present (may differ from reality)
    let document: Document

    var fullName: String { "\(firstName) \(lastName)" }

    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: .now).year ?? 0
    }
}

// MARK: - Appearance

struct Appearance: Equatable {
    let hairColor: HairColor
    let hairStyle: HairStyle
    let accessory: Accessory?

    enum HairColor: String, CaseIterable {
        case blonde, brown, black, red, gray, pink, blue
    }

    enum HairStyle: String, CaseIterable {
        case short, long, buzzed, curly, mohawk, bald
    }

    enum Accessory: String, CaseIterable {
        case glasses, sunglasses, hat, earring, nosePiercing
    }
}

// MARK: - Document

struct Document: Equatable {
    let firstName: String
    let lastName: String
    let dateOfBirth: Date
    let photo: Appearance // What the photo looks like

    var fullName: String { "\(firstName) \(lastName)" }
}

// MARK: - Person Generation

extension Person {
    /// Whether this person is a deceiver (document doesn't match)
    var isDeceiver: Bool {
        document.firstName != firstName
            || document.lastName != lastName
            || document.dateOfBirth != dateOfBirth
            || document.photo != appearance
    }

    /// Whether this person meets the age requirement
    func meetsAgeRequirement(_ minimumAge: Int?) -> Bool {
        guard let minimumAge else { return true }
        return age >= minimumAge
    }
}
