//
//  LeagueModel.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Modelos para representar ligas de fútbol obtenidas desde la API.
//  Incluye la respuesta completa y la estructura de cada liga.
//

import Foundation

// MARK: - Respuesta de lista de ligas
/// Estructura principal devuelta por la API al solicitar ligas
struct LeagueResponse: Codable {
    let response: [LeagueItem]
}

// MARK: - Liga individual
/// Representa un ítem de liga con su identificador único
struct LeagueItem: Codable, Identifiable {
    var id: Int { league.id }
    let league: League
}

// MARK: - Detalles de liga
/// Información básica de una liga
struct League: Codable {
    let id: Int
    let name: String
    let logo: String?
}
