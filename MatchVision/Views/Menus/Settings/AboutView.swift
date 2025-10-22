//
//  AboutView.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Vista que muestra información sobre la app, desarrollador y contacto.
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject var theme: ThemeManager
    
    // MARK: - Texto de información
    private let aboutText = """
MatchVision es tu app de estadísticas y seguimiento de fútbol en tiempo real. Con ella puedes:

• Ver ligas y tablas de clasificación.
• Revisar plantillas y estadísticas de equipos.
• Consultar resultados y próximos partidos.

Esta app está diseñada para ofrecer una experiencia moderna, rápida y minimalista, con información precisa de las principales ligas del mundo.

Desarrollador: Alejandro Olivares Escapa
Contacto: soporte@matchvision.com
Versión: 1.0.0
"""
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Título
                Text("Sobre MatchVision")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(theme.current.accent)
                
                // Separador
                Divider()
                    .background(theme.current.textSecondary)
                
                // Texto descriptivo
                Text(aboutText)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(theme.current.textPrimary)
                    .lineSpacing(8)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.current.card)
                    .shadow(color: theme.current.shadow, radius: 8, x: 0, y: 4)
            )
            .padding()
        }
        .background(theme.current.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AboutView()
                .environmentObject(ThemeManager())
        }
        .preferredColorScheme(.light)

        NavigationStack {
            AboutView()
                .environmentObject(ThemeManager())
        }
        .preferredColorScheme(.dark)
    }
}
