//
//  ProfileViewModel.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  ViewModel para manejar datos de perfil y cerrar sesión
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var userEmail: String = ""

    @Published var favoriteTeam: String = ""
    @Published var favoriteTeamLogo: String = ""

    @Published var isLoading = true
    @Published var loadError: String?

    @Published var signingOut = false
    @Published var signOutError: String?

    private let db = Firestore.firestore()

    // MARK: - Load user data
    func loadUserData() {
        isLoading = true
        loadError = nil

        guard let user = Auth.auth().currentUser else {
            self.isLoading = false
            return
        }

        self.userEmail = user.email ?? ""

        let docRef = db.collection("users").document(user.uid)
        docRef.getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let err = error {
                    self.loadError = "Error al cargar perfil: \(err.localizedDescription)"
                    self.isLoading = false
                    return
                }

                if let data = document?.data() {
                    if let nameFromDB = data["name"] as? String {
                        self.userName = nameFromDB
                    } else {
                        self.userName = "Sin nombre"
                    }

                    if let favName = data["favTeamName"] as? String {
                        self.favoriteTeam = favName
                    } else {
                        self.favoriteTeam = "Sin equipo"
                    }

                    if let favLogo = data["favTeamLogo"] as? String {
                        self.favoriteTeamLogo = favLogo
                    } else {
                        self.favoriteTeamLogo = ""
                    }
                }

                self.isLoading = false
            }
        }
    }

    // MARK: - Sign out
    func signOut() {
        signingOut = true
        signOutError = nil
        do {
            try Auth.auth().signOut()
        } catch {
            signOutError = "Error al cerrar sesión: \(error.localizedDescription)"
        }
        signingOut = false
    }
}
