//
//  LeagueStandingsViewModel.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  ViewModel para la pantalla de clasificación de ligas.
//

import Foundation
import Combine

@MainActor
class LeagueStandingsViewModel: ObservableObject {
    @Published var standings: [TeamStanding] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let api = APIService()

    func loadStandings(for leagueId: Int, season: Int = 2024) {
        isLoading = true
        errorMessage = nil
        standings = []

        api.getLeagueStats(leagueId: leagueId, season: season) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let teams):
                    self.standings = teams.sorted { $0.rank < $1.rank }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
