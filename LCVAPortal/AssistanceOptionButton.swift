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
                    .foregroundColor(.white)
                Text(title)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.lcvaBlue.opacity(0.3), Color.white.opacity(0.1)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(10)
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
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaBlue.opacity(0.4)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Contact Information
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contact Information")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Name", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                            
                            TextField("Email", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        
                        // Assistance Options
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Assistance Needed")
                                .font(.headline)
                                .foregroundColor(.white)
                            
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
                                            .foregroundColor(.white)
                                        Text(option.title)
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        
                        // Visit Details
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Visit Details")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            DatePicker(
                                "Planned Visit Date",
                                selection: $date,
                                displayedComponents: [.date]
                            )
                            .colorScheme(.dark)
                            .foregroundColor(.white)
                            .accentColor(.white)
                            
                            TextField("Additional Information or Specific Needs", text: $additionalInfo, axis: .vertical)
                                .textFieldStyle(CustomTextFieldStyle())
                                .lineLimit(4)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        
                        // Submit Button
                        Button(action: {
                            // Handle submission
                            isPresented = false
                        }) {
                            Text("Submit Request")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.lcvaBlue.opacity(0.6), Color.white.opacity(0.1)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Assistance Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.lcvaBlue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct AssistanceOption: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
} 