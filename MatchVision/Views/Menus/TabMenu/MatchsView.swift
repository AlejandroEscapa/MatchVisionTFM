//
//  MatchsView.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Muestra partidos de una fecha específica, agrupados por liga.
//  Estilo “SofaScore”, navegación a TeamDetailView, pull-to-refresh y soporte ThemeManager.
//

import SwiftUI

struct MatchsView: View {
    // MARK: - Propiedades principales
    @EnvironmentObject var vm: MatchsViewModel // ViewModel que maneja los partidos
    @EnvironmentObject var theme: ThemeManager // Tema actual
    @State private var selectedDate = Date()   // Fecha seleccionada

    // MARK: - Cuerpo principal
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Header con estado y DatePicker
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
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("Mostrando \(vm.matches.count) partido(s)")
                            .font(.footnote)
                            .foregroundColor(theme.current.textPrimary)
                    }

                    Spacer()

                    // Selector de fecha
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .onChange(of: selectedDate) { _ in vm.loadMatches(for: selectedDate) }
                        .tint(theme.current.accent)
                        .foregroundColor(theme.isDarkTheme ? Color(white: 0.8) : Color(white: 0.2))
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
                .padding(.top, 30)
                .padding(.horizontal, 20)

                // Lista de partidos
                Group {
                    if vm.matches.isEmpty && !vm.isLoading {
                        // Vista vacía
                        VStack {
                            Spacer()
                            Image(systemName: "sportscourt")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64, height: 64)
                                .foregroundColor(theme.current.textPrimary)
                            Text("No hay partidos para esta fecha.")
                                .font(.subheadline)
                                .foregroundColor(theme.current.textPrimary)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        // Vista con partidos agrupados
                        ScrollViewReader { scrollProxy in
                            ScrollView {
                                LazyVStack(spacing: 14, pinnedViews: [.sectionHeaders]) {
                                    ForEach(vm.groupedLeagueKeys(), id: \.self) { leagueName in
                                        Section(header: leagueHeader(for: leagueName)) {
                                            ForEach(vm.groupedMatches()[leagueName] ?? []) { match in
                                                matchCard(for: match)
                                                    .padding(.horizontal)
                                                    .id(match.id)
                                            }
                                        }
                                    }
                                    Spacer(minLength: 24)
                                }
                                .padding(.top, 6)
                            }
                        }
                        .refreshable { vm.loadMatches(for: selectedDate) }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.bottom)
            .onAppear { vm.loadMatches(for: selectedDate) } // Carga inicial
            .navigationLogo()
            .background(theme.current.background.ignoresSafeArea())
        }
        .environmentObject(vm)
    }

    // MARK: - Card estilo “SofaScore” con hora arriba
    @ViewBuilder
    private func matchCard(for match: MatchItem) -> some View {
        VStack(spacing: 8) {
            // Info superior: hora y estado
            HStack {
                Text(formattedDate(match.fixture.date))
                    .font(.caption2)
                    .foregroundColor(theme.current.textSecondary)
                Spacer()
                Text(match.fixture.status.short.uppercased())
                    .font(.caption2)
                    .foregroundColor(theme.current.textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

            // Cuerpo del partido: escudo, nombre y marcador
            HStack(spacing: 12) {
                // Home
                VStack(spacing: 4) {
                    teamLogoView(team: match.teams.home)
                    teamNameView(team: match.teams.home)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .frame(minWidth: 100, maxWidth: 120)

                Spacer()

                // Marcador
                HStack(spacing: 4) {
                    Text("\(match.goals.home ?? 0)")
                        .font(.title2)
                        .bold()
                    Text("-")
                        .font(.title2)
                        .bold()
                    Text("\(match.goals.away ?? 0)")
                        .font(.title2)
                        .bold()
                }
                .foregroundColor(theme.current.textPrimary)

                Spacer()

                // Away
                VStack(spacing: 4) {
                    teamLogoView(team: match.teams.away)
                    teamNameView(team: match.teams.away)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .frame(minWidth: 100, maxWidth: 120)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .background(theme.current.card)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
    }

    // MARK: - Vista de logo del equipo
    @ViewBuilder
    private func teamLogoView(team: TeamInfo) -> some View {
        if let logo = team.logo, let url = URL(string: logo) {
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
    }

    // MARK: - Vista del nombre del equipo
    @ViewBuilder
    private func teamNameView(team: TeamInfo) -> some View {
        if let standing = vm.teamStanding(for: team.id) {
            NavigationLink(destination: TeamDetailView(team: standing).environmentObject(theme)) {
                Text(team.name)
                    .font(.subheadline)
                    .foregroundColor(theme.current.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        } else {
            Text(team.name)
                .font(.subheadline)
                .foregroundColor(theme.current.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }

    // MARK: - Formatear fecha ISO a HH:mm
    private func formattedDate(_ isoDate: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: isoDate) ?? ISO8601DateFormatter().date(from: isoDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
        return "--:--"
    }

    // MARK: - Header de cada liga
    @ViewBuilder
    private func leagueHeader(for leagueName: String) -> some View {
        HStack(spacing: 8) {
            if let first = (vm.groupedMatches()[leagueName]?.first),
               let logoStr = first.league.logo,
               let url = URL(string: logoStr) {
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

            Text(leagueName)
                .font(.headline)
                .foregroundColor(theme.current.textPrimary)
            Spacer()
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 12)
        .background(theme.current.card)
    }
}
