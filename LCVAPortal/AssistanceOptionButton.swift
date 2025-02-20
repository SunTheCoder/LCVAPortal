import SwiftUI

struct AssistanceOptionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    @State private var isShowingForm = false
    
    var body: some View {
        Button(action: { isShowingForm = true }) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 16))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.primary.opacity(0.1))
            .cornerRadius(8)
        }
        .foregroundColor(.primary)
        .sheet(isPresented: $isShowingForm) {
            AssistanceRequestForm(isPresented: $isShowingForm)
        }
    }
}

struct AssistanceRequestForm: View {
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var email = ""
    @State private var date = Date()
    @State private var additionalInfo = ""
    @State private var selectedAssistance: Set<String> = []
    
    let assistanceOptions = [
        AssistanceOption(title: "Wheelchair Access", icon: "figure.roll"),
        AssistanceOption(title: "Audio Description", icon: "ear"),
        AssistanceOption(title: "Sign Language Interpreter", icon: "hands.sparkles"),
        AssistanceOption(title: "Large Print Materials", icon: "textformat.size"),
        AssistanceOption(title: "Sensory Support", icon: "brain.head.profile"),
        AssistanceOption(title: "Other Assistance", icon: "person.fill.questionmark")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Information")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Assistance Needed")) {
                    ForEach(assistanceOptions) { option in
                        Toggle(isOn: Binding(
                            get: { selectedAssistance.contains(option.title) },
                            set: { isSelected in
                                if isSelected {
                                    selectedAssistance.insert(option.title)
                                } else {
                                    selectedAssistance.remove(option.title)
                                }
                            }
                        )) {
                            HStack {
                                Image(systemName: option.icon)
                                    .foregroundColor(.secondary)
                                Text(option.title)
                            }
                        }
                    }
                }
                
                Section(header: Text("Visit Details")) {
                    DatePicker("Planned Visit Date", selection: $date, displayedComponents: [.date])
                    
                    TextField("Additional Information or Specific Needs", text: $additionalInfo, axis: .vertical)
                        .lineLimit(4)
                }
                
                Section {
                    Button("Submit Request") {
                        // Handle submission
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Assistance Request")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
}

struct AssistanceOption: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
} 