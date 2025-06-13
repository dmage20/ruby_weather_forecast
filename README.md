# README

# Weather Forecast App

This is a simple Ruby on Rails application that allows users to enter a physical address or zip code and retrieve the current weather and a 3-day weather forecast for the corresponding location. It integrates with the [WeatherAPI](https://www.weatherapi.com/) and [OpenStreetMap Nominatim API](https://nominatim.org/).
It is meant to demonstrates service-oriented design, API integration, caching, and simple analytics tracking.

## Ruby Version

- Ruby 3.2.2  
- Rails 7.1.3.2

## System Dependencies

- PostgreSQL
- [WeatherAPI.com](https://www.weatherapi.com/) key (for weather forecasts)
- [Nominatim API](https://nominatim.org/release-docs/latest/api/Search/) (for geocoding)

## Features

- User can input an address and receive a weather forecast in the US
- Uses external APIs to geocode and fetch weather data
- Caches forecast results by zip code for 30 minutes
- Collects search data for reporting and product insights
- Retries API calls automatically on transient failures
- Includes unit, request, and system tests
- Clean, minimal UI with CSS separation

## Setup Instructions

1. Install dependencies:
   ```bash
   bundle install
   yarn install
   ```

2. Add your WeatherAPI key to credentials:
   
	 To edit securely, run:
   ```bash
   EDITOR="code --wait" bin/rails credentials:edit
   ```
	Then add your api key
   ```yaml
   weather_api:
     key: your_weatherapi_key
   ```


---

## Database Creation

```bash
rails db:create
```

---

## Database Initialization

```bash
rails db:migrate
```

---

## How to Run the Test Suite

```bash
bundle exec rspec
```

RSpec is used to test both request and service logic.

---

## Services and Features

- **WeatherApiService**: Calls the Weather API and returns 3-day forecast data.
- **GeocodingApiService**: Converts a user-entered address to a zip code using the Nominatim API.
- **Rails Cache**: Forecast results are cached by zip code for 30 minutes.
- **Retry Logic**: A utility method provides fault tolerance when dealing with transient API errors.

---

## Deployment Instructions

This is a standard Rails app and can be deployed using for example:

- **Heroku**
- **Fly.io**

Don’t forget to set the `RAILS_MASTER_KEY` in production environments for credentials access.
And to share with other developers. 

---

## Decomposition

- `ForecastsController`: Handles form submission, manages API calls, caching, and Search object creation.
- `Search`: Stores address and zip code for historical trend tracking.
- `WeatherApiService` and `GeocodingApiService`: Isolated service objects for external integrations.
- `ReportsController`: Displays aggregate data and usage insights for admins or analysts.

---

## Design Patterns

- **Service Object Pattern**: Used for both Weather and Geocoding API integrations.
- **Retry logic**: Could be generalized into a base service layer for cross-cutting concerns.

---

## Scalability Considerations

- Caching via `Rails.cache` reduces repeated API calls for frequent searches and provides a simple caching solution.
- Search records are scoped to recent activity to show the flexibility and usefulness of thoughtful database implementation.
- Extracted service objects make external API logic easier to extend or replace.
- In a real-world system:
  - Background jobs (e.g. Sidekiq) would offload slow or rate-limited API calls.
  - Redis or Memcached would be used for scalable caching.

---

## Notes

- Address input is limited to 200 characters to prevent abuse and malformed requests.
- All searches are tracked in the database to support business insights.
- Reporting pages are meant to demonstrate the value of usage tracking and would be restricted to admin users in production.

