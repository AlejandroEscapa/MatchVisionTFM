//
//  PlayerDetailView.swift
//  MatchVision
//
//  Creado por Alejandro Escapa
//  Vista detallada de un jugador con estadísticas, ficha y opciones de compartir
//

import SwiftUI

struct PlayerDetailView: View {
    let player: PlayerInfo

    @State private var isFavorite: Bool = false
    @State private var showShareSheet: Bool = false
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                quickStatsCard
                breakdownGrid
                additionalStatsCard
                actionButtons
                Spacer(minLength: 24)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: [shareText()])
        }
        .background(theme.current.background.ignoresSafeArea())
    }

    // MARK: - Header con foto, nombre, posición y nacionalidad
    private var header: some View {
        HStack(spacing: 16) {
            playerPhoto
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(player.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .foregroundColor(theme.current.textPrimary)
                    Spacer()
                }

                HStack(spacing: 8) {
                    if let pos = player.position {
                        Text(pos)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(player.tagColor.opacity(0.12))
                            .foregroundColor(player.tagColor)
                            .cornerRadius(8)
                    }

                    if let nat = player.nationality {
                        Text(nat)
                            .font(.caption)
                            .foregroundColor(theme.current.textSecondary)
                    }

                    if let age = player.age {
                        Text("· \(age)")
                            .font(.caption)
                            .foregroundColor(theme.current.textSecondary)
                    }
                }
            }
        }
        .padding()
        .background(theme.current.card)
        .cornerRadius(12)
        .shadow(color: theme.current.shadow.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    // MARK: - Foto del jugador con placeholder
    private var playerPhoto: some View {
        Group {
            if let photo = player.photo, let url = URL(string: photo) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 92, height: 92)
                            .background(theme.current.placeholder)
                            .cornerRadius(12)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 92, height: 92)
                            .cornerRadius(12)
                            .clipped()
                            .shadow(color: theme.current.shadow, radius: 4, x: 0, y: 2)
                    case .failure:
                        placeholderPhoto
                    @unknown default:
                        placeholderPhoto
                    }
                }
            } else {
                placeholderPhoto
            }
        }
    }

    private var placeholderPhoto: some View {
        theme.current.placeholder
            .frame(width: 92, height: 92)
            .cornerRadius(12)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.title)
                    .foregroundColor(theme.current.textSecondary.opacity(0.8))
            )
    }

    // MARK: - Card con altura, peso y edad
    private var quickStatsCard: some View {
        HStack(spacing: 12) {
            statColumn(title: "Altura", value: player.height.map { "\($0) cm" } ?? "—")
                .frame(maxWidth: .infinity)
            separator
            statColumn(title: "Peso", value: player.weight.map { "\($0) kg" } ?? "—")
                .frame(maxWidth: .infinity)
            separator
            statColumn(title: "Edad", value: player.age.map { "\($0) años"} ?? "—")
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background(theme.current.card)
        .cornerRadius(12)
    }

    private func statColumn(title: String, value: String) -> some View {
        VStack {
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(theme.current.textPrimary)
            Text(title)
                .font(.caption)
                .foregroundColor(theme.current.textSecondary)
        }
        .frame(minWidth: 64)
    }

    // MARK: - Breakdown grid con ficha de jugador
    private var breakdownGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ficha de jugador")
                .font(.headline)
                .foregroundColor(theme.current.textPrimary)
            Rectangle()
                .fill(theme.current.textSecondary.opacity(0.2))
                .frame(height: 1)
                .padding(.vertical, 4)

            HStack(spacing: 12) {
                detailCard(title: "Posición", value: player.position ?? "—")
                separator
                detailCard(title: "País", value: player.nationality ?? "—")
            }

            HStack(spacing: 12) {
                detailCard(title: "Partidos", value: "\(player.performance?.appearances ?? 0)")
                separator
                detailCard(title: "Goles", value: "\(player.performance?.goals ?? 0)")
                separator
                detailCard(title: "Asists", value: "\(player.performance?.assists ?? 0)")
            }
        }
        .padding()
        .background(theme.current.card)
        .cornerRadius(12)
    }

    private func detailCard(title: String, value: String) -> some View {
        VStack(alignment: .center, spacing: 6) {
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(theme.current.textPrimary)
                .multilineTextAlignment(.center)
            Text(title)
                .font(.caption)
                .foregroundColor(theme.current.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(theme.current.card)
        .cornerRadius(10)
        .shadow(color: theme.current.shadow.opacity(0.03), radius: 4, x: 0, y: 2)
    }

    // MARK: - Estadísticas adicionales
    private var additionalStatsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Estadísticas")
                .font(.headline)
                .foregroundColor(theme.current.textPrimary)
            Rectangle()
                .fill(theme.current.textSecondary.opacity(0.2))
                .frame(height: 1)
                .padding(.vertical, 4)

            if hasDetailedStats {
                HStack(spacing: 12) {
                    if let yellow = player.performance?.yellow { statLabel(title: "Amarillas", value: "\(yellow)") }
                    if let red = player.performance?.red { separator; statLabel(title: "Rojas", value: "\(red)") }
                    if let rating = player.performance?.rating { separator; statLabel(title: "Rating", value: String(format: "%.2f", rating)) }
                }
                .frame(maxWidth: .infinity)
            } else {
                Text("No hay estadísticas detalladas disponibles para este jugador en la respuesta actual de la API.")
                    .font(.caption)
                    .foregroundColor(theme.current.textSecondary)
            }
        }
        .padding()
        .background(theme.current.card)
        .cornerRadius(12)
    }

    private var hasDetailedStats: Bool {
        let perf = player.performance
        return perf?.minutes != nil || perf?.yellow != nil || perf?.red != nil || perf?.rating != nil
    }

    private func statLabel(title: String, value: String) -> some View {
        VStack {
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(theme.current.textPrimary)
            Text(title)
                .font(.caption)
                .foregroundColor(theme.current.textSecondary)
        }
        .frame(minWidth: 60)
        .padding(6)
        .background(theme.current.background.opacity(0.05))
        .cornerRadius(8)
    }

    // MARK: - Botones de acción
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                showShareSheet = true
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(theme.current.accent.opacity(0.12))
                .foregroundColor(theme.current.accent)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Separador uniforme
    private var separator: some View {
        Rectangle()
            .fill(theme.current.textSecondary.opacity(0.25))
            .frame(width: 1, height: 48)
    }

    // MARK: - Helpers
    private func shareText() -> String {
        var parts: [String] = []
        parts.append(player.displayName)
        if let pos = player.position { parts.append(pos) }
        if let nat = player.nationality { parts.append(nat) }
        return parts.joined(separator: " • ")
    }
}

// MARK: - Preview
struct PlayerDetailView_Previews: PreviewProvider {
    static var sample: PlayerInfo {
        PlayerInfo(
            id: 10,
            name: "Kylian Mbappé",
            firstname: "Kylian",
            lastname: "Mbappé",
            firstnameLocal: nil,
            lastnameLocal: nil,
            age: 25,
            nationality: "Francia",
            height: "178 cm",
            weight: "73 kg",
            photo: "https://media.api-sports.io/football/players/203.jpg",
            position: "Delantero",
            performance: nil
        )
    }

    static var previews: some View {
        NavigationStack {
            PlayerDetailView(player: sample)
                .environmentObject(ThemeManager())
        }
        .preferredColorScheme(.light)

        NavigationStack {
            PlayerDetailView(player: sample)
                .environmentObject(ThemeManager())
        }
        .preferredColorScheme(.dark)
    }
}
