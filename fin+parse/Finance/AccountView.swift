// AccountView.swift — Profile & Settings Sheet

import SwiftUI

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Account Sheet (root)
// ─────────────────────────────────────────────────────────────────────────────
struct AccountView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dataManager: SharedDataManager
    @Environment(\.dismiss) private var dismiss

    // Edit-profile
    @State private var editingName  = false
    @State private var draftName    = ""

    // Settings toggles
    @State private var notificationsOn  = true
    @State private var budgetAlertsOn   = true
    @State private var weeklyReportOn   = false

    // Danger zone
    @State private var showLogoutAlert  = false
    @State private var showDeleteAlert  = false

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        profileHeader
                        statsRow.padding(.horizontal, 20).padding(.top, 24)
                        settingsSections
                        dangerZone
                        Spacer().frame(height: 60)
                    }
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.textMuted)
                            .padding(8)
                            .background(AppTheme.surface2)
                            .clipShape(Circle())
                    }
                }
            }
            // Edit name alert
            .alert("Edit Name", isPresented: $editingName) {
                TextField("Full name", text: $draftName)
                    .textInputAutocapitalization(.words)
                Button("Save") { saveName() }
                Button("Cancel", role: .cancel) { }
            } message: { Text("Enter your new display name.") }
            // Logout confirm
            .alert("Sign Out?", isPresented: $showLogoutAlert) {
                Button("Sign Out", role: .destructive) { authManager.logout() }
                Button("Cancel", role: .cancel) { }
            } message: { Text("You'll need to sign in again to access your data.") }
            // Delete confirm
            .alert("Delete Account?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) { authManager.logout() }
                Button("Cancel", role: .cancel) { }
            } message: { Text("This will permanently delete your account and all data. This cannot be undone.") }
        }
    }

    // ─────────────────────────────────────────────
    // MARK: Profile header
    // ─────────────────────────────────────────────
    private var profileHeader: some View {
        VStack(spacing: 0) {
            // Hero gradient strip
            ZStack(alignment: .bottom) {
                AppTheme.accentGradient
                    .frame(height: 120)
                    .ignoresSafeArea(edges: .top)

                // Decorative orbs
                Circle().fill(.white.opacity(0.06)).frame(width: 160, height: 160).offset(x: 100, y: -30)
                Circle().fill(.white.opacity(0.04)).frame(width: 100, height: 100).offset(x: -80, y: 20)

                // Avatar circle — sits at the bottom edge
                ZStack {
                    Circle()
                        .fill(AppTheme.accentGradient)
                        .frame(width: 80, height: 80)
                        .overlay(Circle().stroke(.white, lineWidth: 4))
                        .shadow(color: AppTheme.accent.opacity(0.4), radius: 12, y: 6)
                    Text(authManager.currentUser?.initials ?? "?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(y: 40)
            }

            // Name + email — below the avatar
            VStack(spacing: 6) {
                Spacer().frame(height: 48) // space for avatar overhang

                HStack(spacing: 8) {
                    Text(authManager.currentUser?.fullName ?? "User")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Button {
                        draftName = authManager.currentUser?.fullName ?? ""
                        editingName = true
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppTheme.accent.opacity(0.7))
                    }
                    .buttonStyle(PressEffect())
                }

                Text(authManager.currentUser?.email ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textMuted)

                // Member since badge
                if let user = authManager.currentUser {
                    HStack(spacing: 5) {
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.system(size: 11))
                        Text("Member since \(memberSince(user.createdAt))")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(AppTheme.accent)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(AppTheme.accentSoft)
                    .clipShape(Capsule())
                    .padding(.top, 2)
                }
            }
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity)
            .background(AppTheme.surface)
        }
        .shadow(color: AppTheme.shadowSM, radius: 6, y: 3)
    }

    // ─────────────────────────────────────────────
    // MARK: Quick stats row
    // ─────────────────────────────────────────────
    private var statsRow: some View {
        HStack(spacing: 12) {
            AccountStatCard(
                value: "₸\(abbreviate(dataManager.balance))",
                label: "Balance",
                color: AppTheme.accent,
                icon: "dollarsign.circle.fill"
            )
            AccountStatCard(
                value: "\(dataManager.transactions.count)",
                label: "Transactions",
                color: AppTheme.green,
                icon: "arrow.up.arrow.down"
            )
            AccountStatCard(
                value: "\(dataManager.goals.count)",
                label: "Goals",
                color: AppTheme.yellow,
                icon: "target"
            )
        }
    }

    // ─────────────────────────────────────────────
    // MARK: Settings sections
    // ─────────────────────────────────────────────
    private var settingsSections: some View {
        VStack(spacing: 22) {
            // ── Preferences ──────────────────────
            SettingsSection(title: "Preferences", icon: "slider.horizontal.3") {
                SettingsToggleRow(
                    icon: "bell.fill", iconColor: AppTheme.accent,
                    label: "Push Notifications",
                    value: $notificationsOn
                )
                SettingsDivider()
                SettingsToggleRow(
                    icon: "chart.bar.fill", iconColor: AppTheme.red,
                    label: "Budget Alerts",
                    value: $budgetAlertsOn
                )
                SettingsDivider()
                SettingsToggleRow(
                    icon: "envelope.fill", iconColor: AppTheme.green,
                    label: "Weekly Summary Email",
                    value: $weeklyReportOn
                )
            }

            // ── App ──────────────────────────────
            SettingsSection(title: "App", icon: "gearshape.fill") {
                NavigationLink {
                    CurrencySettingsView()
                        .environmentObject(dataManager)
                } label: {
                    SettingsNavRow(icon: "turkishlirasign.circle.fill", iconColor: AppTheme.teal, label: "Currency", value: "KZT ₸")
                }
                SettingsDivider()
                NavigationLink {
                    AppearanceSettingsView()
                } label: {
                    SettingsNavRow(icon: "paintbrush.fill", iconColor: AppTheme.purple, label: "Appearance", value: "Light")
                }
                SettingsDivider()
                NavigationLink {
                    DataExportView()
                        .environmentObject(dataManager)
                } label: {
                    SettingsNavRow(icon: "square.and.arrow.up.fill", iconColor: AppTheme.orange, label: "Export Data", value: "")
                }
            }

            // ── Security ─────────────────────────
            SettingsSection(title: "Security", icon: "lock.shield.fill") {
                SettingsActionRow(icon: "lock.rotation", iconColor: AppTheme.yellow, label: "Change Password") {
                    // In a real app: present change-password sheet
                }
                SettingsDivider()
                SettingsActionRow(icon: "faceid", iconColor: AppTheme.green, label: "Face ID / Touch ID") {
                    // In a real app: toggle biometrics
                }
            }

            // ── About ─────────────────────────────
            SettingsSection(title: "About", icon: "info.circle.fill") {
                SettingsInfoRow(icon: "app.badge.fill",     iconColor: AppTheme.accent,  label: "Version",       value: "1.0.0")
                SettingsDivider()
                SettingsInfoRow(icon: "doc.text.fill",      iconColor: AppTheme.textMuted, label: "Terms of Service", value: "")
                SettingsDivider()
                SettingsInfoRow(icon: "hand.raised.fill",   iconColor: AppTheme.textMuted, label: "Privacy Policy",   value: "")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }

    // ─────────────────────────────────────────────
    // MARK: Danger zone
    // ─────────────────────────────────────────────
    private var dangerZone: some View {
        VStack(spacing: 12) {
            // Sign out
            Button { showLogoutAlert = true } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(AppTheme.accentSoft)
                            .frame(width: 34, height: 34)
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.accent)
                    }
                    Text("Sign Out")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.accent)
                    Spacer()
                }
                .padding(16)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusLG, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusLG).stroke(AppTheme.border))
            }
            .buttonStyle(PressEffect())

            // Delete account
            Button { showDeleteAlert = true } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(AppTheme.redSoft)
                            .frame(width: 34, height: 34)
                        Image(systemName: "trash.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.red)
                    }
                    Text("Delete Account")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.red)
                    Spacer()
                }
                .padding(16)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusLG, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusLG).stroke(AppTheme.red.opacity(0.2)))
            }
            .buttonStyle(PressEffect())
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }

    // ─────────────────────────────────────────────
    // MARK: Helpers
    // ─────────────────────────────────────────────
    private func saveName() {
        guard !draftName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        // Persist updated name — update UserDefaults directly via AuthManager
        guard var user = authManager.currentUser else { return }
        user.fullName = draftName.trimmingCharacters(in: .whitespaces)
        authManager.currentUser = user
        // Persist the updated user
        let key = "fincora_session"
        if let d = try? JSONEncoder().encode(user) { UserDefaults.standard.set(d, forKey: key) }
    }

    private func memberSince(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "MMM yyyy"; return f.string(from: date)
    }

    private func abbreviate(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        
        let absValue = Foundation.abs(Int32(value))
        
        if absValue >= 1_000_000 {
            return "\(formatter.string(from: NSNumber(value: value / 1_000_000)) ?? "")M"
        } else if absValue >= 1_000 {
            return "\(formatter.string(from: NSNumber(value: value / 1_000)) ?? "")K"
        } else {
            return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Reusable Setting Row components
// ─────────────────────────────────────────────────────────────────────────────

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppTheme.textMuted)
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.textMuted)
                    .tracking(0.5)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 8)

            // Rows container
            VStack(spacing: 0) {
                content()
            }
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusLG, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusLG).stroke(AppTheme.border))
        }
    }
}

