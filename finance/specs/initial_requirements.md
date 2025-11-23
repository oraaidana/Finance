I want to build a finance tracker app called QarzhyAI that can help users to track their incomes/incomes, categorize and uploading bank statements. This app will interact with ML so make a space to me so I can manually add it. 

The app should be built with SwiftUI and have the following features:

## Basic UI

Simple app with following pages:

- Splash Screen
- Authentications Screens (Login, Register, Forgot Password, Email Verification)
- Bottom tabs with:
    - Home page, Analytics, Profile, Chat

## Adding transactions:

- It can either be an expense or income. The amount and date of the transaction can be picked. 
- Both have their categories by default, also user can upload their own. Categories by emoji picking.

## Uploading bank statements

- Users can upload their bank statement. The ML will parse and categorize this and send respond to the app.
- The app should show how the ML divided to categories and provide editting (changing amount, category, date and etc.).

## Analytics

- Pie chart where it shows spendings and earnings of user. 
- Provide some recomendations using ML
- View spendings on different period (date, last week, last two weeks, last month, and etc.)

## Chat

- Simple chat where user can ask for financial recomendations
- User can ask recomendations about the analyics.
- Also ML will receive this queries and send back to an App. 


## Theme

- The app uses system, light, dark mode
- The theme can be changed in settings


### Code styles

- Architecture of an app is MVVM
- The code should be clean
