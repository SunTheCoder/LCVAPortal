//
//  ExhibitionDetailModalView.swift
//  LCVAPortal
//
//  Created by Sun English on 11/15/24.
//

import SwiftUI
import MapKit


struct ExhibitionDetailModalView: View {
    let exhibition: Exhibition
   
    @Binding var isPresented: Bool // Binding to control modal visibility
    
    var body: some View {
        NavigationView {
            ZStack {
                // Add background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.lcvaBlue, Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Display exhibition image
                        AsyncImage(url: URL(string: exhibition.imageUrl)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                                .shadow(radius: 3)
                                .accessibilityLabel(Text("Image of \(exhibition.title)"))
                        } placeholder: {
                            ProgressView()
                                .accessibilityHidden(true) // Hide loading indicator from VoiceOver
                        }
                        .frame(maxHeight: 300)
                        
                        // Display title
                        Text(exhibition.title)
                            .font(.system(size: 25))
                            .bold()
                            .padding(.vertical)
                            .accessibilityAddTraits(.isHeader)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Reception, Closing, Description, and Links
                        Text("Reception:")
                            .font(.body)
                            
                            .bold()
                            .accessibilityLabel(Text("Reception: \(exhibition.reception)"))
                        Text(exhibition.reception)
                            .font(.body)
                            
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityLabel(Text("Reception: \(exhibition.reception)"))

                        Text("Closing:")
                            .font(.body)
                            
                            .bold()
                            .accessibilityLabel(Text("Reception: \(exhibition.closing)"))
                        Text(exhibition.closing)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityLabel(Text("Closing: \(exhibition.closing)"))

                        
                        
                        Text("About:")
                            .font(.body)
                            
                            .bold()
                            .accessibilityLabel(Text("About"))
                        
                        Text(exhibition.description)
                            .font(.body)
                            
                            .accessibilityLabel(Text("Description: \(exhibition.description)"))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Link("Survey Link", destination: URL(string: exhibition.surveyUrl)!)
                            .font(.subheadline)
                            .padding(2)
                            .padding(.horizontal, 2)
                            .background(Color.primary.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(3)
                            .shadow(radius: 2)
                            .accessibilityLabel("Open Survey Link")
                            .frame(maxWidth: .infinity, alignment: .center)

                        
                        // Extra Content Section
                        Text("Extra Content:")
                            .font(.headline)
                            
                            .frame(maxWidth: .infinity, alignment: .center)

                        
                        if let extraLink = exhibition.extraLink, !extraLink.isEmpty, let url = URL(string: extraLink) {
                            Link(extraLink, destination: url)
                                .font(.subheadline)
                                .padding(2)
                                .padding(.horizontal, 2)
                                .background(Color.primary.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(3)
                                .shadow(radius: 2)
                                .accessibilityLabel(Text("Visit \(extraLink)"))
                                .frame(maxWidth: .infinity, alignment: .center)

                        } else {
                            Text("No additional link available")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                        }
                    }
                    .padding()
                    .onAppear {
                                        print("Exhibition Details: \(exhibition)")
                                    }
                }
            }
            .navigationTitle("Exhibition Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                                print("Exhibition Details: \(exhibition)")
                            }
        }
    }
}
