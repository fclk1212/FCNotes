import SwiftUI

@Observable
final class AuthViewModel {
    let authService = AuthenticationService()

    var isAuthenticated: Bool {
        authService.isAuthenticated
    }

    var isAuthenticating: Bool {
        authService.isAuthenticating
    }

    var authError: String? {
        authService.authError
    }

    var biometricIcon: String {
        authService.biometricIcon
    }

    var biometricName: String {
        authService.biometricName
    }

    func authenticate() async {
        await authService.authenticate()
    }

    func lock() {
        authService.lock()
    }
}
