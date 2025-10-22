//
//  LeagueStandingsView.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Tabla de posiciones de una liga específica, con navegación a TeamDetailView.
//  Maneja carga, error y vacío. Adaptada a ThemeManager.
//

import SwiftUI

struct LeagueStandingsView: View {
    // MARK: - Propiedades principales
    let leagueId: Int
    let leagueName: String
    let leagueLogo: String?
    
    @EnvironmentObject var theme: ThemeManager
    @State private var standings: [TeamStanding] = [] // Lista de equipos con posiciones
    @State private var isLoading = false             // Estado de carga
    @State private var errorMessage: String?         // Mensaje de error si falla la carga
    
    private let api = APIService() // Servicio API para obtener datos

    // MARK: - Cuerpo principal
    var body: some View {
        VStack(spacing: 0) {
            contentView
                .padding(.horizontal)
                .padding(.top, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(theme.current.background.ignoresSafeArea())
        }
        .navigationTitle(leagueName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Botón de recarga manual
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { loadStandings() } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(theme.current.accent)
                }
            }
        }
        .onAppear { loadStandings() } // Carga inicial de la tabla al aparecer
    }
    
    // MARK: - Contenido principal según estado
    @ViewBuilder
    private var contentView: some View {
        if isLoading {
            // Vista de carga
            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: theme.current.accent))
                    .scaleEffect(1.0)
                Text("Cargando clasificación...")
                    .font(.subheadline)
                    .foregroundColor(theme.current.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = errorMessage {
            // Vista de error
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                Text("Error al cargar: \(error)")
                    .multilineTextAlignment(.center)
                    .foregroundColor(theme.current.textSecondary)
                Button("Reintentar") { loadStandings() }
                    .buttonStyle(.borderedProminent)
                    .tint(theme.current.accent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        } else {
            // Vista de tabla de posiciones
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(standings) { team in
                        NavigationLink(destination: TeamDetailView(team: team).environmentObject(theme)) {
                            standingRow(team: team) // Fila de cada equipo
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: - Fila de clasificación de equipo
    private func standingRow(team: TeamStanding) -> some View {
        HStack(spacing: 12) {
            // Posición del equipo
            Text("\(team.rank)")
                .font(.subheadline).fontWeight(.semibold)
                .frame(width: 36, height: 36)
                .background(theme.current.placeholder.opacity(0.25))
                .foregroundColor(theme.current.textPrimary)
                .cornerRadius(8)
            
            // Logo del equipo
            if let logoUrl = team.team.logo, let url = URL(string: logoUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty, .failure:
                        theme.current.placeholder
                            .frame(width: 40, height: 28)
                            .cornerRadius(6)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 28)
                            .cornerRadius(6)
                    @unknown default:
                        theme.current.placeholder
                            .frame(width: 40, height: 28)
                            .cornerRadius(6)
                    }
                }
            } else {
                theme.current.placeholder
                    .frame(width: 40, height: 28)
                    .cornerRadius(6)
            }
            
            // Nombre y estadísticas básicas del equipo
            VStack(alignment: .leading, spacing: 4) {
                Text(team.team.name)
                    .font(.subheadline)
                    .foregroundColor(theme.current.textPrimary)
                    .lineLimit(1)
                Text("\(team.all?.played ?? 0) PJ  •  GF \(team.all?.goals?.forGoals ?? 0)  •  GC \(team.all?.goals?.against ?? 0)")
                    .font(.caption2)
                    .foregroundColor(theme.current.textSecondary)
            }
            
            Spacer()
            
            // Puntos del equipo
            Text("\(team.points)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(theme.current.textPrimary)
                .padding(.trailing, 8)
        }
        .padding(12)
        .background(theme.current.card)
        .cornerRadius(12)
        .shadow(color: theme.current.shadow, radius: 5, x: 0, y: 3)
        .padding(.horizontal, 2)
    }
    
    // MARK: - Networking: carga de clasificación
    private func loadStandings() {
        isLoading = true
        errorMessage = nil
        standings = []
        
        api.getLeagueStatsSeason2023(leagueId: leagueId) { result in
            DispatchQueue.main.async {
                isLoading = false
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

// MARK: - Preview
struct LeagueStandingsView_Previews: PreviewProvider {
    static var sampleTeam = TeamStanding(
        rank: 1,
        team: StandingTeam(id: 85, name: "Paris Saint Germain", logo: "https://media.api-sports.io/football/teams/85.png"),
        points: 76,
        goalsDiff: 48,
        group: "Ligue 1",
        form: "WWLDW",
        status: "same",
        description: "Promotion - Champions League",
        all: MatchStats(played: 34, win: 22, draw: 10, lose: 2, goals: GoalsStats(forGoals: 81, against: 33)),
        home: MatchStats(played: 17, win: 9, draw: 6, lose: 2, goals: GoalsStats(forGoals: 42, against: 22)),
        away: MatchStats(played: 17, win: 13, draw: 4, lose: 0, goals: GoalsStats(forGoals: 39, against: 11)),
        update: "2024-06-05T00:00:00+00:00"
    )
    
    static var previews: some View {
        NavigationStack {
            LeagueStandingsView(leagueId: 1, leagueName: "Ligue 1", leagueLogo: sampleTeam.team.logo)
                .environmentObject(ThemeManager())
        }
        .preferredColorScheme(.light)
        
        NavigationStack {
            LeagueStandingsView(leagueId: 1, leagueName: "Ligue 1", leagueLogo: sampleTeam.team.logo)
                .environmentObject(ThemeManager())
        }
        .preferredColorScheme(.dark)
    }
}
