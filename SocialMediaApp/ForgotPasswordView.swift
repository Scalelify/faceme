import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var successMessage: String?

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !authManager.isLoading
    }

    var body: some View {
        VStack {
            Spacer(minLength: 40)

            Text("Reset Password")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 20)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            if let error = authManager.errorMessage, !error.isEmpty {
                Text(error)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.top, 8)
            }

            if let successMessage, !successMessage.isEmpty {
                Text(successMessage)
                    .foregroundColor(.green)
                    .font(.subheadline)
                    .padding(.top, 8)
            }

            Button {
                successMessage = nil
                Task {
                    await authManager.resetPassword(email: email.trimmingCharacters(in: .whitespacesAndNewlines))
                    if authManager.errorMessage == nil || authManager.errorMessage?.isEmpty == true {
                        successMessage = "Password reset email sent."
                    }
                }
            } label: {
                HStack {
                    if authManager.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Send Reset Email")
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
