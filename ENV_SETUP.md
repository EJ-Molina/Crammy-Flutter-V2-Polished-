# Environment Setup for Crammy App

This project uses environment variables to securely store API keys. Follow these steps to set up your environment:

## Setup Instructions

### 1. Copy the environment template
Copy the `.env.example` file to `.env`:
```bash
cp .env.example .env
```

### 2. Add your API keys
Open the `.env` file and replace the placeholder values with your actual API keys:

```env
# Environment variables for Crammy App
# DO NOT COMMIT THIS FILE TO VERSION CONTROL

# Gemini AI API Key - Get this from Google AI Studio
GEMINI_API_KEY=your_actual_gemini_api_key_here
```

### 3. Get your Gemini API Key
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Create a new API key
4. Copy the API key and paste it in your `.env` file

### 4. Install dependencies
```bash
flutter pub get
```

## Security Notes

- **Never commit the `.env` file to version control** - it's already added to `.gitignore`
- The `.env.example` file shows the expected format but doesn't contain real API keys
- Keep your API keys secure and don't share them publicly

## Project Structure

The environment configuration is managed by:
- `lib/helpers/environment_config.dart` - Helper class to access environment variables
- `.env` - Your actual environment variables (not tracked by git)
- `.env.example` - Template file showing required variables (tracked by git)

## Troubleshooting

If you get an error about missing environment variables:
1. Make sure your `.env` file exists in the project root
2. Verify that `GEMINI_API_KEY` is set in the `.env` file
3. Check that the API key is valid and has the necessary permissions