import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        VStack(spacing: 16) {
            Text("Profile")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            Text("Welcome, \(authManager.user?.displayName ?? "User")")
                .foregroundColor(.white)

            Text(authManager.user?.email ?? "")
                .foregroundColor(.gray)

            Button("Log Out") {
                authManager.signOut()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.red)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.top, 20)
        }
        .padding(24)
        .background(Color.black.ignoresSafeArea())
    }
}
