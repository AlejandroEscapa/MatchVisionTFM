//
//  MatchModel.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Modelos para representar partidos de fútbol obtenidos desde la API.
//  Incluye información del fixture, equipos y resultados.
//

import Foundation

// MARK: - Respuesta de lista de partidos
/// Contiene la lista de partidos obtenidos de la API
struct MatchResponse: Codable {
    let response: [MatchItem]
}

// MARK: - Partido individual
struct MatchItem: Codable, Identifiable {
    var id: Int { fixture.id } // ID único del fixture para SwiftUI

    let fixture: Fixture   // Información del partido (fecha, estado)
    let league: League     // Liga a la que pertenece el partido
    let teams: Teams       // Equipos involucrados
    let goals: Goals       // Goles marcados por cada equipo
}

// MARK: - Información del fixture
struct Fixture: Codable {
    let id: Int
    let date: String       // Fecha y hora del partido en formato ISO8601
    let status: Status     // Estado actual del partido
}

// MARK: - Estado del partido
struct Status: Codable {
    let short: String      // Estado abreviado (NS, FT, 1H, etc.)
    let elapsed: Int?      // Minutos transcurridos si aplica
}

// MARK: - Equipos del partido
struct Teams: Codable {
    let home: TeamInfo     // Equipo local
    let away: TeamInfo     // Equipo visitante
}

// MARK: - Información de cada equipo
struct TeamInfo: Codable {
    let id: Int
    let name: String
    let logo: String?      // URL del logo del equipo
}

// MARK: - Goles del partido
struct Goals: Codable {
    let home: Int?         // Goles del equipo local
    let away: Int?         // Goles del equipo visitante
}
