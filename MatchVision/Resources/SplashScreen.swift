//
//  SplashView.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Vista de splash con logo y animación de desvanecido.
//

import SwiftUI

/// Splash simple con fade out y salida controlada mediante la binding `isActive`.
struct SplashView: View {
    
    // Binding externo que controla si la splash sigue activa
    @Binding var isActive: Bool
    
    // Opacidad del logo para la animación
    @State private var logoOpacity: Double = 1.0

    // MARK: - Duraciones de animación
    private enum Durations {
        static let fade: TimeInterval = 4      // Tiempo para el fade out del logo
        static let delay: TimeInterval = 3     // Retardo antes de finalizar la splash
        static let finish: TimeInterval = 0.4  // Animación final antes de cambiar `isActive`
    }

    var body: some View {
        ZStack {
            // Fondo negro ocupando toda la pantalla
            Color.black
                .ignoresSafeArea()

            // Logo centrado
            Image("ImageLogoV2")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .opacity(logoOpacity)
        }
        .onAppear { startAnimation() } // Inicia animación al aparecer
    }

    // MARK: - Animación del logo
    private func startAnimation() {
        // Desvanecer el logo gradualmente
        withAnimation(.easeInOut(duration: Durations.fade)) {
            logoOpacity = 0
        }

        // Después del delay, se desactiva la splash con animación
        DispatchQueue.main.asyncAfter(deadline: .now() + Durations.delay) {
            withAnimation(.easeOut(duration: Durations.finish)) {
                isActive = false
            }
        }
    }
}
