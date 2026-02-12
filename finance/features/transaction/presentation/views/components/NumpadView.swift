//
//  NumpadView.swift
//  finance
//
//  Created on 01/28/26.
//

import SwiftUI

struct NumpadView: View {
    let onDigit: (String) -> Void
    let onDecimal: () -> Void
    let onDelete: () -> Void
    var onImport: (() -> Void)? = nil
    let onSave: () -> Void
    let canSave: Bool
    var showImport: Bool = true

    private let spacing: CGFloat = 8
    private let columns = 4

    private var buttonWidth: CGFloat {
        let totalSpacing = spacing * CGFloat(columns - 1)
        let availableWidth = UIScreen.main.bounds.width - 32
        return (availableWidth - totalSpacing) / CGFloat(columns)
    }

    private let buttonHeight: CGFloat = 52

    var body: some View {
        VStack(spacing: spacing) {
            // Row 1: 1, 2, 3, IMPORT or delete
            HStack(spacing: spacing) {
                NumpadKey(label: "1", width: buttonWidth, height: buttonHeight) { onDigit("1") }
                NumpadKey(label: "2", width: buttonWidth, height: buttonHeight) { onDigit("2") }
                NumpadKey(label: "3", width: buttonWidth, height: buttonHeight) { onDigit("3") }
                if showImport {
                    NumpadKey(
                        label: "IMPORT",
                        width: buttonWidth,
                        height: buttonHeight,
                        backgroundColor: Color.appPrimary,
                        foregroundColor: .white
                    ) { onImport?() }
                } else {
                    NumpadKey(
                        icon: "delete.left",
                        width: buttonWidth,
                        height: buttonHeight
                    ) { onDelete() }
                }
            }

            // Row 2: 4, 5, 6, delete or decimal
            HStack(spacing: spacing) {
                NumpadKey(label: "4", width: buttonWidth, height: buttonHeight) { onDigit("4") }
                NumpadKey(label: "5", width: buttonWidth, height: buttonHeight) { onDigit("5") }
                NumpadKey(label: "6", width: buttonWidth, height: buttonHeight) { onDigit("6") }
                if showImport {
                    NumpadKey(
                        icon: "delete.left",
                        width: buttonWidth,
                        height: buttonHeight
                    ) { onDelete() }
                } else {
                    NumpadKey(label: ".", width: buttonWidth, height: buttonHeight) { onDecimal() }
                }
            }

            // Row 3: 7, 8, 9, decimal or 00
            HStack(spacing: spacing) {
                NumpadKey(label: "7", width: buttonWidth, height: buttonHeight) { onDigit("7") }
                NumpadKey(label: "8", width: buttonWidth, height: buttonHeight) { onDigit("8") }
                NumpadKey(label: "9", width: buttonWidth, height: buttonHeight) { onDigit("9") }
                if showImport {
                    NumpadKey(label: ".", width: buttonWidth, height: buttonHeight) { onDecimal() }
                } else {
                    NumpadKey(label: "00", width: buttonWidth, height: buttonHeight) { onDigit("00") }
                }
            }

            // Row 4: 00/0, 0, SAVE (wide)
            HStack(spacing: spacing) {
                if showImport {
                    NumpadKey(label: "00", width: buttonWidth, height: buttonHeight) { onDigit("00") }
                }
                NumpadKey(label: "0", width: buttonWidth, height: buttonHeight) { onDigit("0") }
                NumpadKey(
                    label: "SAVE",
                    width: showImport ? buttonWidth * 2 + spacing : buttonWidth * 3 + spacing * 2,
                    height: buttonHeight,
                    backgroundColor: canSave ? Color.appIncome : Color.appCardBackground,
                    foregroundColor: canSave ? .white : .appTextSecondary
                ) { onSave() }
            }
        }
    }
}

// MARK: - Numpad Key
struct NumpadKey: View {
    var label: String? = nil
    var icon: String? = nil
    let width: CGFloat
    let height: CGFloat
    var backgroundColor: Color = Color.appCardBackground
    var foregroundColor: Color = .appTextPrimary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                        .fontWeight(.medium)
                } else if let label = label {
                    Text(label)
                        .font(label.count > 2 ? .subheadline.weight(.semibold) : .title2.weight(.medium))
                }
            }
            .foregroundColor(foregroundColor)
            .frame(width: width, height: height)
            .background(backgroundColor)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
