//
//  WelcomeView.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Vista de bienvenida de la app, con animación del logo y navegación al login.
//  Totalmente adaptada a ThemeManager y AuthViewModel.
//

import SwiftUI

struct WelcomeView: View {
    // MARK: - Environment
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var theme: ThemeManager
    
    // MARK: - State
    @State private var showContent = false
    @State private var logoScale: CGFloat = 0.8
    @State private var navigateToLogin = false

    var body: some View {
        ZStack {
            // Fondo dinámico
            VStack {
                // Logo con animación
                Image("ImageLogoV2")
                    .resizable()
                    .padding(.top, 10)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .shadow(color: .black.opacity(0.3), radius: 20)
                    .scaleEffect(logoScale)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                            logoScale = 2.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeIn(duration: 1)) {
                                showContent = true
                            }
                        }
                    }

                // Contenido que aparece después de la animación
                if showContent {
                    VStack(spacing: 10) {
                        Text("Bienvenido a MATCHVISION")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                            .padding(.horizontal, 30)

                        Text("Conecta y entérate de todo el fútbol.")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)

                        // Botón principal para navegar a LoginView
                        Button(action: {
                            navigateToLogin = true
                        }) {
                            Text("Comenzar")
                                .font(.headline)
                        }
                        .buttonStyle(AppPrimaryButtonStyle(disabled: false))
                        .padding(.horizontal, 50)
                        .padding(.top, 5)

                        // NavigationLink oculto con environmentObjects
                        NavigationLink(
                            destination: LoginView()
                                .environmentObject(auth)
                                .environmentObject(theme),
                            isActive: $navigateToLogin
                        ) {
                            EmptyView()
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
        .dynamicAppBackground(animated: true)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        WelcomeView()
            .environmentObject(AuthViewModel())
            .environmentObject(ThemeManager())
    }
}
