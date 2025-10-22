//
//  LeagueListView.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Lista de ligas disponibles con logo y nombre, navegando a LeagueStandingsView.
//  Adaptada a ThemeManager y sin separadores nativos.
//

import SwiftUI

struct LeagueListView: View {
    let leagues: [LeagueItem]                // Lista de ligas a mostrar
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        List {
            // Itera sobre cada liga y crea un NavigationLink
            ForEach(leagues, id: \.league.id) { item in
                NavigationLink(
                    destination: LeagueStandingsView(
                        leagueId: item.league.id,
                        leagueName: item.league.name,
                        leagueLogo: item.league.logo
                    )
                    .environmentObject(theme) // Pasa el ThemeManager al destino
                ) {
                    HStack(spacing: 12) {
                        leagueLogoView(urlString: item.league.logo) // Logo de la liga

                        Text(item.league.name)
                            .font(.body)
                            .foregroundColor(theme.current.textPrimary)

                        Spacer()
                    }
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .listRowBackground(theme.current.card) // Fondo de la celda según tema
            }
        }
        .listStyle(.plain) // Estilo simple de lista
        .scrollContentBackground(.hidden)
        .background(theme.current.background.ignoresSafeArea()) // Fondo de toda la vista
        .navigationTitle("Ligas")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Quita los separadores nativos de UITableView
            UITableView.appearance().separatorStyle = .none

            // Configuración de la barra de navegación para mantener los colores del tema
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor(theme.current.card)
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
            UINavigationBar.appearance().compactAppearance = navBarAppearance
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(theme.current.card, for: .navigationBar)
    }

    // MARK: - Logo de liga
    @ViewBuilder
    private func leagueLogoView(urlString: String?) -> some View {
        if let logo = urlString, let url = URL(string: logo) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    theme.current.placeholder
                        .frame(width: 48, height: 36)
                        .cornerRadius(6)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 36)
                        .cornerRadius(6)
                case .failure:
                    theme.current.placeholder
                        .frame(width: 48, height: 36)
                        .cornerRadius(6)
                @unknown default:
                    theme.current.placeholder
                        .frame(width: 48, height: 36)
                        .cornerRadius(6)
                }
            }
        } else {
            theme.current.placeholder
                .frame(width: 48, height: 36)
                .cornerRadius(6)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        LeagueListView(leagues: [])
            .environmentObject(ThemeManager())
    }
}
