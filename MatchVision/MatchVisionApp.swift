//
//  MatchVisionApp.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Punto de entrada de la app. Inicializa Firebase, gestiona SplashScreen, TabView o WelcomeView según el estado de sesión.
//  Configura apariencia global de TabBar y NavigationBar, e inyecta ThemeManager y AuthViewModel.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import UIKit

// MARK: - AppDelegate para inicializar Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// MARK: - App Principal
@main
struct MatchVisionApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var auth = AuthViewModel()
    @StateObject private var theme = ThemeManager()
    @State private var showSplash = true

    init() {
        let tabColor = UIColor.systemGreen
        let bgColor = UIColor.systemBackground

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = bgColor
        tabAppearance.stackedLayoutAppearance.selected.iconColor = tabColor
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: tabColor]
        tabAppearance.stackedLayoutAppearance.normal.iconColor = tabColor.withAlphaComponent(0.7)
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: tabColor.withAlphaComponent(0.7)]

        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
        UITabBar.appearance().tintColor = tabColor
        UITabBar.appearance().barTintColor = bgColor
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView(isActive: $showSplash)
                        .transition(.opacity)
                        .zIndex(1)
                } else {
                    // Inyectamos theme y auth en el NavigationStack (ancestro común)
                    NavigationStack {
                        if auth.isSignedIn {
                            TabViewLauncher()
                        } else {
                            WelcomeView()
                        }
                    }
                    .environmentObject(auth)
                    .environmentObject(theme)
                    .tint(theme.current.accent) // Accent dinámico para tus vistas
                    .background(theme.current.background.ignoresSafeArea()) // Fondo dinámico de tus vistas
                    .transition(.opacity)
                }
            }
            .onAppear {
                applySystemAccent(color: theme.current.accent, background: theme.current.background)
            }
            .onChange(of: theme.isDarkTheme) { _ in
                applySystemAccent(color: theme.current.accent, background: theme.current.background)
            }
        }
    }

    // MARK: - Actualizar UIAppearance para NavigationBar (TabBar ya fijado en init)
    private func applySystemAccent(color: Color, background: Color) {
        let uiColor = UIColor(color)
        let bgColor = UIColor(background)

        // Fondo global de la ventana
        UIWindow.appearance().backgroundColor = bgColor
        
        // NavigationBar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        navAppearance.backgroundColor = bgColor
        navAppearance.titleTextAttributes = [.foregroundColor: uiColor]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: uiColor]

        UINavigationBar.appearance().standardAppearance = navAppearance
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        }
        UINavigationBar.appearance().tintColor = uiColor
    }
}
