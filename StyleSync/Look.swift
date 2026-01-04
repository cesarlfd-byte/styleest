import SwiftUI

struct Look: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String // ex: "look1", "look2" — você pode criar depois
    let tags: [String]
}
