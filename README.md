# Weather App

A production-quality Rails application that provides weather forecasts based on address input.

## Features

- **Address Resolution**: Converts any valid address (or Zip Code) to strict coordinates using the `geocoder` gem (via Nominatim).
- **Weather Data**: Fetches real-time weather data from the [National Weather Service (NWS) API](https://www.weather.gov/documentation/services-web-api).
- **Caching**: Implements a robust 30-minute caching strategy based on Zip Code to minimize API calls and improve performance.
- **Clean UI**: A responsive, accessible interface built with semantic HTML and vanilla CSS.
- **Resiliency**: Handles API failures gracefully and provides user feedback.

## Tech Stack

- **Ruby on Rails 7.2**
- **Geocoder**: For address-to-coordinate resolution.
- **Faraday**: For reliable HTTP requests to NWS.
- **RSpec**: For comprehensive unit and request testing.
- **Redis** (Optional): Configured for production caching, falls back to MemoryStore in development.

## Setup Instructions

1.  **Install Dependencies**:
    ```bash
    bundle install
    ```

2.  **Run Tests**:
    ```bash
    bundle exec rspec
    ```

3.  **Start Server**:
    ```bash
    bin/rails server
    ```

4.  **Visit**: `http://localhost:3000`

## Decomposition & Design

### Components

-   **`WeatherController`**: Handles the HTTP request/response cycle. It accepts user input, delegates logic to the service layer, and prepares data for the view.
    -   *Why?* To keep the controller "skinny" and focused only on routing and flow control.

-   **`WeatherService`**: The core business logic unit.
    -   **Responsibilities**:
        1.  Geocoding the input address.
        2.  Checking the cache.
        3.  Fetching data from the NWS API (Grid & Forecast endpoints).
        4.  Transforming raw JSON into a consumable `WeatherForecast` object.
    -   *Pattern*: Service Object. Used to encapsulate complex external interactions.

-   **`WeatherForecast` (Model/Value Object)**: A plain Ruby object (non-ActiveRecord) that serves as the data structure for the view.
    -   *Why?* Decouples the view from the raw API response structure, making future API changes easier to manage.

### Scalability Considerations

-   **Caching**: The 30-minute expiration on Zip Code keys ensures that we don't bombard the NWS API for popular locations. Using Rails Cache interface allows easy swapping to Redis/Memcached for distributed caching in production.
-   **API Client**: `Faraday` is used with a custom User-Agent (required by NWS) and is easily extensible with middleware for retries or logging if needed.

### Best Practices

-   **Encapsulation**: The Controller doesn't know *how* weather is fetched, only that it gets a `WeatherForecast`.
-   **Error Handling**: Service layer raises standard errors which are caught and displayed as flash messages, preventing crashes.
-   **TDD**: Features were implemented with RSpec tests driven development.
