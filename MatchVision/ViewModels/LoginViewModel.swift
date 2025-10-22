//
//  LoginViewModel.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  ViewModel para la pantalla de login.
//

import SwiftUI
import FirebaseAuth
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showPassword: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showingAlert: Bool = false

    var canLogin: Bool {
        email.contains(".") && password.count >= 6
    }

    func attemptLogin(auth: AuthViewModel, dismiss: @escaping () -> Void) {
        guard canLogin, !isLoading else { return }
        isLoading = true

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showingAlert = true
                    print("[LoginViewModel] Error al iniciar sesión:", error.localizedDescription)
                    return
                }

                guard let user = result?.user else {
                    self.errorMessage = "No se pudo obtener la información del usuario."
                    self.showingAlert = true
                    return
                }

                UserDefaults.standard.set(self.email, forKey: "userEmail")

                if let displayName = user.displayName, !displayName.isEmpty {
                    UserDefaults.standard.set(displayName, forKey: "userName")
                } else {
                    UserDefaults.standard.removeObject(forKey: "userName")
                }

                auth.isSignedIn = true
                dismiss()
            }
        }
    }
}
