# 1. Import Flask and the os module
import os
from flask import Flask, jsonify

# 2. Create the Flask application instance
app = Flask(__name__)

# 3. Read the PORT environment variable, defaulting to 5000 if it is not set
# The environment variable is read as a string, so we convert it to an integer.
PORT = int(os.environ.get("PORT", 5000))

# 4. Create a route at "/" that returns the status and metadata as a JSON response
@app.route("/")
def index():
    return jsonify({
        "app": "TechNova",
        "version": "2.0.0",
        "status": "running",
        "port": PORT,
        "build": "automated",
        "verified_at": "2026-06-30"
    })

# 5. Run the Flask application server if this script is executed directly
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=PORT)
