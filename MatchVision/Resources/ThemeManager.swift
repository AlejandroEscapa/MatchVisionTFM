//
//  ThemeManager.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Gestión de temas (claro/oscuro) y colores primarios.
//

import SwiftUI
import Combine

/// Manager central de tema y paleta de colores
final class ThemeManager: ObservableObject {

    // MARK: - Modos de tema
    enum Mode {
        case light
        case dark
    }

    // MARK: - Colores primarios seleccionables
    enum PrimaryColor: String, CaseIterable {
        case blue, green, red
    }

    /// Paleta de colores para UI
    struct Palette {
        let background: Color       // Fondo principal
        let card: Color             // Fondo de cards / contenedores
        let textPrimary: Color      // Texto principal
        let textSecondary: Color    // Texto secundario
        let accent: Color           // Color principal/acento
        let placeholder: Color      // Placeholder de inputs
        let shadow: Color           // Sombra general
    }

    // MARK: - Propiedades publicas
    @Published var isDarkTheme: Bool {
        didSet {
            mode = isDarkTheme ? .dark : .light
            updatePalette()
            UserDefaults.standard.set(isDarkTheme, forKey: Self.userDefaultsKey)
        }
    }

    @Published private(set) var current: Palette

    @Published var primaryColor: PrimaryColor {
        didSet {
            updatePalette()
            UserDefaults.standard.set(primaryColor.rawValue, forKey: Self.colorKey)
        }
    }

    private(set) var mode: Mode

    // MARK: - UserDefaults keys
    private static let userDefaultsKey = "isDarkTheme"
    private static let colorKey = "primaryColor"

    // MARK: - Colores base
    private let lightBaseBlue = Color(.systemBlue)
    private let lightBaseGreen = Color(.systemGreen)
    private let lightBaseRed = Color.red
    private let darkBaseBlue = Color(red: 0.0, green: 122/255, blue: 1.0)
    private let darkBaseGreen = Color.green
    private let darkBaseRed = Color.red

    // MARK: - Init
    init() {
        // Cargamos valores guardados o valores por defecto
        let savedTheme = UserDefaults.standard.bool(forKey: Self.userDefaultsKey)
        let savedColorRaw = UserDefaults.standard.string(forKey: Self.colorKey)
        let savedColor = PrimaryColor(rawValue: savedColorRaw ?? "blue") ?? .blue

        self.isDarkTheme = savedTheme
        self.primaryColor = savedColor
        self.mode = savedTheme ? .dark : .light

        // Definición del color de acento
        let accentColor: Color
        switch savedColor {
        case .blue: accentColor = savedTheme ? darkBaseBlue : lightBaseBlue
        case .green: accentColor = savedTheme ? darkBaseGreen : lightBaseGreen
        case .red: accentColor = savedTheme ? darkBaseRed : lightBaseRed
        }

        // Colores de fondo, cards, texto, placeholder y sombra
        let background = savedTheme ? Color(red: 18/255, green: 18/255, blue: 18/255) : Color(.systemGray6)
        let card = savedTheme ? Color(red: 38/255, green: 38/255, blue: 42/255) : Color(.systemGray5)
        let textPrimary = savedTheme ? Color.white : Color(UIColor.label)
        let textSecondary = savedTheme ? Color.gray.opacity(0.8) : Color(UIColor.secondaryLabel)
        let placeholder = savedTheme ? Color.gray.opacity(0.3) : Color(.systemGray4)
        let shadow = savedTheme ? Color.black.opacity(0.6) : Color.black.opacity(0.05)

        self.current = Palette(
            background: background,
            card: card,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accent: accentColor,
            placeholder: placeholder,
            shadow: shadow
        )
    }

    // MARK: - Métodos públicos

    /// Retorna el color de acento actual según tema y color primario
    func getAccentColor() -> Color {
        switch primaryColor {
        case .blue: return isDarkTheme ? darkBaseBlue : lightBaseBlue
        case .green: return isDarkTheme ? darkBaseGreen : lightBaseGreen
        case .red: return isDarkTheme ? darkBaseRed : lightBaseRed
        }
    }

    // MARK: - Actualización interna de la paleta
    private func updatePalette() {
        withAnimation(.easeInOut) {
            current = Palette(
                background: isDarkTheme ? Color(red: 18/255, green: 18/255, blue: 18/255) : Color(.systemGray6),
                card: isDarkTheme ? Color(red: 38/255, green: 38/255, blue: 42/255) : Color(.systemGray5),
                textPrimary: isDarkTheme ? Color.white : Color(UIColor.label),
                textSecondary: isDarkTheme ? Color.gray.opacity(0.8) : Color(UIColor.secondaryLabel),
                accent: getAccentColor(),
                placeholder: isDarkTheme ? Color.gray.opacity(0.3) : Color(.systemGray4),
                shadow: isDarkTheme ? Color.black.opacity(0.6) : Color.black.opacity(0.05)
            )
        }
    }
}
