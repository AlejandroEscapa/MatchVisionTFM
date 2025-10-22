//
//  MatchsViewModel.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  ViewModel para gestionar partidos y standings de ligas.
//

import SwiftUI
import Combine

@MainActor
class MatchsViewModel: ObservableObject {
    @Published var matches: [MatchItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var leagueStandings: [TeamStanding] = []
    
    private let api = APIService()
    private let season: Int = 2024
    
    // MARK: - Carga de partidos en tiempo real
    func loadMatches(for date: Date) {
        isLoading = true
        errorMessage = nil
        
        api.fetchMatches(date: date) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let data):
                    // Ordenar por fecha
                    self.matches = data.sorted { first, second in
                        let iso = ISO8601DateFormatter()
                        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                        let d1 = iso.date(from: first.fixture.date)
                        let d2 = iso.date(from: second.fixture.date)
                        if let d1 = d1, let d2 = d2 { return d1 < d2 }
                        return true
                    }
                    
                    // Cargar standings de las ligas mostradas
                    let leagueIds = Set(self.matches.map { $0.league.id })
                    leagueIds.forEach { self.loadLeagueStandings(for: $0) }
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.matches = []
                }
            }
        }
    }
    
    // MARK: - Carga de standings de liga 2024
    func loadLeagueStandings(for leagueId: Int) {
        api.getLeagueStatsSeason2023(leagueId: leagueId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let teams):
                    let existingIds = Set(self.leagueStandings.map { $0.team.id })
                    let newTeams = teams.filter { !existingIds.contains($0.team.id) }
                    self.leagueStandings.append(contentsOf: newTeams)
                    self.leagueStandings.sort { $0.rank < $1.rank }
                case .failure(let error):
                    print("Error cargando standings: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Helpers de agrupación
    func groupedMatches() -> [String: [MatchItem]] {
        Dictionary(grouping: matches, by: { $0.league.name })
    }
    
    func groupedLeagueKeys() -> [String] {
        groupedMatches().keys.sorted { $0 < $1 }
    }
    
    func teamStanding(for teamId: Int) -> TeamStanding? {
        leagueStandings.first(where: { $0.team.id == teamId })
    }
}
