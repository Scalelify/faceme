import SwiftUI

struct MainAppView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("SocialMediaApp")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                Text("You are logged in.")
                    .foregroundColor(.white.opacity(0.8))

                NavigationLink("Open Profile") {
                    ProfileView()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(24)
            .background(Color.black.ignoresSafeArea())
        }
    }
}
