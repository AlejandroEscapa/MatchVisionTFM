//
//  HomeView.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Vista principal con secciones de ligas y noticias destacadas.
//  Adaptada a ThemeManager y con pull-to-refresh.
//

import SwiftUI

// Padding general para los títulos de sección
private let sectionTitlePadding = EdgeInsets(top: 10, leading: 12, bottom: 5, trailing: 12)

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @EnvironmentObject var theme: ThemeManager

    // Referencias para tamaños de tarjetas
    private let referenceCardImageHeight: CGFloat = 180
    private let referenceCardTotalHeight: CGFloat = 320
    private var listCardWidth: CGFloat { UIScreen.main.bounds.width - 40 } // padding horizontal global 20 + 20

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    // Sección de ligas
                    leaguesSection()

                    // Sección de noticia destacada
                    FeaturedNewsSection(
                        featured: $vm.featuredArticle,
                        isLoading: vm.isLoadingNews,
                        errorMessage: vm.newsErrorMessage,
                        onReload: { vm.loadNews() },
                        imageHeight: referenceCardImageHeight,
                        cardWidth: listCardWidth
                    )

                    // Sección de noticias generales
                    NewsSection(
                        articles: vm.articlesForList,
                        isLoading: vm.isLoadingNews,
                        errorMessage: vm.newsErrorMessage,
                        onReload: { vm.loadNews() },
                        imageHeight: referenceCardImageHeight,
                        cardWidth: listCardWidth,
                        sectionHeight: referenceCardTotalHeight
                    )

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top)
            }
            .refreshable {
                vm.loadLeagues()
                vm.loadNews()
            }
            .background(theme.current.background.ignoresSafeArea())
        }
        .navigationLogo()
        .background(theme.current.background.ignoresSafeArea())
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Sección de ligas
    @ViewBuilder
    private func leaguesSection() -> some View {
        CardView {
            VStack(spacing: 15) {
                HStack {
                    Text("TODAS LAS LIGAS").bold()
                        .foregroundColor(theme.current.textPrimary)
                    Spacer()
                    NavigationLink(destination: LeagueListView(leagues: vm.leagues)) {
                        HStack(spacing: 6) {
                            Text("Ver lista").foregroundColor(theme.current.accent)
                            Image(systemName: "chevron.right")
                                .foregroundColor(theme.current.textPrimary)
                        }
                    }
                }
                .padding(sectionTitlePadding)

                ScrollView(.horizontal, showsIndicators: false) {
                    let cardWidth: CGFloat = 100
                    let spacing: CGFloat = 16
                    let visibleCards: CGFloat = min(3, CGFloat(vm.leagues.count))
                    let leadingPadding = max(0, (UIScreen.main.bounds.width
                                                 - (visibleCards * cardWidth)
                                                 - ((visibleCards - 1) * spacing)) / 2 - 20)

                    LazyHStack(spacing: spacing) {
                        if vm.leagues.isEmpty && vm.leaguesErrorMessage == nil {
                            // Placeholder mientras se cargan ligas
                            ForEach(0..<6, id: \.self) { _ in
                                placeholderLeagueCard()
                            }
                        } else if let error = vm.leaguesErrorMessage {
                            // Error al cargar ligas
                            VStack(spacing: 8) {
                                Text("Error: \(error)").foregroundColor(.red)
                                Button("Reintentar") { vm.loadLeagues() }
                                    .buttonStyle(.bordered)
                            }
                            .frame(width: UIScreen.main.bounds.width - 40)
                        } else {
                            // Ligas cargadas
                            ForEach(vm.leagues) { item in
                                NavigationLink(destination: LeagueStandingsView(
                                    leagueId: item.league.id,
                                    leagueName: item.league.name,
                                    leagueLogo: item.league.logo)
                                ) {
                                    leagueCard(for: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.leading, leadingPadding)
                    .padding(.trailing, 10)
                }
            }
        }
    }

    // MARK: - Placeholder de liga
    private func placeholderLeagueCard() -> some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.current.placeholder)
                .frame(width: 100, height: 70)
            RoundedRectangle(cornerRadius: 6)
                .fill(theme.current.placeholder)
                .frame(width: 90, height: 16)
        }
        .frame(width: 100)
        .background(theme.current.card)
        .cornerRadius(12)
        .shadow(color: theme.current.shadow, radius: 4, x: 0, y: 2)
    }

    // MARK: - Tarjeta de liga
    private func leagueCard(for item: LeagueItem) -> some View {
        VStack(spacing: 8) {
            if let logoURL = item.league.logo, let url = URL(string: logoURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: Color(theme.current.placeholder)
                    case .success(let image): image.resizable().scaledToFit().frame(width: 80, height: 60)
                    case .failure: Color(theme.current.placeholder)
                    @unknown default: Color(theme.current.placeholder)
                    }
                }
                .padding(.vertical, 8)
            }
            Text(item.league.name.displayLeagueName())
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(theme.current.textPrimary)
                .lineLimit(1)
        }
        .frame(width: 100)
        .padding(.bottom, 5)
        .background(theme.current.background.opacity(0.2))
        .cornerRadius(12)
        .shadow(color: theme.current.shadow, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Sección de noticia destacada
struct FeaturedNewsSection: View {
    @Binding var featured: Article?
    let isLoading: Bool
    let errorMessage: String?
    let onReload: () -> Void
    let imageHeight: CGFloat
    let cardWidth: CGFloat
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    Text("NOTICIA DESTACADA").bold()
                        .foregroundColor(theme.current.textPrimary)
                    Spacer()
                    Button { onReload() } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(theme.current.accent)
                    }
                }
                .padding(sectionTitlePadding)
                
                if isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 8) {
                        Text("No se pudo cargar la noticia destacada")
                            .bold()
                            .font(.subheadline)
                            .foregroundColor(theme.current.textSecondary)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(theme.current.textSecondary)
                            .multilineTextAlignment(.center)
                        Button("Reintentar") { onReload() }
                    }
                } else if let article = featured {
                    FeaturedArticleCard(
                        article: article,
                        imageHeight: imageHeight,
                        cardWidth: cardWidth
                    )
                    .environmentObject(theme)
                } else {
                    Text("No hay noticia destacada ahora.")
                        .font(.subheadline)
                        .foregroundColor(theme.current.textSecondary)
                }
            }
        }
    }
}

