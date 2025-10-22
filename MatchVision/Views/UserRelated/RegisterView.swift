//
//  RegisterView.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Vista para crear una cuenta de usuario, con validación básica y guardado en Firestore.
//  Integrada con ThemeManager.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: State de campos
    @State private var name = ""
    @State private var email = ""
    @State private var confirmEmail = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false

    @State private var errorMessage: String?
    @State private var showingAlert = false
    @State private var isLoading = false

    private var canRegister: Bool {
        !name.isEmpty && email.contains("@") && email.contains(".") &&
        email == confirmEmail && password == confirmPassword && password.count >= 6
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear.dynamicAppBackground(animated: true).ignoresSafeArea()

                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Crea tu cuenta")
                            .font(.title.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.top, 45)
                        Text("Introduce tus credenciales para empezar")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }

                    // MARK: Campos de registro
                    VStack(spacing: 16) {
                        FloatingLabelTextField(title: "Nombre", text: $name)
                        FloatingLabelTextField(title: "Email", text: $email, keyboard: .emailAddress)
                        FloatingLabelTextField(title: "Confirmar email", text: $confirmEmail, keyboard: .emailAddress)
                        PasswordField(title: "Password", text: $password, showPassword: $showPassword)
                        PasswordField(title: "Confirmar password", text: $confirmPassword, showPassword: $showPassword)
                    }
                    .padding(20)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)

                    // Botón registrar
                    Button(action: registerUser) {
                        Text("Registrarse")
                    }
                    .buttonStyle(AppPrimaryButtonStyle(disabled: !canRegister || isLoading))
                    .disabled(!canRegister || isLoading)
                    .padding(.horizontal, 28)

                    HStack {
                        Text("¿Ya tienes cuenta?")
                            .font(.footnote)
                            .foregroundColor(.white)
                        Button(action: { dismiss() }) {
                            Text("Inicia sesión")
                                .font(.footnote.weight(.semibold))
                                .foregroundColor(.white)
                        }
                    }

                    Spacer(minLength: 16)
                }
                .padding(.horizontal, 20)
                .navigationLogo()

                if isLoading {
                    Color.black.opacity(0.25).ignoresSafeArea()
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
        }
    }

    // MARK: - Función de registro
    func registerUser() {
        guard canRegister, !isLoading else { return }
        isLoading = true

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showingAlert = true
                    return
                }

                guard let user = result?.user else { return }

                let db = Firestore.firestore()
                let data: [String: Any] = [
                    "uid": user.uid,
                    "name": name,
                    "email": email,
                    "createdAt": FieldValue.serverTimestamp()
                ]

                db.collection("users").document(user.uid).setData(data) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.errorMessage = "Error guardando perfil: \(error.localizedDescription)"
                            self.showingAlert = true
                            return
                        }

                        try? Auth.auth().signOut()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Componentes auxiliares
private struct FloatingLabelTextField: View {
    let title: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.secondary)
            TextField(title, text: $text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .padding(12)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
        }
    }
}

private struct PasswordField: View {
    let title: String
    @Binding var text: String
    @Binding var showPassword: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.secondary)
            HStack {
                if showPassword {
                    TextField(title, text: $text)
                } else {
                    SecureField(title, text: $text)
                }
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
}
