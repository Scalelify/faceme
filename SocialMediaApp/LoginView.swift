import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        !authManager.isLoading
    }

    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 40)

                Text("Welcome Back")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 28)

                VStack(spacing: 14) {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                if let error = authManager.errorMessage, !error.isEmpty {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.top, 8)
                }

                Button {
                    Task {
                        await authManager.signIn(
                            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                            password: password
                        )
                    }
                } label: {
                    HStack {
                        if authManager.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Log In")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(canSubmit ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!canSubmit)
                .padding(.top, 10)

                HStack {
                    NavigationLink("Forgot Password?") {
                        ForgotPasswordView()
                    }
                    .foregroundColor(.blue)
                    .font(.subheadline.weight(.semibold))

                    Spacer()

                    NavigationLink("Sign Up") {
                        SignupView()
                    }
                    .foregroundColor(.blue)
                    .font(.subheadline.weight(.semibold))
                }
                .padding(.top, 14)

                Spacer()
            }
            .padding(24)
            .background(Color.black.ignoresSafeArea())
        }
    }
}
