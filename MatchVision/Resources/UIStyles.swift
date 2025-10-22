//
//  UIStyles.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Modificadores y estilos de UI reutilizables.
//

import SwiftUI

// MARK: - Dynamic background modifier
/// Gradiente animada de fondo para vistas
private struct DynamicAppBackgroundModifier: ViewModifier {
    var animated: Bool = true
    var colors: [Color] = [
        Color(red: 0.19, green: 0.20, blue: 0.24),
        Color(red: 0.32, green: 0.10, blue: 0.39)
    ]
    @State private var hueShift: Double = 0.0

    func body(content: Content) -> some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: colors),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .hueRotation(Angle(degrees: hueShift))
                .onAppear {
                    guard animated else { return }
                    withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                        hueShift = 360
                    }
                }

            content
        }
    }
}

public extension View {
    /// Aplica gradiente dinámica de la app
    func dynamicAppBackground(animated: Bool = true, colors: [Color]? = nil) -> some View {
        let useColors = colors ?? [
            Color(red: 0.19, green: 0.20, blue: 0.24),
            Color(red: 0.32, green: 0.10, blue: 0.39)
        ]
        return modifier(DynamicAppBackgroundModifier(animated: animated, colors: useColors))
    }
}

// MARK: - Primary button style
/// Estilo de botón principal de la app
struct AppPrimaryButtonStyle: ButtonStyle {
    var disabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(disabled ? Color.white.opacity(0.25) : Color.white)
            )
            .foregroundColor(disabled ? Color.white.opacity(0.7) : .black)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(disabled ? Color.white.opacity(0.3) : Color.white, lineWidth: 1)
            )
            .shadow(color: disabled ? .clear : Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .padding(.horizontal, 20)
    }
}
