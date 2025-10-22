//
//  TerminosView.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Vista que muestra los términos y condiciones de uso de la aplicación.
//

import SwiftUI

struct TerminosView: View {
    @EnvironmentObject var theme: ThemeManager
    
    // MARK: - Texto de términos
    private let termsText = """
Bienvenido a MatchVision. Al usar esta aplicación, aceptas los siguientes términos y condiciones:

1. Uso de la app
• La app es solo para uso personal y no comercial.
• Está prohibida la distribución de contenido de la app sin autorización.

2. Contenido de terceros
• Los datos deportivos son proporcionados por APIs externas (API-SPORTS).
• No nos hacemos responsables de errores en los datos.

3. Privacidad
• La app no comparte información personal sin tu consentimiento.
• La información puede ser almacenada localmente o en Firebase para funcionalidades como login.

4. Responsabilidad
• No garantizamos la exactitud de predicciones, resultados o estadísticas.
• La app se ofrece “tal cual”, sin garantías de ningún tipo.

5. Modificaciones
• Nos reservamos el derecho de modificar estos términos en cualquier momento.
• Los cambios se aplican desde la fecha de publicación en la app.

Gracias por confiar en MatchVision.
"""
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Título
                Text("Términos y condiciones")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(theme.primaryColor == .red ? Color.red : theme.getAccentColor())
                
                // Separador
                Divider()
                    .background(theme.current.textSecondary)
                
                // Texto de los términos
                Text(termsText)
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
struct TerminosView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TerminosView()
                .environmentObject(ThemeManager())
        }
        .preferredColorScheme(.light)

        NavigationStack {
            TerminosView()
                .environmentObject(ThemeManager())
        }
        .preferredColorScheme(.dark)
    }
}
