import SwiftUI

// MARK: - Add/Edit Category View
enum CategoryEditMode {
    case add
    case edit(SpendingCategory)
}

struct AddEditCategoryView: View {
    @Environment(\.dismiss) private var dismiss

    let mode: CategoryEditMode
    let categoryType: CategoryType
    let onSave: (SpendingCategory) -> Void

    @State private var name: String = ""
    @State private var selectedEmoji: String = "📦"

    // Emoji keyboard
    @State private var emojiInput: String = ""
    @FocusState private var isEmojiFocused: Bool

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Emoji selector
                Button {
                    emojiInput = ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isEmojiFocused = true
                    }
                } label: {
                    Text(selectedEmoji)
                        .font(.system(size: 60))
                        .frame(width: 100, height: 100)
                        .background(Color.appSecondary)
                        .cornerRadius(24)
                }

                // Hidden TextField for Emoji Keyboard
                TextField("", text: $emojiInput)
                    .focused($isEmojiFocused)
                    .opacity(0.01)
                    .frame(width: 1, height: 1)
                    .allowsHitTesting(false)
                    .onChange(of: emojiInput) { _, newValue in
                        // Pick the last character as the icon
                        if let lastChar = newValue.last {
                            selectedEmoji = String(lastChar)
                        }
                    }

                // Name input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category name")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)

                    TextField("Enter name", text: $name)
                        .font(.title3)
                        .padding()
                        .background(Color.appBackground)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.top, 10)
            .navigationTitle(isEditing ? "Edit Category" : "New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("X") {
                        dismiss()
                    }
                    .buttonStyle(.plain)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCategory()
                    }
                    .buttonStyle(.plain)
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if case .edit(let category) = mode {
                    name = category.name
                    selectedEmoji = category.emoji
                }
            }
        }
        .presentationBackground(Color.appBackground)
    }

    private func saveCategory() {
        let category: SpendingCategory
        if case .edit(let existing) = mode {
            category = SpendingCategory(
                id: existing.id,
                name: name,
                emoji: selectedEmoji,
                isVisible: existing.isVisible,
                isDefault: false,
                order: existing.order,
                categoryType: existing.categoryType
            )
        } else {
            category = SpendingCategory(
                name: name,
                emoji: selectedEmoji,
                isVisible: true,
                isDefault: false,
                categoryType: categoryType
            )
        }

        onSave(category)
        dismiss()
    }
}
