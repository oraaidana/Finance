// GoalsView.swift

import SwiftUI
import Charts

struct GoalsView: View {
    @EnvironmentObject var dataManager: SharedDataManager
    @State private var showAdd = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Goals").font(.system(size: 26, weight: .black, design: .rounded)).foregroundColor(AppTheme.textPrimary)
                        Text("Dream big, save smart").font(.system(size: 12)).foregroundColor(AppTheme.textMuted)
                    }
                    Spacer()
                    Button(action: { showAdd = true }) {
                        Image(systemName: "plus").font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.accent).padding(10).background(AppTheme.accentSoft).clipShape(Circle())
                    }.buttonStyle(PressEffect())
                }
                .padding(.horizontal, 20).padding(.top, 16)

                // Progress Overview Chart
                if !dataManager.goals.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Progress Overview").font(.system(size: 17, weight: .bold)).foregroundColor(AppTheme.textPrimary)

                        Chart(dataManager.goals) { goal in
                            BarMark(x: .value("Goal", goal.name),
                                    yStart: .value("Start", 0),
                                    yEnd: .value("Target", goal.targetAmount))
                                .foregroundStyle(goal.color.opacity(0.2))
                                .cornerRadius(8)
                            BarMark(x: .value("Goal", goal.name),
                                    yStart: .value("Start", 0),
                                    yEnd: .value("Saved", goal.savedAmount))
                                .foregroundStyle(goal.color)
                                .cornerRadius(8)
                        }
                        .chartXAxis {
                            AxisMarks { AxisValueLabel().foregroundStyle(AppTheme.textMuted).font(.system(size: 9)) }
                        }
                        .chartYAxis {
                            AxisMarks { AxisValueLabel().foregroundStyle(AppTheme.textMuted).font(.system(size: 9)) }
                        }
                        .frame(height: 150)
                    }
                    .glassCard()
                    .padding(.horizontal, 20)
                }

                // Goal Cards
                VStack(spacing: 14) {
                    ForEach(dataManager.goals) { goal in
                        GoalCard(goal: goal)
                    }
                }
                .padding(.horizontal, 20)

                if dataManager.goals.isEmpty {
                    VStack(spacing: 16) {
                        Text("🎯").font(.system(size: 50))
                        Text("No goals yet").font(.system(size: 18, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                        Text("Set your first savings goal and start working towards your dreams!")
                            .font(.system(size: 14)).foregroundColor(AppTheme.textMuted).multilineTextAlignment(.center)
                        Button(action: { showAdd = true }) {
                            Text("Create a Goal")
                                .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                                .padding(.horizontal, 24).padding(.vertical, 12)
                                .background(AppTheme.accentGradient)
                                .clipShape(Capsule())
                        }.buttonStyle(PressEffect())
                    }
                    .padding(40)
                }

                Spacer().frame(height: 100)
            }
        }
        .background(AppTheme.bg)
        .sheet(isPresented: $showAdd) { AddGoalSheet() }
    }
}

// MARK: - Goal Card
struct GoalCard: View {
    let goal: SavingsGoal

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        Text(goal.emoji).font(.system(size: 28))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(goal.name).font(.system(size: 17, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                            Text("By \(goal.formattedDeadline)").font(.system(size: 12)).foregroundColor(AppTheme.textMuted)
                        }
                    }
                }
                Spacer()
                // Progress Ring
                ZStack {
                    Circle().stroke(goal.color.opacity(0.2), lineWidth: 5).frame(width: 52, height: 52)
                    Circle().trim(from: 0, to: CGFloat(goal.progress))
                        .stroke(goal.color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 52, height: 52)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1, dampingFraction: 0.7), value: goal.progress)
                    Text("\(goal.progressPercent)%")
                        .font(.system(size: 10, weight: .bold)).foregroundColor(goal.color)
                }
            }

            // Progress Bar
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4).fill(goal.color.opacity(0.15)).frame(height: 8)
                        RoundedRectangle(cornerRadius: 4).fill(goal.color)
                            .frame(width: geo.size.width * CGFloat(goal.progress), height: 8)
                            .animation(.spring(response: 1, dampingFraction: 0.7), value: goal.progress)
                    }
                }.frame(height: 8)

                HStack {
                    Text("$\(String(format: "%.0f", goal.savedAmount)) saved")
                        .font(.system(size: 12, weight: .semibold)).foregroundColor(goal.color)
                    Spacer()
                    Text("$\(String(format: "%.0f", goal.targetAmount)) target")
                        .font(.system(size: 12)).foregroundColor(AppTheme.textMuted)
                }
            }

            // Remaining
            let remaining = goal.targetAmount - goal.savedAmount
            if remaining > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.circle.fill").font(.system(size: 12)).foregroundColor(AppTheme.accent)
                    Text("$\(String(format: "%.0f", remaining)) more to reach your goal")
                        .font(.system(size: 12)).foregroundColor(AppTheme.textMuted)
                }
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 12)).foregroundColor(AppTheme.green)
                    Text("Goal achieved! 🎉").font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.green)
                }
            }
        }
        .padding(20)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusLG, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusLG).stroke(goal.color.opacity(0.2)))
    }
}

