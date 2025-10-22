//
//  SettingsView.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Configuración de la app: modo nocturno, color principal, accesos a "Acerca de" y Términos.
//  Adaptada a ThemeManager, usando SettingRow reutilizable.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    // MARK: - Entornos
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Cuerpo principal
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Modo nocturno
                    SettingRow(isOn: $theme.isDarkTheme, title: "Modo nocturno", icon: "moon.fill", hasSwitch: true)
                    Divider().background(theme.current.placeholder)

                    // Color principal (Picker)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(theme.current.accent)
                                .frame(width: 28, height: 28)
                            Text("Color principal")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(theme.current.textPrimary)
                            Spacer()
                        }
                        .padding(.top, 8)

                        Picker("Color principal", selection: $theme.primaryColor) {
                            Text("Azul").tag(ThemeManager.PrimaryColor.blue)
                            Text("Verde").tag(ThemeManager.PrimaryColor.green)
                            Text("Rojo").tag(ThemeManager.PrimaryColor.red)
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom, 10)
                    }
                    .padding(.horizontal)
                    .background(theme.current.card)
                    .cornerRadius(8)
                    Divider().background(theme.current.placeholder)
                    
                    // Acerca de la app
                    NavigationLink(destination: AboutView()) {
                        SettingRow(title: "Acerca de la app", icon: "info.circle", hasSwitch: false)
                    }
                    Divider().background(theme.current.placeholder)

                    // Términos y condiciones
                    NavigationLink(destination: TerminosView()) {
                        SettingRow(title: "Términos y condiciones", icon: "doc.text.fill", hasSwitch: false)
                    }
                }
                .background(theme.current.card)
                .cornerRadius(16)
                .padding()
                .padding(.top, 5)
            }
            .navigationBarHidden(true)
            .navigationLogo()
            .background(theme.current.background.ignoresSafeArea())
        }
    }
}

// MARK: - Fila de configuración reutilizable
struct SettingRow: View {
    @EnvironmentObject var theme: ThemeManager
    @Binding var isOn: Bool
    let title: String
    let icon: String?
    let hasSwitch: Bool

    init(isOn: Binding<Bool> = .constant(false), title: String, icon: String? = nil, hasSwitch: Bool) {
        self._isOn = isOn
        self.title = title
        self.icon = icon
        self.hasSwitch = hasSwitch
    }

    var body: some View {
        HStack {
            if let iconName = icon {
                Image(systemName: iconName)
                    .foregroundColor(theme.current.accent)
                    .frame(width: 28, height: 28)
            }

            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(theme.current.textPrimary)

            Spacer()

            if hasSwitch {
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(theme.current.textSecondary)
            }
        }
        .padding(.horizontal)
        .frame(height: 50)
        .background(theme.current.card)
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
        .environmentObject(AuthViewModel())
}
