1. Based on the document provides here is my understandings:
    1. What is the app and who it is for:
        1. Its a weather planning app that turns a 7 day forecast into activity specific suitability ranking for a searched location.
        2. Rather showing raw weather data, in translate data into simple answer How good conditions are for skiing, surfing, indoor and ourdooor sightseeing.
        3. Its for people deciding what to do or where to go based on weather primarily:
            1. Travelers/tourists planning a trip and unsure whether to pack for sightseeing or indoor backup plans.
            2. Outdoor enthusiasts (skiers, surfers) checking if conditions at a specific destination will be worth the trip.
            3. Casual users planning a week ahead who want a quick "is this a good week for X" answer rather than parsing raw forecasts themselves
    2. What outcome do they expect: 
        1. Knowing which days in the next week are good, mediocre, or bad for a specific activity at a specific place.
        2. So they can decide when to go skiing/surfing/sightseeing, or decide whether a location is worth visiting for that purpose this week.
        3. User don't have to manually interpret temperature, snowfall, wind speed, wave-relevant conditions, or precipitation themselves.
2. I've to build an app that does following/ How does the app get users what they want.
    1. Search a city -> Using open-meteo geocoding API -> It will list results -> Let user pick city/location
    2. That location will give Latitude and Longitude -> using this hit Forecast API and get weather data for next 7 days 
    3. Turn each day's weather into suitability score/rank for these four activities skiing, surfing, indoor and outdoor sightseeing
    4. Show result to user
3. Now 2.1 and 2.2 are straight forward part. Coming 2.3 score/ranking the data to show suitability for the activities,
    1. I have not does the skiing and surfing personally so I don't know what weather parameters are considered good or bad.
    2. For any location I know what kind of weather forecasting data I get. So I used that API and its reponse to filter out 
        data which I actually need and usefull for end user to take a decision for such activities. 
    3. I've attached that prompt and response here: [https://share.gemini.google/DfyEDjvAdSLH](https://share.gemini.google/DfyEDjvAdSLH)
    4. Now I've the relevant parameters that assess the suitabiltiy for 4 activities now I need a ranking system for end users.
    5. I used AI model and added context about forecast data and activitiy suitabilty and build a scoring system: [https://claude.ai/share/fdefab05-bb21-4900-a3f8-fbb4ed9394d6](https://claude.ai/share/fdefab05-bb21-4900-a3f8-fbb4ed9394d6)
4. Screen and User flows
