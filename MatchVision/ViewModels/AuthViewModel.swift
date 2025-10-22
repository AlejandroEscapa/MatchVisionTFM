//
//  AuthViewModel.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Gestión de autenticación con Firebase.
//

import Foundation
import FirebaseAuth
import Combine

final class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = Auth.auth().currentUser != nil

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        // Listener que actualiza el estado global cuando Firebase cambia el usuario actual
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                let signed = (user != nil)
                self?.isSignedIn = signed
                print("[AuthViewModel] addStateDidChangeListener -> isSignedIn:", signed, "currentUser:", user?.uid ?? "nil")
            }
        }
        print("[AuthViewModel] init - initial isSignedIn:", isSignedIn)
    }

    deinit {
        if let h = handle { Auth.auth().removeStateDidChangeListener(h) }
    }

    // Cerrar sesión
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isSignedIn = false // redundante pero asegura el cambio
            }
            print("[AuthViewModel] signOut ok")
        } catch {
            print("[AuthViewModel] signOut error:", error.localizedDescription)
        }
    }
}
