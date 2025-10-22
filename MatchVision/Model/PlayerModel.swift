//
//  PlayerModel.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Modelos para representar jugadores, incluyendo estadísticas y performance.
//

import Foundation
import SwiftUI

// MARK: - Respuesta básica de jugadores
struct PlayersResponse: Codable {
    let response: [PlayerResponseItem]
}

struct PlayerResponseItem: Codable {
    let player: PlayerInfo?
}

// MARK: - Información del jugador
struct PlayerInfo: Codable, Identifiable {
    let id: Int
    let name: String?              // Nombre completo si existe
    let firstname: String?
    let lastname: String?
    let firstnameLocal: String?
    let lastnameLocal: String?
    let age: Int?
    let nationality: String?
    let height: String?
    let weight: String?
    let photo: String?
    var position: String?
    var performance: PlayerPerformance?

    // Nombre a mostrar en UI
    var displayName: String {
        if let n = name { return n }
        let parts = [firstname, lastname].compactMap { $0 }
        if !parts.isEmpty { return parts.joined(separator: " ") }
        return "Jugador"
    }

    // Color de la etiqueta según la posición
    var tagColor: Color {
        guard let pos = position?.lowercased() else { return Color.gray }
        switch pos {
        case "portero":
            return Color.black
        case "defensa":
            return Color.blue
        case "centrocampista":
            return Color.green
        case "delantero":
            return Color.red
        default:
            return Color.gray
        }
    }
}

// MARK: - Respuesta completa de jugadores (con estadísticas)
struct PlayersResponseFull: Codable {
    let response: [PlayerResponseItemFull]
}

struct PlayerResponseItemFull: Codable {
    let player: PlayerInfo?
    let statistics: [PlayerStatisticsFull]?
}

// MARK: - Estadísticas completas de un jugador
struct PlayerStatisticsFull: Codable {
    let team: SimpleTeam?      // Equipo del jugador
    let games: GamesFull?      // Partidos jugados, minutos, posición
    let goals: GoalsFull?      // Goles y asistencias
    let cards: CardsFull?      // Tarjetas
}

// Equipo simplificado
struct SimpleTeam: Codable {
    let id: Int?
    let name: String?
}

// Estadísticas de juegos
struct GamesFull: Codable {
    let position: String?
    let appearances: Int?
    let minutes: Int?
    let rating: String?         // Rating como string (puede ser convertido a Double)
}

// Goles y asistencias
struct GoalsFull: Codable {
    let total: Int?
    let assists: Int?
}

// Tarjetas
struct CardsFull: Codable {
    let yellow: Int?
    let red: Int?
}

// Estadísticas resumidas para UI
struct PlayerPerformance: Codable {
    let appearances: Int?
    let minutes: Int?
    let goals: Int?
    let assists: Int?
    let yellow: Int?
    let red: Int?
    let rating: Double?
}