struct SettingsDivider: View {
    var body: some View {
        Divider()
            .background(AppTheme.border)
            .padding(.leading, 56)
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    @Binding var value: Bool

    var body: some View {
        HStack(spacing: 14) {
            SettingsIcon(name: icon, color: iconColor)
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
            Toggle("", isOn: $value)
                .labelsHidden()
                .tint(AppTheme.accent)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }
}

struct SettingsNavRow: View {
    let icon: String; let iconColor: Color
    let label: String; let value: String

    var body: some View {
        HStack(spacing: 14) {
            SettingsIcon(name: icon, color: iconColor)
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
            if !value.isEmpty {
                Text(value)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textMuted)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.textMuted)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }
}

struct SettingsActionRow: View {
    let icon: String; let iconColor: Color; let label: String; let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                SettingsIcon(name: icon, color: iconColor)
                Text(label)
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        }
        .buttonStyle(PressEffect())
    }
}

struct SettingsInfoRow: View {
    let icon: String; let iconColor: Color; let label: String; let value: String

    var body: some View {
        HStack(spacing: 14) {
            SettingsIcon(name: icon, color: iconColor)
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textMuted)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }
}

struct SettingsIcon: View {
    let name: String; let color: Color
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color.opacity(0.12))
                .frame(width: 32, height: 32)
            Image(systemName: name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
        }
    }
}

