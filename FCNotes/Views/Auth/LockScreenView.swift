import SwiftUI

struct LockScreenView: View {
    let authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            // Background gradient
            FCGradient.main
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // App icon area
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 120, height: 120)

                        Circle()
                            .fill(.white.opacity(0.3))
                            .frame(width: 90, height: 90)

                        Image(systemName: "note.text")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(.white)
                    }

                    Text("FCNotes")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Notlarınız güvende")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                // Auth button
                VStack(spacing: 16) {
                    if let error = authViewModel.authError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(.white.opacity(0.2))
                            .clipShape(Capsule())
                    }

                    Button {
                        Task {
                            await authViewModel.authenticate()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: authViewModel.biometricIcon)
                                .font(.title2)

                            Text("\(authViewModel.biometricName) ile Aç")
                                .font(.headline)
                        }
                        .foregroundStyle(.fcSeaGreen)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    }
                    .disabled(authViewModel.isAuthenticating)
                    .opacity(authViewModel.isAuthenticating ? 0.6 : 1)
                }

                Spacer()
                    .frame(height: 60)
            }
        }
        .task {
            await authViewModel.authenticate()
        }
    }
}
