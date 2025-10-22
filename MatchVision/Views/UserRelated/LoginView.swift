//
//  LoginView.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Vista para iniciar sesión en la app, adaptada a ThemeManager y AuthViewModel.
//  Incluye campos de email y contraseña, toggle de visibilidad y navegación a RegisterView.
//

import SwiftUI

struct LoginView: View {
    // MARK: - Environment
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var theme: ThemeManager
    @StateObject private var vm = LoginViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo dinámico
                Color.clear.dynamicAppBackground(animated: true)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    // MARK: Header
                    VStack(spacing: 8) {
                        Text("Inicia sesión")
                            .font(.title.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.top, 100)
                        Text("Introduce tus credenciales para acceder")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }

                    // MARK: Campos de login
                    VStack(spacing: 16) {
                        TextField("Email", text: $vm.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .padding(12)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)

                        HStack {
                            if vm.showPassword {
                                TextField("Password", text: $vm.password)
                            } else {
                                SecureField("Password", text: $vm.password)
                            }

                            Button { vm.showPassword.toggle() } label: {
                                Image(systemName: vm.showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)

                        Text(vm.canLogin ? "Listo para iniciar" : "Introduce email y contraseña.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 20)

                    // MARK: Botón de login y enlace a registro
                    VStack(spacing: 12) {
                        Button {
                            vm.attemptLogin(auth: auth) { dismiss() }
                        } label: {
                            Text("Iniciar sesión")
                        }
                        .buttonStyle(AppPrimaryButtonStyle(disabled: !vm.canLogin || vm.isLoading))
                        .disabled(!vm.canLogin || vm.isLoading)
                        .padding(.horizontal, 28)

                        HStack {
                            Text("¿No tienes cuenta?")
                                .font(.footnote)
                                .foregroundColor(.white)
                            NavigationLink(destination: RegisterView()
                                .environmentObject(auth)
                                .environmentObject(theme)
                            ) {
                                Text("Crear cuenta")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    }

                    Spacer(minLength: 16)
                }
                .padding(.horizontal, 20)
                .navigationLogo()

                // MARK: Loading overlay
                if vm.isLoading {
                    Color.black.opacity(0.25).ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
        }
    }
}
