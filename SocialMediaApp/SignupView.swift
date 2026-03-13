import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var localError: String?

    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        password.count >= 6 &&
        password == confirmPassword &&
        !authManager.isLoading
    }

    var body: some View {
        VStack {
            Spacer(minLength: 30)

            Text("Create Account")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 20)

            VStack(spacing: 12) {
                TextField("Name", text: $name)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                SecureField("Password (min 6 chars)", text: $password)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if let localError, !localError.isEmpty {
                Text(localError)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.top, 8)
            } else if let error = authManager.errorMessage, !error.isEmpty {
                Text(error)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.top, 8)
            }

            Button {
                localError = nil
                if password != confirmPassword {
                    localError = "Passwords do not match."
                    return
                }
                Task {
                    await authManager.signUp(
                        email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                        password: password,
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                }
            } label: {
                HStack {
                    if authManager.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Sign Up")
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

            Button("Back to Login") {
                dismiss()
            }
            .foregroundColor(.blue)
            .font(.subheadline.weight(.semibold))
            .padding(.top, 14)

            Spacer()
        }
        .padding(24)
        .background(Color.black.ignoresSafeArea())
    }
}
