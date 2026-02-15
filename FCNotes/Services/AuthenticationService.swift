import LocalAuthentication
import Foundation

@Observable
final class AuthenticationService {
    var isAuthenticated = false
    var isAuthenticating = false
    var authError: String?

    private let context = LAContext()

    var biometricType: LABiometryType {
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }

    var biometricIcon: String {
        switch biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "lock.fill"
        }
    }

    var biometricName: String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "Biyometrik"
        }
    }

    func authenticate() async {
        let context = LAContext()
        context.localizedCancelTitle = "İptal"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Fallback to device passcode
            await authenticateWithPasscode(context: context)
            return
        }

        await MainActor.run {
            isAuthenticating = true
            authError = nil
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "FCNotes'a erişmek için kimliğinizi doğrulayın"
            )
            await MainActor.run {
                isAuthenticated = success
                isAuthenticating = false
            }
        } catch {
            await MainActor.run {
                authError = "Kimlik doğrulama başarısız oldu"
                isAuthenticating = false
            }
        }
    }

    private func authenticateWithPasscode(context: LAContext) async {
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            await MainActor.run {
                authError = "Cihazda güvenlik ayarı bulunamadı"
                isAuthenticating = false
            }
            return
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "FCNotes'a erişmek için kimliğinizi doğrulayın"
            )
            await MainActor.run {
                isAuthenticated = success
                isAuthenticating = false
            }
        } catch {
            await MainActor.run {
                authError = "Kimlik doğrulama başarısız oldu"
                isAuthenticating = false
            }
        }
    }

    func lock() {
        isAuthenticated = false
    }
}
