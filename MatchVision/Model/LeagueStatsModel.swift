//
//  LeagueStatsModel.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Modelos para representar estadísticas de ligas y clasificaciones de equipos.
//

import Foundation

// MARK: - Respuesta de estadísticas de liga
/// Contiene la lista de ligas con sus respectivas clasificaciones
struct LeagueStatsResponse: Codable {
    let response: [LeagueResponseItem]
}

// MARK: - Ítem de respuesta por liga
struct LeagueResponseItem: Codable {
    let league: LeagueWithStandings
}

// MARK: - Liga con standings
struct LeagueWithStandings: Codable {
    let id: Int
    let name: String
    let country: String?
    let logo: String?
    let flag: String?
    let season: Int?
    let standings: [[TeamStanding]]? // Array de arrays para posibles grupos en la liga
}

// MARK: - Clasificación de equipo
struct TeamStanding: Codable, Identifiable {
    var id: Int { team.id } // ID del equipo para SwiftUI
    let rank: Int
    let team: StandingTeam
    let points: Int
    let goalsDiff: Int?       // Diferencia de goles
    let group: String?        // Grupo si aplica
    let form: String?         // Forma reciente del equipo (WWDL, etc.)
    let status: String?       // Estado en la competición (e.g., "relegated")
    let description: String?  // Información adicional
    let all: MatchStats?      // Estadísticas globales
    let home: MatchStats?     // Estadísticas en casa
    let away: MatchStats?     // Estadísticas fuera
    let update: String?       // Fecha de última actualización
}

// MARK: - Información básica del equipo
struct StandingTeam: Codable {
    let id: Int
    let name: String
    let logo: String?
}

// MARK: - Estadísticas de partidos
struct MatchStats: Codable {
    let played: Int?
    let win: Int?
    let draw: Int?
    let lose: Int?
    let goals: GoalsStats? // Goles a favor y en contra
}

// MARK: - Goles
struct GoalsStats: Codable {
    let forGoals: Int?     // Goles a favor
    let against: Int?      // Goles en contra

    enum CodingKeys: String, CodingKey {
        case forGoals = "for" // La API usa "for" como clave
        case against
    }
}
