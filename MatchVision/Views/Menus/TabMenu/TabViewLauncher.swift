//
//  ContentView.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Vista principal con TabView: Inicio, Partidos, Perfil, Ajustes.
//  Navegación interna con NavigationStack y adaptación a ThemeManager.
//
import SwiftUI

struct TabViewLauncher: View {
    // MARK: - Entornos y estados
    @EnvironmentObject var theme: ThemeManager
    @StateObject private var matchsVM = MatchsViewModel()
    @State private var selection: Int = 0

    // MARK: - Cuerpo principal
    var body: some View {
        TabView(selection: $selection) {

            // Pestaña Inicio
            NavigationStack {
                HomeView()
                    .environmentObject(theme)
            }
            .tabItem { Label("Inicio", systemImage: "house.fill") }
            .tag(0)

            // Pestaña Partidos
            NavigationStack {
                MatchsView()
                    .environmentObject(matchsVM)
                    .environmentObject(theme)
            }
            .tabItem { Label("Partidos", systemImage: "sportscourt.fill") }
            .tag(1)

            // Pestaña Perfil
            NavigationStack {
                ProfileView()
                    .environmentObject(theme)
            }
            .tabItem { Label("Perfil", systemImage: "person.crop.circle.fill") }
            .tag(2)

            // Pestaña Ajustes
            NavigationStack {
                SettingsView()
                    .environmentObject(theme)
            }
            .tabItem { Label("Ajustes", systemImage: "gearshape.fill") }
            .tag(3)
        }
        .tint(theme.current.accent)
        .onAppear {
            // Configuración de la apariencia de la TabBar según el tema actual
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(theme.current.background)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Preview
#Preview {
    TabViewLauncher()
        .environmentObject(ThemeManager())
}
