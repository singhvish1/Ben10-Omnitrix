import SwiftUI

struct Alien: Identifiable, Hashable {
    let id: String
    let name: String
    let species: String
    let accent: Color
    let symbol: String
    let power: String
}

extension Alien {
    static let roster: [Alien] = [
        Alien(id: "heatblast", name: "Heatblast", species: "Pyronite", accent: .orange, symbol: "flame.fill", power: "Pyrokinesis"),
        Alien(id: "fourarms", name: "Four Arms", species: "Tetramand", accent: .red, symbol: "figure.strengthtraining.traditional", power: "Super strength"),
        Alien(id: "xlr8", name: "XLR8", species: "Kineceleran", accent: .cyan, symbol: "bolt.fill", power: "Hyper speed"),
        Alien(id: "diamondhead", name: "Diamondhead", species: "Petrosapien", accent: .blue, symbol: "diamond.fill", power: "Crystal armor"),
        Alien(id: "wildmutt", name: "Wildmutt", species: "Vulpimancer", accent: .brown, symbol: "pawprint.fill", power: "Enhanced senses"),
        Alien(id: "upgrade", name: "Upgrade", species: "Galvanic Mechamorph", accent: .purple, symbol: "cpu.fill", power: "Techno-morph"),
    ]
}
