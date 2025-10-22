//
//  NewsViewModel.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  ViewModel para manejar noticias deportivas.
//

import SwiftUI
import Combine

@MainActor
class NewsViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiNews = APINews()

    func loadNews(language: String = "en", country: String? = nil) {
        print("[NewsViewModel] loadNews called language=\(language) country=\(country ?? "nil")")
        isLoading = true
        errorMessage = nil
        articles = []

        apiNews.fetchFootballNews(language: language, country: country, pageSize: 20) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {
                    print("[NewsViewModel] self deallocated antes de completar la petición")
                    return
                }
                self.isLoading = false

                switch result {
                case .success(let fetchedArticles):
                    print("[NewsViewModel] fetch success count=\(fetchedArticles.count)")
                    if fetchedArticles.isEmpty {
                        self.errorMessage = "No hay noticias disponibles."
                        print("[NewsViewModel] Warning: fetchedArticles está vacío")
                    } else {
                        self.articles = fetchedArticles
                    }
                case .failure(let error):
                    self.errorMessage = "Error al cargar las noticias: \(error.localizedDescription)"
                    print("[NewsViewModel][ERROR] \(error.localizedDescription)")
                }
            }
        }
    }
}
