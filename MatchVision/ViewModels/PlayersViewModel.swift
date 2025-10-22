//
//  PlayersViewModel.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  ViewModel para manejar lista de jugadores con estadísticas completas
//

import Foundation
import Combine
import SwiftUI

@MainActor
class PlayersViewModel: ObservableObject {
    @Published var players: [PlayerInfo] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let api = APIService()
    private let season: Int
    private let teamId: Int

    init(teamId: Int, season: Int = 2023) {
        self.teamId = teamId
        self.season = season
    }

    func load() {
        fetchPlayersFull(teamId: teamId)
    }

    func reload() {
        players = []
        load()
    }

    // MARK: - Fetch completo (PlayerInfo + statistics)
    func fetchPlayersFull(teamId: Int) {
        isLoading = true
        errorMessage = nil

        api.fetchPlayersFull(teamId: teamId, season: 2023) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let fullResponse):
                    var mappedPlayers = fullResponse.compactMap { item -> PlayerInfo? in
                        guard let base = item.player else { return nil }
                        let stats = item.statistics?.first
                        let perf = PlayerPerformance(
                            appearances: stats?.games?.appearances,
                            minutes: stats?.games?.minutes,
                            goals: stats?.goals?.total,
                            assists: stats?.goals?.assists,
                            yellow: stats?.cards?.yellow,
                            red: stats?.cards?.red,
                            rating: stats?.games?.rating.flatMap { Double($0) }
                        )

                        var player = PlayerInfo(
                            id: base.id,
                            name: base.name,
                            firstname: base.firstname,
                            lastname: base.lastname,
                            firstnameLocal: base.firstnameLocal,
                            lastnameLocal: base.lastnameLocal,
                            age: base.age,
                            nationality: base.nationality,
                            height: base.height,
                            weight: base.weight,
                            photo: base.photo,
                            position: stats?.games?.position ?? base.position,
                            performance: perf
                        )

                        player = self.translatePosition(player: player)
                        player.performance = self.calculateMatches(performance: perf)

                        return player
                    }

                    mappedPlayers.sort { lhs, rhs in
                        func positionRank(_ pos: String?) -> Int {
                            switch pos?.lowercased() {
                            case "portero": return 0
                            case "defensa": return 1
                            case "centrocampista": return 2
                            case "delantero": return 3
                            default: return 4
                            }
                        }
                        return positionRank(lhs.position) < positionRank(rhs.position)
                    }

                    self.players = mappedPlayers

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.players = []
                }
            }
        }
    }

    // MARK: - Traduce la posición al español
    private func translatePosition(player: PlayerInfo) -> PlayerInfo {
        guard let pos = player.position?.lowercased() else { return player }
        var translated = player
        if pos.contains("goal") || pos.contains("keeper") {
            translated.position = "Portero"
        } else if pos.contains("def") || pos.contains("back") {
            translated.position = "Defensa"
        } else if pos.contains("mid") {
            translated.position = "Centrocampista"
        } else if pos.contains("att") || pos.contains("forward") || pos.contains("striker") {
            translated.position = "Delantero"
        } else {
            translated.position = pos.capitalized
        }
        return translated
    }

    // MARK: - Calcula partidos como minutos / 90
    private func calculateMatches(performance: PlayerPerformance?) -> PlayerPerformance? {
        guard let perf = performance, let minutes = perf.minutes, minutes > 0 else {
            return performance
        }
        let matches = max(1, minutes / 90)
        return PlayerPerformance(
            appearances: matches,
            minutes: perf.minutes,
            goals: perf.goals,
            assists: perf.assists,
            yellow: perf.yellow,
            red: perf.red,
            rating: perf.rating
        )
    }
}
