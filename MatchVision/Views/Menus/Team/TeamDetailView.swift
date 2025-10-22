//
//  TeamDetailView.swift
//  MatchVision
//
//  Creado por Alejandro Escapa
//  Vista de detalle de un equipo mostrando logo, nombre, posición, puntos, estadísticas, plantilla y acciones de usuario.
//  Integrada con ThemeManager y soporte para favoritos, próximos partidos y compartir.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct TeamDetailView: View {
    let team: TeamStanding
    
    @State private var isFavorite: Bool = false
    @State private var showShareSheet: Bool = false
    @EnvironmentObject var theme: ThemeManager
    
    @StateObject private var playersVM: PlayersViewModel
    
    init(team: TeamStanding) {
        self.team = team
        _playersVM = StateObject(wrappedValue: PlayersViewModel(teamId: team.team.id, season: 2024))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                quickStatsCard
                goalsComparisonCard
                breakdownGrid
                actionButtons
                
                // Jugadores
                Divider().padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Plantilla")
                            .font(.headline)
                            .foregroundColor(theme.current.textPrimary)
                            .padding(.top, 5)
                        Spacer()
                    }
                    
                    if let err = playersVM.errorMessage {
                        Text("Error cargando jugadores: \(err)")
                            .foregroundColor(.red)
                            .font(.caption)
                    } else if playersVM.players.isEmpty && !playersVM.isLoading {
                        Text("No hay jugadores disponibles. Pulsa recargar si crees que hay un error.")
                            .font(.caption)
                            .foregroundColor(theme.current.textSecondary)
                    } else {
                        let sorted = sortedPlayers(playersVM.players)
                        ForEach(sorted) { player in
                            PlayerRow(player: player)
                                .environmentObject(theme)
                        }
                    }
                }
                .padding()
                .background(theme.current.card)
                .cornerRadius(12)
                .padding(.top, 6)
                
                Spacer(minLength: 24)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showShareSheet = true } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(theme.current.accent)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: [shareText()])
        }
        .onAppear {
            playersVM.load()
        }
        .background(theme.current.background.ignoresSafeArea())
    }
    
    // MARK: - Header + Cards
    private var header: some View {
        HStack(spacing: 16) {
            teamLogoView
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(team.team.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .foregroundColor(theme.current.textPrimary)
                    Spacer()
                    rankBadge
                }
                
                HStack(spacing: 10) {
                    Text("\(team.points) pts")
                        .font(.headline)
                        .foregroundColor(theme.current.textPrimary)
                }
            }
        }
        .padding()
        .background(theme.current.card)
        .cornerRadius(12)
        .shadow(color: theme.current.shadow.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var teamLogoView: some View {
        Group {
            if let logoStr = team.team.logo, let url = URL(string: logoStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(width: 84, height: 84)
                            .background(theme.current.placeholder)
                            .cornerRadius(12)
                    case .success(let image):
                        image.resizable().scaledToFit()
                            .frame(width: 84, height: 84)
                            .cornerRadius(12)
                            .shadow(radius: 4, y: 2)
                    case .failure:
                        placeholderLogo
                    @unknown default:
                        placeholderLogo
                    }
                }
            } else {
                placeholderLogo
            }
        }
    }
    
    private var placeholderLogo: some View {
        theme.current.placeholder
            .frame(width: 84, height: 84)
            .cornerRadius(12)
            .overlay(Image(systemName: "sportscourt").font(.title3).foregroundColor(theme.current.textSecondary.opacity(0.8)))
    }
    
    private var rankBadge: some View {
        Text("#\(team.rank)")
            .font(.subheadline).fontWeight(.semibold)
            .padding(.vertical, 6).padding(.horizontal, 10)
            .background(theme.current.accent.opacity(0.12))
            .foregroundColor(theme.current.accent)
            .cornerRadius(10)
    }
    
    private var quickStatsCard: some View {
        HStack(spacing: 12) {
            statColumn(title: "PJ", value: "\(team.all?.played ?? 0)")
            Divider().frame(height: 44).background(theme.current.textSecondary.opacity(0.3))
            statColumn(title: "V", value: "\(team.all?.win ?? 0)")
            statColumn(title: "E", value: "\(team.all?.draw ?? 0)")
            statColumn(title: "D", value: "\(team.all?.lose ?? 0)")
            Spacer()
            VStack(alignment: .trailing) {
                Text("GD").font(.caption).foregroundColor(theme.current.textSecondary)
                Text("\(team.goalsDiff ?? ((team.all?.goals?.forGoals ?? 0) - (team.all?.goals?.against ?? 0)))")
                    .font(.headline).fontWeight(.semibold)
                    .foregroundColor(theme.current.textPrimary)
            }
        }
        .padding()
        .background(theme.current.card)
        .cornerRadius(12)
    }
    
    private func statColumn(title: String, value: String) -> some View {
        VStack {
            Text(value).font(.headline).fontWeight(.semibold).foregroundColor(theme.current.textPrimary)
            Text(title).font(.caption).foregroundColor(theme.current.textSecondary)
        }
        .frame(minWidth: 44)
    }
    
    private var goalsComparisonCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Goles").font(.headline).foregroundColor(theme.current.textPrimary)
            HStack {
                VStack(alignment: .leading) { Text("Favor").font(.caption).foregroundColor(theme.current.textSecondary) }
                Spacer()
                VStack(alignment: .leading) { Text("En contra").font(.caption).foregroundColor(theme.current.textSecondary) }
            }
            GoalsBar(forGoals: team.all?.goals?.forGoals ?? 0, againstGoals: team.all?.goals?.against ?? 0)
                .frame(height: 16)
                .cornerRadius(8)
        }
        .padding()
        .background(theme.current.card)
        .cornerRadius(12)
    }
    
    private var breakdownGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Estadísticas detalladas")
                .font(.headline)
                .foregroundColor(theme.current.textPrimary)
            HStack(spacing: 12) {
                detailCard(title: "Posición", value: "#\(team.rank)")
                detailCard(title: "Puntos", value: "\(team.points)")
                detailCard(title: "Diferencia", value: "\(team.goalsDiff ?? 0)")
            }
            HStack(spacing: 12) {
                detailCard(title: "GF", value: "\(team.all?.goals?.forGoals ?? 0)")
                detailCard(title: "GC", value: "\(team.all?.goals?.against ?? 0)")
                detailCard(title: "Partidos", value: "\(team.all?.played ?? 0)")
            }
        }
        .padding()
        .background(theme.current.card)
        .cornerRadius(12)
    }
    
    private func detailCard(title: String, value: String) -> some View {
        VStack(alignment: .center, spacing: 6) {
            Text(value).font(.headline).fontWeight(.semibold).foregroundColor(theme.current.textPrimary)
            Text(title).font(.caption).foregroundColor(theme.current.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(theme.current.card)
        .cornerRadius(10)
        .shadow(color: theme.current.shadow.opacity(0.03), radius: 4, x: 0, y: 2)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                isFavorite.toggle()
                saveFavoriteTeam()
            } label: {
                HStack {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(isFavorite ? Color.yellow.opacity(0.15) : theme.current.card)
                .foregroundColor(isFavorite ? Color.yellow : theme.current.textPrimary)
                .cornerRadius(10)
            }.buttonStyle(.plain)
            
            NavigationLink {
                UpcomingMatchesView(teamId: team.team.id, teamName: team.team.name)
            } label: {
                HStack { Image(systemName: "calendar") }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10).padding(.horizontal, 14)
                    .background(theme.current.accent.opacity(0.12))
                    .foregroundColor(theme.current.accent)
                    .cornerRadius(10)
            }.buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func shareText() -> String {
        let gf = team.all?.goals?.forGoals ?? 0
        let ga = team.all?.goals?.against ?? 0
        return "\(team.team.name) — \(team.points) pts • PJ \(team.all?.played ?? 0) • GF \(gf) GA \(ga)"
    }
    
    // MARK: - Guardar equipo favorito en Firestore
    private func saveFavoriteTeam() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let favData: [String: Any] = [
            "favTeamName": team.team.name,
            "favTeamLogo": team.team.logo ?? "",
            "favTeamId": team.team.id
        ]
        db.collection("users").document(uid).setData(favData, merge: true) { error in
            if let error = error {
                print("Error guardando favorito:", error.localizedDescription)
            } else {
                print("Equipo favorito guardado correctamente")
            }
        }
    }
}

