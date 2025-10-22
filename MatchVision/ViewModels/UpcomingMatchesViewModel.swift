//
//  UpcomingMatchesViewModel.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  ViewModel para manejar próximos partidos de un equipo
//

import Foundation
import Combine

class UpcomingMatchesViewModel: ObservableObject {
    @Published var matches: [MatchItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let service = APIService()
    private let teamId: Int

    init(teamId: Int) {
        self.teamId = teamId
    }

    func load() {
        isLoading = true
        errorMessage = nil

        service.fetchUpcomingMatches(teamId: teamId) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let items):
                self.matches = items
            case .failure(let err):
                self.errorMessage = err.localizedDescription
            }
        }
    }
}
