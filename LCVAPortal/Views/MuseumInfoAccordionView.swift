import SwiftUI

struct MuseumInfoAccordionView: View {
    @State private var expandedSection: String?
    @State private var expandedSubSection: String?
    
    let sections = [
        AccordionSection(
            title: "About LCVA",
            subsections: [
                SubSection(
                    title: "Mission",
                    content: "To enrich lives by sharing transformative experiences in the visual arts with our community."
                ),
                SubSection(
                    title: "Contact",
                    content: "",  // Empty string for content
                    isContactForm: true
                ),
                SubSection(
                    title: "Values",
                    content: """
                    **The Centrality of Art to Individual and Community Life**
                    • Works of art are essential records of human history and can influence and enrich every aspect of living. Art can inspire people to lead more hopeful, creative, and participatory lives for the greater good of their communities. With these convictions in mind, the LCVA treats all visitors in a welcoming and inclusive manner while fostering an aesthetic appreciation of diverse experiences, forms, media, and content. The LCVA encourages participation in the creative process regardless of age, training, or ability. The LCVA designs exhibitions, educational and volunteer programs, and internships to spark community interaction and development.

                    **Artistic Integrity**
                    • The LCVA serves as an advocate for artists by insisting on fair, respectful, and professional treatment of artists within our institution as well as in the community at large. The LCVA fully accepts the role of steward for art in its possession and commits itself to preserving the original intent of the artist. The LCVA dedicates itself to presenting compelling examples of exemplary artistic vision and craftsmanship.

                    **Professionalism**
                    • In the conduct of its business and in the exhibition, collection, preservation, and maintenance of works of art, the LCVA adheres to the highest professional standards and ethical considerations as outlined by the American Association of Museums, the Commonwealth of Virginia, and Longwood University.
                    """
                )
            ]
        ),
        AccordionSection(
            title: "Visit Us",
            subsections: [
                SubSection(
                    title: "Location",
                    content: """
                    129 North Main Street
                    Farmville, VA 23901
                    
                    Located in historic downtown Farmville, the LCVA is a short walk from Longwood University's campus.
                    """
                ),
                SubSection(
                    title: "Parking",
                    content: "Free parking is available on Main Street and in the municipal lot behind the building."
                ),
                SubSection(
                    title: "Accessibility",
                    content: "The LCVA is fully accessible to all visitors. Wheelchair access is available at our Main Street entrance."
                )
            ]
        ),
        AccordionSection(
            title: "Get Involved",
            subsections: [
                SubSection(
                    title: "Membership",
                    content: "Join our community of art lovers and supporters. Members receive special benefits and invitations to exclusive events."
                ),
                SubSection(
                    title: "Volunteer",
                    content: "We welcome volunteers who want to contribute their time and talents to support our mission."
                ),
                SubSection(
                    title: "Donate",
                    content: "Your support helps us continue to provide free admission and educational programs to our community."
                )
            ]
        )
    ]
    
    var body: some View {
        VStack(spacing: 1) {
            ForEach(sections, id: \.title) { section in
                VStack(spacing: 0) {
                    // Main section button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            expandedSection = expandedSection == section.title ? nil : section.title
                            expandedSubSection = nil // Reset subsection when main section changes
                        }
                    }) {
                        HStack {
                            Text(section.title)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: expandedSection == section.title ? "chevron.up" : "chevron.down")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.1))
                    }
                    
                    // Subsections
                    if expandedSection == section.title {
                        VStack(spacing: 1) {
                            ForEach(section.subsections, id: \.title) { subsection in
                                VStack(spacing: 0) {
                                    // Subsection button
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            expandedSubSection = expandedSubSection == subsection.title ? nil : subsection.title
                                        }
                                    }) {
                                        HStack {
                                            Text(subsection.title)
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(.white.opacity(0.9))
                                            Spacer()
                                            Image(systemName: expandedSubSection == subsection.title ? "chevron.up" : "chevron.down")
                                                .foregroundColor(.white.opacity(0.9))
                                                .font(.system(size: 12))
                                        }
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 10)
                                        .background(Color.white.opacity(0.05))
                                    }
                                    
                                    // Subsection content
                                    if expandedSubSection == subsection.title {
                                        if subsection.isContactForm {
                                            ContactFormView()
                                                .padding(.horizontal, 32)
                                                .padding(.vertical, 12)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color.white.opacity(0.03))
                                                .transition(.opacity.combined(with: .move(edge: .top)))
                                        } else {
                                            VStack(alignment: .leading, spacing: 8) {
                                                if subsection.title == "Values" {
                                                    Group {
                                                        Text("The Centrality of Art to Individual and Community Life")
                                                            .bold()
                                                        Text("• Works of art are essential records of human history and can influence and enrich every aspect of living. Art can inspire people to lead more hopeful, creative, and participatory lives for the greater good of their communities. With these convictions in mind, the LCVA treats all visitors in a welcoming and inclusive manner while fostering an aesthetic appreciation of diverse experiences, forms, media, and content. The LCVA encourages participation in the creative process regardless of age, training, or ability. The LCVA designs exhibitions, educational and volunteer programs, and internships to spark community interaction and development.")
                                                        
                                                        Text("Artistic Integrity")
                                                            .bold()
                                                            .padding(.top, 8)
                                                        Text("• The LCVA serves as an advocate for artists by insisting on fair, respectful, and professional treatment of artists within our institution as well as in the community at large. The LCVA fully accepts the role of steward for art in its possession and commits itself to preserving the original intent of the artist. The LCVA dedicates itself to presenting compelling examples of exemplary artistic vision and craftsmanship.")
                                                        
                                                        Text("Professionalism")
                                                            .bold()
                                                            .padding(.top, 8)
                                                        Text("• In the conduct of its business and in the exhibition, collection, preservation, and maintenance of works of art, the LCVA adheres to the highest professional standards and ethical considerations as outlined by the American Association of Museums, the Commonwealth of Virginia, and Longwood University.")
                                                    }
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white.opacity(0.8))
                                                } else {
                                                    Text(subsection.content)
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.white.opacity(0.8))
                                                }
                                            }
                                            .padding(.horizontal, 32)
                                            .padding(.vertical, 12)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.white.opacity(0.03))
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                        }
                                    }
                                }
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
        .background(Color.black.opacity(0.2))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct AccordionSection {
    let title: String
    let subsections: [SubSection]
}

struct SubSection {
    let title: String
    let content: String
    var isContactForm: Bool = false
    
    init(title: String, content: String = "", isContactForm: Bool = false) {
        self.title = title
        self.content = content
        self.isContactForm = isContactForm
    }
}

// Add this struct for the contact form
struct ContactFormView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var showingAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.black)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.black)
                .keyboardType(.emailAddress)
            
            TextEditor(text: $message)
                .frame(height: 100)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .foregroundColor(.black)
            
            Button(action: {
                // Here you would implement sending the message
                showingAlert = true
                // Reset form
                name = ""
                email = ""
                message = ""
            }) {
                Text("Send Message")
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.lcvaBlue)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 8)
        .alert("Message Sent", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Thank you for your message. We'll get back to you soon!")
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.9).edgesIgnoringSafeArea(.all)
        MuseumInfoAccordionView()
    }
} 
