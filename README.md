 ReFood AI: The Smart Kitchen Assistant

Ending food waste through Artificial Intelligence, Gamification, and Community Donation.

 Project Overview

ReFood AI is a fully responsive, cross-platform application (Web, Android, iOS) developed at UniHack 2025 to tackle the global crisis of food waste. We integrate advanced Gemini Vision AI and intelligent analytics to transform how households manage, consume, and donate surplus food, turning environmental responsibility into economic savings and a fun, community-driven activity.

The Problem We Solve

Globally, one-third of all food is wasted, resulting in massive economic loss (trillions of dollars annually) and contributing 8–10% of global greenhouse gas emissions. Households lack the tools to accurately track freshness and find easy, immediate solutions for surplus items.

The ReFood AI Solution

ReFood AI provides a full-cycle solution:

Preventive Intelligence: Uses AI to predict expiration and suggest immediate use.

Financial Incentive: Quantifies user savings to drive behavioral change.

Community Impact: Seamlessly connects surplus food to donation recipients.

 Key Features

1. AI Food Scanner (Multi-Modal Vision)

Our core feature uses AI to transform a simple photograph into actionable insights:

Accurate Food Identification & Freshness: Identifies the food item and provides a freshness assessment (Fresh, Needs Attention, Spoiled).

Storage Recommendations: Advises on optimal storage conditions to maximize shelf life.

Expiration Forecasting: Estimates the remaining usable days until spoilage.

Recipe Generation: Offers detailed recipes specifically designed to use the identified ingredients or potential leftovers.

2. AI Chat Assistant

An advanced chatbot available 24/7 to answer complex queries regarding:

Food waste reduction techniques.

Meal planning strategies.

Creative ways to use common leftovers.

3. Real-Time Analytics & Financial Tools

We empower users with clear data on their impact and savings:

Savings Calculator: Users input their family size and monthly grocery budget to receive a personalized annual savings projection achievable by reducing food waste.

Real-Time Waste Monitor: Displays live, simulated global food waste metrics to highlight the scale of the problem and motivate users.

Waste Reduction Charts: Visual projections illustrating how the user's adoption of ReFood AI improves their personal waste profile over time.

4. Community & Gamification (Leaderboards)

We foster a community of "Food Saviors":

Donation Platform: Users can register surplus food and instantly find nearby NGOs, Homeless Shelters, and Animal Shelters for drop-off or pickup.

Leaderboards: Users compete based on quantifiable impact metrics:

Most Money Saved (Financial Impact)

Most Food Donated (Social Impact)

Most Eco-Friendly (Environmental Impact)

Review System: Allows users to share their experiences and build trust in the platform.

5. Food Saver Game

A fun, casual game where users catch falling food items before they hit the ground, reinforcing the core mission of waste prevention.

 Technology Stack (UniHack 2025)

Our application is built on a robust, cross-platform architecture focused on speed and real-time data processing.

Category

Technology

Purpose

Frontend/Platform

Flutter / Dart

Single codebase for Web, Android, and Windows development. Ensures full responsiveness across all screen sizes.

AI / Machine Vision

Gemini API (google_generative_ai SDK)

Used for image analysis, freshness assessment, and contextual ChatBot responses.

Data Persistence

Hive / Hive Flutter

High-performance local storage solution for user scores, settings, and form data (e.g., pending donations/reviews).

Mapping / Location

flutter_map / geolocator

Displays map layers and retrieves real-time geographical data for nearby donation centers.

Data Visualization

fl_chart

Used to generate interactive Line, Bar, and Pie charts for analytics and savings projection screens.

 Application Screenshots

Feature

Description

Dashboard

The centralized hub offering quick access to the AI Scanner, Chat, and Donation tools.

Savings Calculator

Interactive form showing projected monthly and annual savings based on user input.





Food Scanner

The screen showing a photo ready for analysis, with the Analyze button.





Donation Flow

The interface for selecting a recipient (Animal Shelters, NGOs, Homeless) and submitting pickup details.




🏃 Getting Started (Local Setup)

To run ReFood AI locally, ensure you have the Flutter SDK installed.

Clone the repository:

git clone [Your Repository URL]
cd ReFood-AI


Install dependencies:

flutter pub get


Setup API Keys (Crucial for AI/Mapping):

Obtain a Gemini API Key from Google AI Studio.

Create a file named .env in the root directory and add your keys:

GEMINI_API_KEY=YOUR_GEMINI_KEY
MAPTILER_KEY=YOUR_MAPTILER_KEY 


Run the application (Web Recommended):

flutter run -d chrome


 Team & Contributions

This project was proudly developed by [Your Team Name] for UniHack 2025.

Name

Role

GitHub

[Your Name]

[Your Role]

[@YourGitHubHandle]

[Team Member 2]

[Their Role]

[@TheirGitHubHandle]

[Team Member 3]

[Their Role]

[@TheirGitHubHandle]

[Team Member 4]

[Their Role]

[@TheirGitHubHandle]

We believe ReFood AI can be the definitive tool in the global fight against food waste! Sign by AQUALIX SLAYERS TEAM
