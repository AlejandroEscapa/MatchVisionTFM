//
//  ProfileView.swift
//  MatchVision
//
//  Creado por Alejandro Olivares Escapa
//  Vista de perfil de usuario, mostrando avatar, nombre, email, equipo favorito y acciones.
//  Integrada con ThemeManager y ProfileViewModel.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    // MARK: - Environment & State
    @EnvironmentObject var theme: ThemeManager
    @StateObject private var vm = ProfileViewModel()
    @State private var showEdit = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: Header gradient + avatar
                ZStack(alignment: .bottom) {
                    LinearGradient(
                        colors: [
                            theme.current.accent.opacity(0.15),
                            theme.current.accent.opacity(0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 160)
                    .cornerRadius(16)
                    .shadow(color: theme.current.textPrimary.opacity(0.06), radius: 6, x: 0, y: 4)
                    
                    VStack(spacing: 6) {
                        avatar
                    }
                    .offset(y: 36)
                }
                .padding(.horizontal)
                .padding(.bottom, 36)
                
                // MARK: Nombre y correo
                VStack(spacing: 6) {
                    if vm.isLoading {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(theme.current.placeholder)
                            .frame(width: 120, height: 20)
                            .redacted(reason: .placeholder)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(theme.current.placeholder.opacity(0.7))
                            .frame(width: 180, height: 16)
                            .redacted(reason: .placeholder)
                    } else {
                        Text(vm.userName.isEmpty ? "Sin nombre" : vm.userName)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(theme.current.textPrimary)
                        
                        Text(vm.userEmail.isEmpty ? "Sin correo" : vm.userEmail)
                            .font(.subheadline)
                            .foregroundColor(theme.current.textSecondary)
                    }
                    
                    if let err = vm.loadError {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal)
                
                // MARK: Equipo favorito
                favoriteTeamCard(
                    teamName: vm.favoriteTeam.isEmpty ? "Sin equipo" : vm.favoriteTeam,
                    teamLogo: vm.favoriteTeamLogo
                )
                
                // MARK: Acciones
                VStack(spacing: 12) {
                    Button(role: .destructive) {
                        vm.signOut()
                    } label: {
                        HStack {
                            Image(systemName: "arrowshape.turn.up.left")
                                .foregroundColor(.red)
                            Text(vm.signingOut ? "Cerrando sesión..." : "Cerrar sesión")
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding()
                        .background(theme.current.card)
                        .cornerRadius(12)
                    }
                    .disabled(vm.signingOut)
                }
                .padding(.horizontal)
                
                if let soErr = vm.signOutError {
                    Text(soErr)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top, 8)
        }
        .onAppear { vm.loadUserData() }
        .navigationLogo()
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
        .background(theme.current.background.ignoresSafeArea())
    }
    
    // MARK: Avatar
    private var avatar: some View {
        ZStack {
            Circle()
                .fill(theme.current.card)
                .frame(width: 110, height: 110)
                .shadow(color: theme.current.textPrimary.opacity(0.06), radius: 6, x: 0, y: 4)
            
            Image(systemName: "sportscourt")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(theme.current.accent)
        }
    }
    
    // MARK: Equipo favorito card
    private func favoriteTeamCard(teamName: String, teamLogo: String) -> some View {
        HStack(spacing: 12) {
            if let url = URL(string: teamLogo), !teamLogo.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 50, height: 50)
                            .background(theme.current.placeholder)
                            .clipShape(Circle())
                    case .success(let image):
                        ZStack {
                            Circle()
                                .fill(theme.current.placeholder.opacity(0.2))
                                .frame(width: 50, height: 50)
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        }
                        .frame(width: 50, height: 50)
                        .shadow(color: theme.current.textPrimary.opacity(0.1), radius: 4, x: 0, y: 2)
                    case .failure:
                        placeholderLogoCircle
                    @unknown default:
                        placeholderLogoCircle
                    }
                }
            } else {
                placeholderLogoCircle
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Equipo favorito")
                    .font(.subheadline)
                    .foregroundColor(theme.current.textSecondary)
                Text(teamName.isEmpty ? "Sin equipo" : teamName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.current.textPrimary)
            }
            Spacer()
        }
        .padding()
        .background(theme.current.card)
        .cornerRadius(12)
        .shadow(color: theme.current.textPrimary.opacity(0.02), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private var placeholderLogoCircle: some View {
        ZStack {
            Circle()
                .fill(theme.current.placeholder.opacity(0.2))
                .frame(width: 50, height: 50)
            Image(systemName: "sportscourt")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(theme.current.textSecondary.opacity(0.8))
        }
    }
}
