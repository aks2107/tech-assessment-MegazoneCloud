# Weather App - Design Choices

## Overview

This markdown outlines the decisions, tech stack, and strategies used in the development of the Weather App.

### Technical Stack
1. Framework: Angular
    - Why: Angular was chosen because it is an ecosystem that is ready for deployment. Plus, I have experience working with Angular.

2. Strict Typing: TypeScript interface was created to match the API structure of WeatherData. This helps with avoiding runtime errors caused by accessing properties that do not exist.

3. Styling: Tailwind CSS
    - Why: Tailwind CSS makes development faster and reduces the complexity of CSS code.

4. Responsiveness: Tailwind's built-in breakpoint system made implementing the design requirement easy. This made it so that the site can be loaded on all screen sizes.

### Architectural Decisions
1. Angular's Two-Way Binding (ngModel) and Structural Directives (*ngIf) handle the synchronization between the logic and the view automatically.

2. API Integration & Security
    - Environment Files: API keys are sensitive information and the application uses environment files to hide the keys. This allows the key to be excluded from Git so that API keys are not leaked.

3. Error Handling: The HttpClient includes explicit error handling. If the API fails, the UI shows an error message.

4. Start State: A message for the user to search for a city.

5. Loading State: A message that lets the user know that the weather is being retrieved.

6. Error State: A message to let the user know that there is an error.

7. UI Strategy:
    - Flexbox & Grid: A combination of Flexbox and CSS Grid was used.
    
    - Search Bar: Uses flex-col and flex-row to maximize usable space.

    - Cards: Uses vertical stack to separate "Today" vs "Tomorrow" forecast cards.

    - Visual Fonts: Large fonts are used for the important data points like temperature, while less important data points like location use smaller fonts.

### Future Improvements
- If I were to improve this project for the future I would do the following:
    - Caching: Implementing an HTTP Interceptor to cache API responses to reduce API usage limits.

    - Unit Testing: Implementing comprehensive tests to validate the logic.

    - UI: Add more colors and more complex designs to make the site look better.