//
//  ActivityView.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Componente compartido para mostrar el ActivityViewController de iOS
//  Usado en PlayerDetailView y TeamDetailView para compartir información.
//

import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    /// Elementos a compartir (texto, imágenes, URLs, etc.)
    let activityItems: [Any]

    // MARK: - Crear el controlador de actividad
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        // Configuración para iPad: popover en el centro de la pantalla
        if let popover = controller.popoverPresentationController {
            popover.sourceView = UIApplication.shared.windows.first?.rootViewController?.view
            popover.sourceRect = CGRect(
                x: UIScreen.main.bounds.midX,
                y: UIScreen.main.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        return controller
    }

    // MARK: - Actualizar el controlador (no necesario aquí)
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(activityItems: ["Compartiendo texto de prueba"])
            .previewLayout(.sizeThatFits)
    }
}
