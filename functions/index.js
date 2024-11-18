const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
require("dotenv").config();

admin.initializeApp();

const getAiRecommendations = async (mood) => {
  try {
    const ACCESS_TOKEN = process.env.ACCESS_TOKEN;
    console.log("Loaded Access Token:", process.env.ACCESS_TOKEN);

    // Define the payload
    const payload =
        {
          contents: [
            {
              role: "user",
              parts: [{text: mood}],
            },
          ],
        };


    // Log the payload for debugging
    console.log("Payload sent to AI model:", JSON.stringify(payload, null, 2));

    // Send the request to the AI endpoint
    const aiResponse = await axios.post(
        "https://us-central1-aiplatform.googleapis.com/v1/projects/lcvaportal/locations/us-central1/endpoints/2393505971784646656:predict",
        payload,
        {
          headers: {
            "Authorization": `Bearer ${ACCESS_TOKEN}`,
            "Content-Type": "application/json", // Ensure content type is JSON
          },
        },
    );

    // Log the full AI response for debugging
    console.log("AI response:", JSON.stringify(aiResponse.data, null, 2));

    // Validate response structure
    if (!aiResponse.data.predictions ||
        aiResponse.data.predictions.length === 0) {
      throw new Error("No predictions returned from AI model");
    }

    // Extract recommendations from the AI response
    const recommendations = aiResponse.data.predictions.map((prediction) => {
      const modelOutput = prediction.contents.find(
          (content) => content.role === "model",
      );
      if (!modelOutput) {
        throw new Error("Model output not found in AI response");
      }
      return modelOutput.parts[0].text;
    });

    console.log("Recommendations extracted:", recommendations);
    return recommendations;
  } catch (error) {
    console.error("Error fetching AI recommendations:", error.message);
    throw new Error("Failed to fetch recommendations from AI model");
  }
};

const fetchArtData = async () => {
  try {
    const artPiecesSnapshot = await admin.firestore()
        .collection("artworks").get();
    const artPieces = artPiecesSnapshot.docs.map((doc) => doc.data());
    console.log("Art pieces fetched:", artPieces);
    return artPieces;
  } catch (error) {
    console.error("Error fetching art data:", error);
    throw new Error("Failed to fetch art data from Firestore");
  }
};

const filterArt = async (artPieces, recommendations) => {
  try {
    const filteredArt = artPieces.filter((art) =>
      recommendations.includes(art.title));
    console.log("Filtered art pieces:", filteredArt);
    return filteredArt;
  } catch (error) {
    console.error("Error filtering art:", error);
    throw new Error("Failed to filter art based on recommendations");
  }
};

exports.getArtRecommendations = functions.https.onRequest(async (req, res) => {
  try {
    let mood;
    if (

      req.body &&
  req.body.contents &&
  req.body.contents[0] &&
  req.body.contents[0].parts &&
  req.body.contents[0].parts[0] &&
  req.body.contents[0].parts[0].text
    ) {
      mood = req.body.contents[0].parts[0].text;
    }


    if (!mood) {
      return res.status(400).json({error: "Mood is required"});
    }

    const recommendations = await getAiRecommendations(mood);
    const artPieces = await fetchArtData();
    const filteredArt = await filterArt(artPieces, recommendations);

    res.status(200).json({art: filteredArt});
  } catch (error) {
    console.error("Error in getArtRecommendations:", error);
    res.status(500).json({error: error.message});
  }
});
