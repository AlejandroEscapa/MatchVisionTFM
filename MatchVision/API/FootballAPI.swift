//
//  APIService.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Servicio encargado de la comunicación con la API de fútbol (api-sports.io),
//  incluyendo ligas, partidos, jugadores y equipos. Maneja peticiones HTTP, parseo
//  de JSON y entrega de datos listos para la UI.
//

import Foundation
import SwiftUI

struct APIService {
    
    // MARK: - IDs de ligas
    static let fullLeagueIds: [Int] = [
        39, 140, 78, 135, 61, // Ligas principales
        2, 3, 848,            // Champions, Europa, Conference
        1, 4, 5               // Competiciones de selecciones
    ]
    
    private let apiKey = "fc300c641565a6a8c1f6ead1dabc35aa" // Clave API
    private let baseURL = "https://v3.football.api-sports.io" // URL base de la API
    
    // MARK: - Ligas
    /// Obtiene todas las ligas disponibles
    func fetchLeagues(completion: @escaping (Result<[LeagueItem], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/leagues") else {
            completeOnMain(.failure(makeError("URL inválida")), completion); return
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue(apiKey, forHTTPHeaderField: "x-apisports-key")
        
        URLSession.shared.dataTask(with: req) { data, _, err in
            if let err = err { completeOnMain(.failure(err), completion); return }
            guard let data = data else { completeOnMain(.failure(makeError("No data")), completion); return }
            
            do {
                let wrapper = try JSONDecoder().decode(LeagueResponse.self, from: data)
                completeOnMain(.success(wrapper.response), completion)
            } catch {
                completeOnMain(.failure(error), completion)
            }
        }.resume()
    }
    
    // MARK: - Partidos por fecha
    /// Devuelve los partidos de una fecha concreta, filtrando ligas relevantes
    func fetchMatches(date: Date, completion: @escaping (Result<[MatchItem], Error>) -> Void) {
        let dateFormatted = formatDate(date)
        guard let url = URL(string: "\(baseURL)/fixtures?date=\(dateFormatted)") else {
            completeOnMain(.failure(makeError("URL inválida")), completion); return
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue(apiKey, forHTTPHeaderField: "x-apisports-key")
        
        URLSession.shared.dataTask(with: req) { data, _, err in
            if let err = err { completeOnMain(.failure(err), completion); return }
            guard let data = data else { completeOnMain(.failure(makeError("No data")), completion); return }
            
            do {
                let dec = try JSONDecoder().decode(MatchResponse.self, from: data)
                let filtered = dec.response.filter { Self.fullLeagueIds.contains($0.league.id) }
                completeOnMain(.success(filtered), completion)
            } catch {
                completeOnMain(.failure(error), completion)
            }
        }.resume()
    }
    
    // MARK: - Clasificaciones (Standings)
    /// Obtiene standings de la temporada 2023
    func getLeagueStatsSeason2023(leagueId: Int, completion: @escaping (Result<[TeamStanding], Error>) -> Void) {
        
        guard let url = URL(string: "\(baseURL)/standings?league=\(leagueId)&season=2023") else {
            completeOnMain(.failure(makeError("URL inválida")), completion); return
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue(apiKey, forHTTPHeaderField: "x-apisports-key")
        
        URLSession.shared.dataTask(with: req) { data, _, err in
            if let err = err { completeOnMain(.failure(err), completion); return }
            guard let data = data else { completeOnMain(.failure(makeError("No data")), completion); return }
            
            do {
                let decoded = try JSONDecoder().decode(LeagueStatsResponse.self, from: data)
                guard
                    let first = decoded.response.first,
                    let standings = first.league.standings
                else {
                    completeOnMain(.failure(makeError("Standings vacíos")), completion); return
                }
                
                let flat = standings.flatMap { $0 }.sorted { $0.rank < $1.rank } // Aplana y ordena por rank
                completeOnMain(.success(flat), completion)
                
            } catch {
                completeOnMain(.failure(error), completion)
            }
        }.resume()
    }
    
    /// Obtiene standings de cualquier temporada
    func getLeagueStats(leagueId: Int, season: Int, completion: @escaping (Result<[TeamStanding], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/standings?league=\(leagueId)&season=\(season)") else {
            completeOnMain(.failure(makeError("URL inválida")), completion)
            return
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue(apiKey, forHTTPHeaderField: "x-apisports-key")
        
        URLSession.shared.dataTask(with: req) { data, _, err in
            if let err = err { completeOnMain(.failure(err), completion); return }
            guard let data = data else { completeOnMain(.failure(makeError("No data")), completion); return }
            
            do {
                let decoded = try JSONDecoder().decode(LeagueStatsResponse.self, from: data)
                guard
                    let first = decoded.response.first,
                    let standings = first.league.standings
                else {
                    completeOnMain(.failure(makeError("Standings vacíos")), completion); return
                }
                
                let flat = standings.flatMap { $0 }.sorted { $0.rank < $1.rank }
                completeOnMain(.success(flat), completion)
                
            } catch {
                completeOnMain(.failure(error), completion)
            }
        }.resume()
    }
    
    // MARK: - Jugadores
    /// Recupera todos los jugadores de un equipo paginando resultados
    func fetchPlayersFull(teamId: Int, season: Int, completion: @escaping (Result<[PlayerResponseItemFull], Error>) -> Void) {
        
        var allItems: [PlayerResponseItemFull] = []
        var page = 1

        func loadPage() {
            let urlStr = "\(baseURL)/players?team=\(teamId)&season=\(season)&page=\(page)"
            guard let url = URL(string: urlStr) else {
                completeOnMain(.failure(makeError("URL inválida")), completion)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(apiKey, forHTTPHeaderField: "x-apisports-key")

            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completeOnMain(.failure(error), completion)
                    return
                }
                guard let data = data else {
                    completeOnMain(.failure(makeError("No data")), completion)
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(PlayersResponseFull.self, from: data)
                    allItems.append(contentsOf: decoded.response)

                    // Paginación: si hay 25 resultados, carga siguiente página
                    if decoded.response.count == 25 {
                        page += 1
                        loadPage()
                    } else {
                        completeOnMain(.success(allItems), completion)
                    }

                } catch {
                    completeOnMain(.failure(error), completion)
                }

            }.resume()
        }

        loadPage()
    }

    /// Devuelve jugadores resumidos con estadísticas para UI
    func fetchPlayers(teamId: Int, season: Int? = nil, completion: @escaping (Result<[PlayerInfo], Error>) -> Void) {
        
        let year = season ?? Calendar.current.component(.year, from: Date())
        
        guard var comp = URLComponents(string: "\(baseURL)/players") else {
            completeOnMain(.failure(makeError("URL inválida")), completion); return
        }
        
        comp.queryItems = [
            URLQueryItem(name: "team", value: "\(teamId)"),
            URLQueryItem(name: "season", value: "\(year)")
        ]
        
        guard let url = comp.url else {
            completeOnMain(.failure(makeError("URL inválida")), completion); return
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue(apiKey, forHTTPHeaderField: "x-apisports-key")
        
        URLSession.shared.dataTask(with: req) { data, _, err in
            if let err = err { completeOnMain(.failure(err), completion); return }
            guard let data = data else { completeOnMain(.failure(makeError("No data")), completion); return }
            
            do {
                let decoded = try JSONDecoder().decode(PlayersResponseFull.self, from: data)
                
                let mapped: [PlayerInfo] = decoded.response.compactMap { item -> PlayerInfo? in
                    guard let p = item.player else { return nil }
                    let s = item.statistics?.first
                    
                    let perf = PlayerPerformance(
                        appearances: s?.games?.appearances,
                        minutes: s?.games?.minutes,
                        goals: s?.goals?.total,
                        assists: s?.goals?.assists,
                        yellow: s?.cards?.yellow,
                        red: s?.cards?.red,
                        rating: s?.games?.rating.flatMap { Double($0) }
                    )
                    
                    return PlayerInfo(
                        id: p.id,
                        name: p.name,
                        firstname: p.firstname,
                        lastname: p.lastname,
                        firstnameLocal: p.firstnameLocal,
                        lastnameLocal: p.lastnameLocal,
                        age: p.age,
                        nationality: p.nationality,
                        height: p.height,
                        weight: p.weight,
                        photo: p.photo,
                        position: s?.games?.position ?? p.position,
                        performance: perf
                    )
                }
                
                completeOnMain(.success(mapped), completion)
                
            } catch {
                completeOnMain(.failure(error), completion)
            }
            
        }.resume()
    }
    
    // MARK: - Equipos
    /// Devuelve información básica de un equipo
    func fetchTeam(teamId: Int, completion: @escaping (Result<StandingTeam, Error>) -> Void) {
        
        guard var comp = URLComponents(string: "\(baseURL)/teams") else {
            completeOnMain(.failure(makeError("URL inválida")), completion); return
        }
        
        comp.queryItems = [ URLQueryItem(name: "id", value: "\(teamId)") ]
        
        guard let url = comp.url else {
            completeOnMain(.failure(makeError("URL inválida")), completion); return
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue(apiKey, forHTTPHeaderField: "x-apisports-key")
        
        URLSession.shared.dataTask(with: req) { data, _, err in
            if let err = err { completeOnMain(.failure(err), completion); return }
            guard let data = data else { completeOnMain(.failure(makeError("No data")), completion); return }
            
            struct TeamsResponse: Decodable {
                struct Item: Decodable { let team: T }
                struct T: Decodable { let id: Int; let name: String; let logo: String? }
                let response: [Item]
            }
            
            do {
                let decoded = try JSONDecoder().decode(TeamsResponse.self, from: data)
                guard let t = decoded.response.first?.team else {
                    completeOnMain(.failure(makeError("Equipo no encontrado")), completion); return
                }
                
                let team = StandingTeam(id: t.id, name: t.name, logo: t.logo)
                completeOnMain(.success(team), completion)
                
            } catch {
                completeOnMain(.failure(error), completion)
            }
            
        }.resume()
    }
    
    // MARK: - Próximos partidos
    /// Devuelve los próximos partidos de un equipo, ordenados por fecha
    func fetchUpcomingMatches(teamId: Int, completion: @escaping (Result<[MatchItem], Error>) -> Void) {
        
        guard let url = URL(string: "\(baseURL)/fixtures?team=\(teamId)&status=NS") else {
            completeOnMain(.failure(makeError("URL inválida")), completion); return
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue(apiKey, forHTTPHeaderField: "x-apisports-key")
        
        URLSession.shared.dataTask(with: req) { data, _, err in
            if let err = err { completeOnMain(.failure(err), completion); return }
            guard let data = data else { completeOnMain(.failure(makeError("No data")), completion); return }
            
            do {
                let decoded = try JSONDecoder().decode(MatchResponse.self, from: data)
                let iso = ISO8601DateFormatter()
                
                let sorted = decoded.response.sorted {
                    (iso.date(from: $0.fixture.date) ?? .distantFuture) <
                        (iso.date(from: $1.fixture.date) ?? .distantFuture)
                }
                
                completeOnMain(.success(sorted), completion)
                
            } catch {
                completeOnMain(.failure(error), completion)
            }
            
        }.resume()
    }
    
    // MARK: - Helpers
    /// Formatea Date a "yyyy-MM-dd"
    private func formatDate(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: d)
    }
    
    /// Crea NSError con mensaje personalizado
    private func makeError(_ msg: String) -> NSError {
        NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    /// Garantiza que el callback se ejecute en el hilo principal
    private func completeOnMain<T>(_ r: Result<T, Error>, _ c: @escaping (Result<T, Error>) -> Void) {
        DispatchQueue.main.async { c(r) }
    }
}
