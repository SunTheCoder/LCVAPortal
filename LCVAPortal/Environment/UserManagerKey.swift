import SwiftUI

private struct UserManagerKey: EnvironmentKey {
    static let defaultValue: UserManager? = nil
}

extension EnvironmentValues {
    var userManager: UserManager? {
        get { self[UserManagerKey.self] }
        set { self[UserManagerKey.self] = newValue }
    }
} 