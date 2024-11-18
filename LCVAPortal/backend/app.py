<<<<<<< HEAD
#from flask import Flask, request, jsonify
#from dotenv import load_dotenv
#import os
#import vertexai
#from vertexai.generative_models import GenerativeModel
#
## Load environment variables from .env
#load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '..', '.env'))
#
#app = Flask(__name__)
#
## Initialize Vertex AI
#PROJECT_ID = os.getenv("PROJECT_ID")  # Get project ID from .env
#vertexai.init(project=PROJECT_ID, location="us-central1")
#model = GenerativeModel("gemini-1.5-flash-002")
#
#@app.route('/get-recommendations', methods=['POST'])
#def get_recommendations():
#    try:
#        user_input = request.json.get("text", "")
#        if not user_input:
#            return jsonify({"error": "Input text is required"}), 400
#
#        # AI model logic here
#        response_text = model.generate_content(user_input).text
#
#        # Example static data for testing (replace with actual data logic)
#        art_pieces = [
#            {
#                "id": 1,
#                "title": response_text,  # Using AI response as the title
#                "description": "Generated art recommendation",
#                "imageUrl": "https://example.com/image.jpg",
#                "latitude": 48.858844,
#                "longitude": 2.294351,
#                "material": "Canvas",
#                "era": "Modern",
#                "origin": "Unknown",
#                "lore": "This is a generated piece of art based on your mood."
#            }
#        ]
#
#        return jsonify(art_pieces), 200
#
#    except Exception as e:
#        return jsonify({"error": str(e)}), 500
#
#
#if __name__ == '__main__':
#    app.run(debug=True)


=======
>>>>>>> c814233 (ai recommendations working. need training)
from flask import Flask, request, jsonify
from dotenv import load_dotenv
import os
import vertexai
from vertexai.generative_models import GenerativeModel

# Load environment variables from .env
<<<<<<< HEAD
load_dotenv()
=======
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '..', '.env'))
>>>>>>> c814233 (ai recommendations working. need training)

app = Flask(__name__)

# Initialize Vertex AI
PROJECT_ID = os.getenv("PROJECT_ID")  # Get project ID from .env
<<<<<<< HEAD

# Check if GOOGLE_APPLICATION_CREDENTIALS_JSON exists in environment variables
GOOGLE_APPLICATION_CREDENTIALS_JSON = os.getenv("GOOGLE_APPLICATION_CREDENTIALS_JSON")
if GOOGLE_APPLICATION_CREDENTIALS_JSON:
    # Write the credentials to a temporary file
    credentials_path = "/tmp/service-account-key.json"
    with open(credentials_path, "w") as f:
        f.write(GOOGLE_APPLICATION_CREDENTIALS_JSON)
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = credentials_path

# Initialize Vertex AI with the provided project and location
=======
>>>>>>> c814233 (ai recommendations working. need training)
vertexai.init(project=PROJECT_ID, location="us-central1")
model = GenerativeModel("gemini-1.5-flash-002")

@app.route('/get-recommendations', methods=['POST'])
def get_recommendations():
    try:
<<<<<<< HEAD
        # Extract user input from the request
=======
>>>>>>> c814233 (ai recommendations working. need training)
        user_input = request.json.get("text", "")
        if not user_input:
            return jsonify({"error": "Input text is required"}), 400

<<<<<<< HEAD
        # Generate a response using Vertex AI model
        response_text = model.generate_content(user_input).text

        # Create a dummy art piece response based on the AI output
        art_pieces = [
            {
                "id": 1,
                "title": response_text,  # Use AI response as the title
                "description": "Generated art recommendation based on your mood",
=======
        # AI model logic here
        response_text = model.generate_content(user_input).text

        # Example static data for testing (replace with actual data logic)
        art_pieces = [
            {
                "id": 1,
                "title": response_text,  # Using AI response as the title
                "description": "Generated art recommendation",
>>>>>>> c814233 (ai recommendations working. need training)
                "imageUrl": "https://example.com/image.jpg",
                "latitude": 48.858844,
                "longitude": 2.294351,
                "material": "Canvas",
                "era": "Modern",
                "origin": "Unknown",
                "lore": "This is a generated piece of art based on your mood."
            }
        ]

<<<<<<< HEAD
        # Return the generated art pieces
=======
>>>>>>> c814233 (ai recommendations working. need training)
        return jsonify(art_pieces), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
<<<<<<< HEAD
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))
=======
    app.run(debug=True)
>>>>>>> c814233 (ai recommendations working. need training)
