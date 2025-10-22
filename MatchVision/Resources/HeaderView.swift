//
//  HeaderView.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Header fijo con logo y botón de notificaciones sobre el contenido.
//

import SwiftUI

/// Modificador que dibuja un header fijo con logo y botones encima del contenido.
/// Uso: `.modifier(NavigationLogoModifier())` o mediante el atajo `.navigationLogo()`.
struct NavigationLogoModifier: ViewModifier {

    // MARK: - Strings sensibles
    private struct Strings {
        static let appTitle = "MATCHVISION"  // Título de la app
        static let bellActionLog = "Pulsar"  // Acción de debug del botón de notificaciones
    }

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            
            // Desplaza el contenido principal para que no se solape con el header
            content
                .padding(.top, 50)

            // Header fijo en la parte superior
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    
                    // Logo de la aplicación
                    Image("ImageLogoV2")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(height: 56)

                    // Nombre de la app
                    Text(Strings.appTitle)
                        .font(.title3)
                        .fontWeight(.bold)

                    Spacer()

                    // Botón de notificaciones
                    Button(action: { print(Strings.bellActionLog) }) {
                        Image(systemName: "bell.fill")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                    .padding(.trailing, 8)
                }
                .padding(.horizontal)
                .frame(height: 60)
                .background(.ultraThinMaterial) // Fondo translúcido
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2) // Sombra suave

                Spacer()
            }
        }
        .navigationBarHidden(true) // Oculta el navigation bar para no duplicar header
    }
}

// MARK: - Extensión para aplicar el header fácilmente
public extension View {
    /// Atajo para aplicar `NavigationLogoModifier` a cualquier vista.
    func navigationLogo() -> some View {
        self.modifier(NavigationLogoModifier())
    }
}
