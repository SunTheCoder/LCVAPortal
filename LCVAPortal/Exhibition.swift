//
//  Exhibition.swift
//  LCVAPortal
//
//  Created by Sun English on 11/11/24.
//

import Foundation

struct Exhibition: Identifiable {
    let id = UUID()
    let title: String
    let artist: [String]
    let galleryName: String
    let description: String
    let reception: String
    let closing: String
    let surveyUrl: String
    let imageUrl: String
    let extraLink: String?
    let latitude: Double
    let longitude: Double
}

// Sample data
let sampleExhibitions = [
    Exhibition(title: "Bad Kitty Does Not Like Art Museums",
               artist: ["Nick Bruel"],
               galleryName: "Gallery A",
               description: "Bad Kitty Does Not Like Art Museums highlights works of art from author and illustrator Nick Bruel. For over twenty years, his stories have connected with children and adults alike. His whimsical narratives teach valuable life lessons through humor and the curious Bad Kitty. \n\nThough she wasn’t always a bad cat, she just didn’t want to eat asparagus, horseradish, spinach, or zucchini. She wanted an assortment of anchovies, hippo hamburgers, rhino ravioli, or shark sushi. She may not have been as patient as she should have been, but that’s okay. She is learning – she is just a little kitty. \n\nAnd Bad Kitty grows up, just like we do. She goes on vacation, takes a test, gets a bath, gets a phone, and even runs for president. These stories teach that when times get tough, we figure out ways to persevere and succeed, or how to handle disappointment. \n\nBad Kitty Does Not Like Art Museums is an invitation to find your own growth, revisit something you don’t like, and have some laughs. The LCVA, in conjunction with the Virginia Children’s Book Festival, asks that you don’t claw the curtains, overturn litter boxes, or ruin any rugs. \n\nThis exhibition is the eight iteration of the LCVA’s annual Arts and Letters exhibition series showcasing the best in the art of children’s literature, which is proudly presented in conjunction with the Virginia Children’s Book Festival.",
               reception: "Wednesday, October 16, 2024, 6:00 PM - 9:00 PM",
               closing: "Sunday, February 9, 2025, 5:00 PM",
               surveyUrl: "https://docs.google.com/forms/d/e/1FAIpQLScU3PsVCtCWAzyHbxIqa7yf-yK1A2OLYW0R500ZWyZbAp91CQ/viewform?usp=sf_link",
               imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/Bady-Kitty-Starry-Night-1.jpg",
               extraLink: "https://badkittycomicgame.netlify.app",
               latitude: 39.04,
               longitude: -77.03),
               
    Exhibition(title: "Letters from Farmville",
               artist: ["Debra Jean Ambush"],
               galleryName: "Gallery A",
               description: "In 1989 Dr. Debra Jean Ambush came to Farmville to help settle an estate for a recently passed family member. In her family’s farm house was a trunk.  This trunk contained receipts, papers, photographs, and personal correspondence dating back to 1872. For over 30 years these documents, which are an ancestral connection to the artist, have served as vital sources of artistic inspiration and interpretation as she seeks to understand her family’s histories, stories, and memories. Letters from Farmville: Reflections on Ancestral Arrival into Descendant Memory is a four-part exhibition that visualizes African American family history to illuminate the ways in which memory is constructed, lost, and cherished. \n\nThe Longwood Center for the Visual Arts (LCVA) welcomes the community to an opening reception on Friday, September 6 from 5:30 – 8 pm; early entry for Friends & Partners at 5 pm. The exhibition will be on view from September 6, 2024—January 21, 2025. Letters from Farmville is made possible in part through the generous sponsorship of Ilsa Loeser and Letterpress Communications.",
               reception: "Friday, September 6, 2024, 6:00 PM - 9:00 PM",
               closing: "Tuesday, January 21, 2025, 5:00 PM",
               surveyUrl: "no link",
               imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/451624173_1005858958207827_1691580555828386781_n.jpg",
               extraLink: "https://youtu.be/MKdqit-fVkY?si=j32FwPuIqSGnwMio",
               latitude: 39.04,
               longitude: -77.03),
    Exhibition(title: "Of Time, and The Town",
               artist: ["David Ellsworth"],
               galleryName: "Gallery A",
               description: "Of Time, and the Town from filmmaker David Ellsworth poetically depicts twenty years of changes and constants in the built environment of Farmville, Virginia and in the rural areas surrounding it. The film’s super-8 film images bear witness to how everyday locales provide markers of the town’s social evolution. A young couple labors to renovate an abandoned 19th century school and make it their home while the town’s previously shuttered all-Black high school finds new life as a civil rights museum documenting the 1950s student strike that helped integrate the county’s schools. Children grow as one-hundred-year-old oak trees fall. Excerpts from the town’s AM radio station provide a sonic touchstone that complements the film’s evocative sound design. \n\nThe Longwood Center for the Visual Arts (LCVA) welcomes the community to an opening reception on Friday, September 6 from 5:30 – 8 pm; early entry for Friends & Partners at 5 pm. This exhibition will be on view from September 6, 2024—January 21, 2025..",
               reception: "Friday, September 6, 2024, 6:00 PM - 9:00 PM",
               closing: "Tuesday, January 21, 2025, 5:00 PM",
               surveyUrl: "no link",
               imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/Screenshot-299.png",
               extraLink: nil,
               latitude: 39.04,
               longitude: -77.03),
]
