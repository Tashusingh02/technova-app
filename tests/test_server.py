import unittest
# 1. Import the Flask app instance from app.server
from app.server import app

# 2. Define the test class extending unittest.TestCase
class TestTechNovaApp(unittest.TestCase):

    # 3. Create the setUp method to configure the test client
    def setUp(self):
        # Enable testing mode for Flask app (disables error trapping for better traceback)
        app.testing = True
        # Create a test client to send requests to the app
        self.client = app.test_client()

    # 4. Implement the three specified test methods
    
    # Test 1: Verify the server endpoint exists and is healthy (returns 200 OK)
    def test_home_status_code(self):
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)

    # Test 2: Verify the response is correctly formatted as JSON
    def test_home_returns_json(self):
        response = self.client.get("/")
        self.assertEqual(response.content_type, "application/json")

    # Test 3: Verify the JSON payload has the required fields
    def test_home_response_fields(self):
        response = self.client.get("/")
        data = response.get_json()
        self.assertIn("app", data)
        self.assertIn("version", data)
        self.assertIn("status", data)

# 5. Run the tests using unittest's main runner with verbosity set to 2
if __name__ == "__main__":
    unittest.main(verbosity=2)
