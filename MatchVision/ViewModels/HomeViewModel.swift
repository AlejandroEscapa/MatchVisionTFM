//
//  HomeViewModel.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  ViewModel para la pantalla principal: ligas y noticias.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    // MARK: - Estados de ligas
    @Published var leagues: [LeagueItem] = []
    @Published var isLoadingLeagues: Bool = false
    @Published var leaguesErrorMessage: String?

    // MARK: - Estados de noticias
    @Published var allArticles: [Article] = []
    @Published var featuredArticle: Article?
    @Published var isLoadingNews: Bool = false
    @Published var newsErrorMessage: String?

    // MARK: - Servicios
    private let api = APIService()
    private let apiNews = APINews()

    // MARK: - Inicializador
    init() {
        loadLeagues()
        loadNews()
    }

    // MARK: - Computed
    var articlesForList: [Article] {
        guard let featured = featuredArticle else { return allArticles }
        return allArticles.filter { !Self.isSameArticle($0, featured) }
    }

    // MARK: - Carga de ligas
    func loadLeagues() {
        isLoadingLeagues = true
        leaguesErrorMessage = nil

        api.fetchLeagues { [weak self] (result: Result<[LeagueItem], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoadingLeagues = false
                switch result {
                case .success(let items):
                    let mainLeagueNames = ["Premier League", "La Liga", "Bundesliga", "Serie A", "Ligue 1"]
                    let filtered = items.filter { mainLeagueNames.contains($0.league.name) }
                    self.leagues = Array(filtered.prefix(6))
                case .failure(let error):
                    self.leaguesErrorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Carga de noticias
    func loadNews() {
        isLoadingNews = true
        newsErrorMessage = nil
        allArticles = []
        featuredArticle = nil

        apiNews.fetchFootballNews { [weak self] (result: Result<[Article], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoadingNews = false
                switch result {
                case .success(let arr):
                    self.allArticles = arr
                    self.featuredArticle = arr.first(where: { $0.urlToImage != nil && !$0.urlToImage!.isEmpty }) ?? arr.first
                case .failure(let err):
                    self.newsErrorMessage = err.localizedDescription
                }
            }
        }
    }

    // MARK: - Comparación de artículos
    private static func isSameArticle(_ a: Article, _ b: Article) -> Bool {
        if let urlA = a.url, let urlB = b.url, !urlA.isEmpty, !urlB.isEmpty { return urlA == urlB }
        if let titleA = a.title, let titleB = b.title, !titleA.isEmpty, !titleB.isEmpty { return titleA == titleB }
        if let pA = a.publishedAt, let pB = b.publishedAt { return pA == pB }
        return false
    }
}