// MARK: - Sorting jugadores
private func sortedPlayers(_ players: [PlayerInfo]) -> [PlayerInfo] {
    players.sorted { a, b in
        func rank(of p: PlayerInfo) -> Int {
            let pos = p.position?.lowercased() ?? ""
            if pos.contains("portero") || pos.contains("arquero") || pos.contains("goalkeeper") || pos.contains("keeper") { return 0 }
            if pos.contains("defensa") || pos.contains("lateral") || pos.contains("defender") || pos.contains("back") { return 1 }
            if pos.contains("centrocampista") || pos.contains("medio") || pos.contains("midfielder") || pos.contains("mid") { return 2 }
            if pos.contains("delantero") || pos.contains("ataque") || pos.contains("forward") || pos.contains("attacker") || pos.contains("striker") { return 3 }
            return 4
        }
        let ra = rank(of: a)
        let rb = rank(of: b)
        if ra != rb { return ra < rb }
        return a.displayName.localizedCaseInsensitiveCompare(b.displayName) == .orderedAscending
    }
}

// MARK: - PlayerRow
struct PlayerRow: View {
    let player: PlayerInfo
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            if let photo = player.photo, let url = URL(string: photo) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.3).frame(width: 44, height: 44).cornerRadius(6)
                    case .success(let image):
                        image.resizable().scaledToFill().frame(width: 44, height: 44).cornerRadius(6).clipped()
                    case .failure(_):
                        Color.gray.opacity(0.3).frame(width: 44, height: 44).cornerRadius(6)
                    @unknown default:
                        Color.gray.opacity(0.3).frame(width: 44, height: 44).cornerRadius(6)
                    }
                }
            } else {
                Color.gray.opacity(0.3).frame(width: 44, height: 44).cornerRadius(6)
            }

            NavigationLink(destination: PlayerDetailView(player: player).environmentObject(theme)) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(player.displayName)
                            .font(.subheadline)
                            .foregroundColor(theme.current.textPrimary)
                            .lineLimit(1)

                        if let pos = player.position, !pos.isEmpty {
                            Text(pos)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(player.tagColor.opacity(0.08))
                                .foregroundColor(player.tagColor)
                                .cornerRadius(8)
                        }
                        Spacer(minLength: 0)
                    }

                    let subtitle = [
                        player.nationality,
                        player.age.map { "\($0) años" }
                    ].compactMap { $0 }.joined(separator: " · ")

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(theme.current.textSecondary)
                        .lineLimit(1)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            Spacer()
            Image(systemName: "chevron.right").foregroundColor(theme.current.textSecondary)
        }
        .padding(.horizontal, 8)
        .background(theme.current.background.opacity(0.0001))
        .contentShape(Rectangle())
        Divider().padding(.leading, 56)
    }
}

// MARK: - GoalsBar
struct GoalsBar: View {
    let forGoals: Int
    let againstGoals: Int

    private var total: Double { Double(forGoals + againstGoals) == 0 ? 1 : Double(forGoals + againstGoals) }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let forWidth = width * CGFloat(Double(forGoals) / total)
            let againstWidth = width - forWidth

            HStack(spacing: 0) {
                Rectangle().fill(Color(.systemGreen)).frame(width: max(0, forWidth))
                Rectangle().fill(Color(.systemRed)).frame(width: max(0, againstWidth))
            }
            .cornerRadius(8)
            .overlay(
                HStack {
                    Text("\(forGoals)").font(.caption2).foregroundColor(.white).padding(.leading, 6)
                    Spacer()
                    Text("\(againstGoals)").font(.caption2).foregroundColor(.white).padding(.trailing, 6)
                }
            )
        }
    }
}