// MARK: - Sección de noticias
struct NewsSection: View {
    let articles: [Article]
    let isLoading: Bool
    let errorMessage: String?
    let onReload: () -> Void

    let imageHeight: CGFloat
    let cardWidth: CGFloat
    let sectionHeight: CGFloat

    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    Text("NOTICIAS")
                        .bold()
                        .foregroundColor(theme.current.textPrimary)
                    Spacer()
                    Button { onReload() } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(theme.current.accent)
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 12, bottom: 0, trailing: 12))

                if isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }
                        .padding(.vertical, 10)
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 8) {
                        Text("No se pudieron cargar noticias")
                            .bold()
                            .font(.subheadline)
                            .foregroundColor(theme.current.textSecondary)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(theme.current.textSecondary)
                            .multilineTextAlignment(.center)
                        Button("Reintentar") { onReload() }
                    }
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                } else if articles.isEmpty {
                    Text("No hay noticias disponibles ahora.")
                        .font(.subheadline)
                        .foregroundColor(theme.current.textSecondary)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(Array(articles.enumerated()), id: \.element.idOrFallback) { index, article in
                                FeaturedArticleCard(
                                    article: article,
                                    imageHeight: imageHeight,
                                    cardWidth: cardWidth
                                )
                                .environmentObject(theme)
                                .padding(.leading, index == 0 ? 0 : 0)
                            }
                        }
                        .padding(.horizontal, 0)
                    }
                    .frame(height: sectionHeight)
                }
            }
        }
    }
}

// MARK: - Tarjeta de artículo
struct FeaturedArticleCard: View {
    let article: Article
    let imageHeight: CGFloat
    let cardWidth: CGFloat
    @EnvironmentObject var theme: ThemeManager

    private let innerPadding: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {

            // Imagen del artículo
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(theme.current.placeholder.opacity(0.1))

                if let imgStr = article.urlToImage, let url = URL(string: imgStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Color(theme.current.placeholder)
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            Color(theme.current.placeholder)
                        @unknown default:
                            Color(theme.current.placeholder)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .frame(height: imageHeight)
            .clipped()

            // Título
            Text(article.title ?? "Sin título")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(theme.current.textPrimary)
                .lineLimit(3)

            // Fuente y fecha
            HStack(spacing: 8) {
                Text(article.source?.name ?? "")
                    .font(.caption)
                    .foregroundColor(theme.current.textSecondary)

                Spacer()

                if let date = article.publishedAt, let formatted = dateFormatted(from: date) {
                    Text(formatted)
                        .font(.caption2)
                        .foregroundColor(theme.current.textSecondary)
                }
            }

            // Link al artículo completo
            if let urlStr = article.url, let url = URL(string: urlStr) {
                Link(destination: url) {
                    Text("Leer artículo completo")
                        .font(.caption)
                        .bold()
                        .padding(.vertical, 7)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity)
                        .background(theme.current.card.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(innerPadding)
        .padding(.bottom, 12)
        .frame(width: cardWidth)
        .background(theme.current.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: theme.current.shadow.opacity(0.4), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(theme.current.placeholder.opacity(0.18), lineWidth: 1)
        )
    }

    // MARK: - Formateo de fecha
    private func dateFormatted(from iso: String) -> String? {
        let isoF = ISO8601DateFormatter()
        isoF.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = isoF.date(from: iso)
        if date == nil { date = ISO8601DateFormatter().date(from: iso) }
        guard let d = date else { return nil }
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df.string(from: d)
    }
}

// MARK: - Tarjeta genérica
struct CardView<Content: View>: View {
    let content: Content
    @EnvironmentObject var theme: ThemeManager

    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.current.card)
                    .shadow(color: theme.current.shadow, radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal, 0)
            .padding(.top, 6)
    }
}

// MARK: - Extensiones auxiliares
private extension Article {
    var idOrFallback: String {
        if let u = self.url, !u.isEmpty { return u }
        if let t = self.title, !t.isEmpty { return t }
        if let p = self.publishedAt, !p.isEmpty { return p }
        return UUID().uuidString
    }
}

private extension String {
    func displayLeagueName() -> String {
        let words = self.split(separator: " ")
        guard let first = words.first else { return self }
        if words.count > 1 {
            let second = words[1]
            if second.count > 4 { return String(first) } else { return self }
        }
        return self
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView().environmentObject(ThemeManager()).preferredColorScheme(.light)
            HomeView().environmentObject(ThemeManager()).preferredColorScheme(.dark)
        }
    }
}
