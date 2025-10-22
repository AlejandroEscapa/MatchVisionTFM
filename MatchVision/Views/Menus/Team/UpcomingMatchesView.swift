//
//  UpcomingMatchesView.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Vista de partidos próximos de un equipo, adaptada a ThemeManager.
//

import SwiftUI

struct UpcomingMatchesView: View {
    let teamId: Int
    let teamName: String

    @StateObject private var vm: UpcomingMatchesViewModel
    @EnvironmentObject var theme: ThemeManager

    init(teamId: Int, teamName: String) {
        self.teamId = teamId
        self.teamName = teamName
        _vm = StateObject(wrappedValue: UpcomingMatchesViewModel(teamId: teamId))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                // MARK: - HEADER
                headerView

                // MARK: - LISTA DE PARTIDOS
                matchesList
            }
            .padding(.bottom)
            .onAppear { vm.load() }
            .navigationTitle(teamName)
            .navigationBarTitleDisplayMode(.inline)
            .background(theme.current.background.ignoresSafeArea())
        }
    }

    // MARK: - HEADER
    private var headerView: some View {
        HStack {
            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: theme.current.accent))
                    .scaleEffect(0.9)
                Text("Cargando partidos...")
                    .font(.footnote)
                    .foregroundColor(theme.current.textSecondary)
            } else if let errorMessage = vm.errorMessage {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.leading)
            } else {
                Text("Próximos \(vm.matches.count) partido(s)")
                    .font(.footnote)
                    .foregroundColor(theme.current.textPrimary)
            }

            Spacer()
        }
        .padding(.top, 30)
        .padding(.horizontal, 20)
    }

    // MARK: - LISTA DE PARTIDOS
    private var matchesList: some View {
        Group {
            if vm.matches.isEmpty && !vm.isLoading {
                VStack {
                    Spacer()
                    Image(systemName: "calendar.badge.exclamationmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .foregroundColor(theme.current.textPrimary)
                    Text("No hay partidos futuros.")
                        .font(.subheadline)
                        .foregroundColor(theme.current.textPrimary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(vm.matches) { match in
                            matchCard(match)
                                .padding(.horizontal)
                        }
                        Spacer(minLength: 24)
                    }
                    .padding(.top, 6)
                }
                .refreshable { vm.load() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - CARD DE PARTIDO
    private func matchCard(_ match: MatchItem) -> some View {
        VStack(spacing: 0) {

            // Fecha y estado
            HStack {
                Text(formattedDate(match.fixture.date))
                    .font(.caption2)
                    .foregroundColor(theme.current.textSecondary)
                    .padding(.top, 8)

                Spacer()

                Text(match.fixture.status.short.uppercased())
                    .font(.caption2)
                    .foregroundColor(theme.current.textSecondary)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 12)

            // Equipos y goles
            HStack {
                teamRow(match.teams.home)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 4) {
                    Text("\(match.goals.home ?? 0)").font(.headline).frame(width: 24)
                    Text("-").font(.headline)
                    Text("\(match.goals.away ?? 0)").font(.headline).frame(width: 24)
                }
                .foregroundColor(theme.current.textPrimary)

                teamRow(match.teams.away)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(12)
        }
        .background(theme.current.card)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - VISTA EQUIPO
    private func teamRow(_ team: TeamInfo) -> some View {
        HStack(spacing: 6) {
            if let urlStr = team.logo, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: Color.gray.opacity(0.2)
                    case .success(let img): img.resizable().scaledToFit()
                    case .failure: Color.gray.opacity(0.2)
                    @unknown default: Color.gray.opacity(0.2)
                    }
                }
                .frame(width: 28, height: 28)
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(theme.current.placeholder)
                    .frame(width: 28, height: 28)
            }

            Text(team.name)
                .font(.subheadline)
                .foregroundColor(theme.current.textPrimary)
        }
    }

    // MARK: - FORMATEAR FECHA
    private func formattedDate(_ isoDate: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: isoDate)
            ?? ISO8601DateFormatter().date(from: isoDate) {

            let f = DateFormatter()
            f.dateFormat = "HH:mm"
            return f.string(from: date)
        }
        return "--:--"
    }
}