// MARK: - Add Goal Sheet
struct AddGoalSheet: View {
    @EnvironmentObject var dataManager: SharedDataManager
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var emoji = "🎯"
    @State private var targetStr = ""
    @State private var savedStr = ""
    @State private var deadline = Calendar.current.date(byAdding: .month, value: 6, to: Date())!
    @State private var colorHex = "#7C6FCD"

    let emojis = ["🎯","✈️","🏠","💻","🚗","📈","🛡️","💍","🎓","🏋️","🎮","🌴"]
    let colors = ["#7C6FCD","#34C97B","#FFB730","#FF6B9D","#26D0CE","#FD7A4A"]

    var isValid: Bool { !name.isEmpty && Double(targetStr) != nil }

    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    RoundedRectangle(cornerRadius: 3).fill(AppTheme.surface2).frame(width: 36, height: 4).padding(.top, 12)
                    HStack {
                        Text("New Goal").font(.system(size: 20, weight: .black, design: .rounded)).foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark").font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textMuted).padding(8).background(AppTheme.surface2).clipShape(Circle())
                        }
                    }

                    // Emoji picker
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Pick an Emoji", systemImage: "face.smiling").font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.textMuted)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                            ForEach(emojis, id: \.self) { e in
                                Button(action: { emoji = e }) {
                                    Text(e).font(.system(size: 24))
                                        .frame(width: 44, height: 44)
                                        .background(emoji == e ? AppTheme.accentSoft : AppTheme.surface2)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(emoji == e ? AppTheme.accent : Color.clear))
                                }.buttonStyle(PressEffect())
                            }
                        }
                    }

                    // Color picker
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Color", systemImage: "paintpalette.fill").font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.textMuted)
                        HStack(spacing: 10) {
                            ForEach(colors, id: \.self) { c in
                                Button(action: { colorHex = c }) {
                                    Circle().fill(Color(hex: c)).frame(width: 32, height: 32)
                                        .overlay(Circle().stroke(.white, lineWidth: colorHex == c ? 3 : 0))
                                        .shadow(color: colorHex == c ? Color(hex: c).opacity(0.5) : .clear, radius: 6)
                                }.buttonStyle(PressEffect())
                            }
                        }
                    }

                    AuthField(icon: "text.cursor", placeholder: "Goal name (e.g. Emergency Fund)", text: $name, isSecure: false)

                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Target ($)", systemImage: "flag.fill").font(.system(size: 11, weight: .semibold)).foregroundColor(AppTheme.textMuted)
                            AuthField(icon: "dollarsign", placeholder: "5000", text: $targetStr, isSecure: false).keyboardType(.decimalPad)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Saved ($)", systemImage: "checkmark").font(.system(size: 11, weight: .semibold)).foregroundColor(AppTheme.textMuted)
                            AuthField(icon: "dollarsign", placeholder: "0", text: $savedStr, isSecure: false).keyboardType(.decimalPad)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Deadline", systemImage: "calendar").font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.textMuted)
                        DatePicker("", selection: $deadline, in: Date()..., displayedComponents: .date)
                            .datePickerStyle(.compact).labelsHidden().tint(AppTheme.accent)
                            .padding(14).background(AppTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD))
                            .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusMD).stroke(AppTheme.border))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button(action: {
                        guard let target = Double(targetStr) else { return }
                        let saved = Double(savedStr) ?? 0
                        let goal = SavingsGoal(name: name, emoji: emoji, targetAmount: target, savedAmount: saved, deadline: deadline, colorHex: colorHex)
                        dataManager.addGoal(goal)
                        dismiss()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: AppTheme.radiusMD).fill(isValid ? AppTheme.accentGradient : LinearGradient(colors: [AppTheme.surface2], startPoint: .leading, endPoint: .trailing))
                            Text("Create Goal").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        }.frame(height: 54)
                    }
                    .buttonStyle(PressEffect()).disabled(!isValid).opacity(isValid ? 1 : 0.5)
                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}
