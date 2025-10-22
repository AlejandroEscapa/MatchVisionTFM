//
//  NewsModel.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Modelos para representar noticias deportivas obtenidas desde la API NewsAPI.
//

import Foundation

// MARK: - Respuesta de noticias
/// Estructura principal devuelta por la API al solicitar noticias
struct NewsResponse: Codable {
    let status: String            // Estado de la respuesta (ok, error, etc.)
    let totalResults: Int         // Total de artículos encontrados
    let articles: [Article]       // Lista de artículos
}

// MARK: - Artículo individual
struct Article: Codable, Identifiable {
    // ID estable: preferimos URL, si no existe se genera UUID
    var id: String { url ?? UUID().uuidString }

    let source: Source?           // Fuente de la noticia
    let author: String?           // Autor
    let title: String?            // Título del artículo
    let description: String?      // Descripción breve
    let url: String?              // Enlace al artículo
    let urlToImage: String?       // Imagen destacada
    let publishedAt: String?      // Fecha de publicación
    let content: String?          // Contenido completo

    // MARK: - Fuente
    struct Source: Codable {
        let id: String?
        let name: String?
    }
}
