//
//  APINews.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Servicio para obtener noticias deportivas desde NewsAPI.org.
//  Gestiona peticiones HTTP, parseo de JSON y entrega de artículos listos para la UI.
//

import Foundation

// MARK: - APINews
final class APINews {

    // MARK: - Constantes
    private let apiKey = "860f15b681614860b332dc2f3cac8f02" // Clave de la API de noticias
    private let baseURL = "https://newsapi.org/v2/top-headlines" // URL base
    
    private enum Localized {
        static let invalidURL = "URL inválida"
        static let noHTTPResponse = "No se recibió respuesta HTTP"
        static let noData = "Sin datos del servidor"
    }

    // MARK: - Propiedades
    private let session: URLSession

    // MARK: - Inicializador
    /// Configura la sesión de red con timeout y cabeceras por defecto
    init(timeout: TimeInterval = 20) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.httpAdditionalHeaders = ["Accept": "application/json"]
        self.session = URLSession(configuration: config)
    }

    // MARK: - API pública
    /// Obtiene noticias de fútbol / deportivas
    func fetchFootballNews(language: String = "en",
                           country: String? = nil,
                           pageSize: Int = 20,
                           completion: @escaping (Result<[Article], Error>) -> Void) {

        // Construye la URL
        guard let url = makeURL(language: language, country: country, pageSize: pageSize) else {
            completeOnMain(.failure(makeError(description: Localized.invalidURL)), completion: completion)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Realiza la petición
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                self.completeOnMain(.failure(error), completion: completion)
                return
            }

            guard let http = response as? HTTPURLResponse else {
                self.completeOnMain(.failure(self.makeError(description: Localized.noHTTPResponse)), completion: completion)
                return
            }

            guard (200...299).contains(http.statusCode) else {
                let err = NSError(domain: "APINews.HTTP", code: http.statusCode,
                                  userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"])
                self.completeOnMain(.failure(err), completion: completion)
                return
            }

            guard let data = data else {
                self.completeOnMain(.failure(self.makeError(description: Localized.noData)), completion: completion)
                return
            }

            // Decodifica JSON a modelo `NewsResponse`
            do {
                let decoded = try JSONDecoder().decode(NewsResponse.self, from: data)
                self.completeOnMain(.success(decoded.articles), completion: completion)
            } catch {
                self.completeOnMain(.failure(error), completion: completion)
            }
        }.resume()
    }

    // MARK: - Helpers
    /// Construye URL con query items según parámetros
    private func makeURL(language: String, country: String?, pageSize: Int) -> URL? {
        var components = URLComponents(string: baseURL)
        var queryItems = [
            URLQueryItem(name: "category", value: "sports"),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        if let country = country {
            queryItems.append(URLQueryItem(name: "country", value: country))
        }
        components?.queryItems = queryItems
        return components?.url
    }

    /// Crea NSError con descripción personalizada
    private func makeError(description: String) -> NSError {
        NSError(domain: "APINews", code: 0, userInfo: [NSLocalizedDescriptionKey: description])
    }

    /// Asegura que el callback se ejecute en el hilo principal
    private func completeOnMain<T>(_ result: Result<T, Error>, completion: @escaping (Result<T, Error>) -> Void) {
        DispatchQueue.main.async { completion(result) }
    }
}