struct AccountStatCard: View {
    let value: String; let label: String; let color: Color; let icon: String

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 38, height: 38)
                Image(systemName: icon).font(.system(size: 15)).foregroundColor(color)
            }
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1).minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppTheme.textMuted)
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusMD).stroke(AppTheme.border))
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Sub-screens (NavigationLink destinations)
// ─────────────────────────────────────────────────────────────────────────────

struct CurrencySettingsView: View {
    @EnvironmentObject var dataManager: SharedDataManager
    let currencies = ["KZT ₸", "USD $", "EUR €", "RUB ₽", "CNY ¥"]
    @State private var selected = "KZT ₸"

    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                ForEach(currencies, id: \.self) { c in
                    Button { selected = c } label: {
                        HStack {
                            Text(c).font(.system(size: 16)).foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            if selected == c {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppTheme.accent)
                            }
                        }
                        .padding(16)
                    }
                    .buttonStyle(PressEffect())
                    if c != currencies.last { Divider().padding(.leading, 16) }
                }
            }
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusLG))
            .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusLG).stroke(AppTheme.border))
            .padding(20)
            Spacer()
        }
        .navigationTitle("Currency")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AppearanceSettingsView: View {
    @State private var selected = "Light"
    let options = [("Light", "sun.max.fill"), ("Dark", "moon.fill"), ("System", "circle.lefthalf.filled")]

    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                ForEach(options, id: \.0) { name, icon in
                    Button { selected = name } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle().fill(AppTheme.accentSoft).frame(width: 34, height: 34)
                                Image(systemName: icon).font(.system(size: 14)).foregroundColor(AppTheme.accent)
                            }
                            Text(name).font(.system(size: 16)).foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            if selected == name {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(AppTheme.accent)
                            }
                        }
                        .padding(16)
                    }
                    .buttonStyle(PressEffect())
                    if name != options.last?.0 { Divider().padding(.leading, 64) }
                }
            }
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusLG))
            .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusLG).stroke(AppTheme.border))
            .padding(20)
            Spacer()
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DataExportView: View {
    @EnvironmentObject var dataManager: SharedDataManager
    @State private var exported = false

    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()
            VStack(spacing: 24) {
                ZStack {
                    Circle().fill(AppTheme.accentSoft).frame(width: 80, height: 80)
                    Image(systemName: "square.and.arrow.up.fill")
                        .font(.system(size: 32)).foregroundStyle(AppTheme.accentGradient)
                }
                .padding(.top, 40)

                VStack(spacing: 8) {
                    Text("Export Your Data")
                        .font(.system(size: 20, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                    Text("Download all your transactions, budgets, and goals as a CSV file.")
                        .font(.system(size: 14)).foregroundColor(AppTheme.textMuted)
                        .multilineTextAlignment(.center).padding(.horizontal, 20)
                }

                // Stats preview
                VStack(spacing: 0) {
                    ExportInfoRow(label: "Transactions", value: "\(dataManager.transactions.count)")
                    Divider().padding(.leading, 16)
                    ExportInfoRow(label: "Budgets",      value: "\(dataManager.budgets.count)")
                    Divider().padding(.leading, 16)
                    ExportInfoRow(label: "Goals",        value: "\(dataManager.goals.count)")
                }
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusLG))
                .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusLG).stroke(AppTheme.border))
                .padding(.horizontal, 20)

                if exported {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(AppTheme.green)
                        Text("Export ready! Check your Files app.")
                            .font(.system(size: 14, weight: .medium)).foregroundColor(AppTheme.green)
                    }
                    .padding(12)
                    .background(AppTheme.greenSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .transition(.scale.combined(with: .opacity))
                }

                Button {
                    withAnimation { exported = true }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "doc.badge.arrow.up.fill")
                        Text("Export CSV").fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(AppTheme.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD))
                    .shadow(color: AppTheme.accent.opacity(0.3), radius: 10, y: 5)
                }
                .buttonStyle(PressEffect())
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExportInfoRow: View {
    let label: String; let value: String
    var body: some View {
        HStack {
            Text(label).font(.system(size: 15)).foregroundColor(AppTheme.textPrimary)
            Spacer()
            Text(value).font(.system(size: 15, weight: .semibold)).foregroundColor(AppTheme.textMuted)
        }.padding(16)
    }
}
