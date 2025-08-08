# 🌤️ Weather for Kids - Tidbyt App

A child-friendly weather visualization app for Tidbyt displays that provides clothing recommendations based on temperature and weather conditions.

## 📱 What it Shows

The app displays weather information in a compact 3-row layout:

**Row 1**: Current temperature (left) and max temperature (right)
**Row 2**: Combined shirt and pants recommendation
**Row 3**: Only shows items that are needed (umbrella, hat, sun cream)

```
┌─────────────────────────┐
│ 22.5°C │ 22.5°C │
│ Shirt + kurze Hose │
│ Creme │
└─────────────────────────┘
```

## 🎯 Clothing Recommendations

The app automatically recommends appropriate clothing based on temperature:

### 👕 Upper Body (Oberteil)
- **Shirt**: When temperature ≥ 16°C
- **Pullover**: When temperature < 16°C

### 👖 Pants (Hose)
- **kurze Hose**: When temperature ≥ 12°C
- **lange Hose**: When temperature < 12°C

### ☔ Umbrella (Regenschirm)
- **Regenschirm**: When rain is forecasted
- **kein Regenschirm**: When no rain is forecasted

### 🧢 Hat (Mütze)
- **Mütze**: When temperature < 7°C
- **keine Mütze**: When temperature ≥ 7°C

### 🧴 Sun Cream (Sonnencreme)
- **Creme**: When UV index ≥ 3
- **keine Creme**: When UV index < 3

## ⚙️ Configuration

Edit the `apps.yaml` file with your Home Assistant settings:

```yaml
weather_for_kids:
  module: app
  class: WeatherForKids
  home_assistant_url: "http://your-home-assistant-url:8123"
  long_living_token: "your-long-living-token-here"
  temperature_forecast_entity: "sensor.weather_temperature_forecast"
  rain_forecast_entity: "sensor.weather_rain_forecast"
  current_temperature_entity: "sensor.weather_current_temperature"
```

### 🔧 Required Settings

1. **home_assistant_url**: Your Home Assistant instance URL
2. **long_living_token**: Your Home Assistant long-lived access token
3. **temperature_forecast_entity**: Entity ID for temperature forecast
4. **rain_forecast_entity**: Entity ID for rain forecast (boolean)
5. **current_temperature_entity**: Entity ID for current temperature

## 🚀 Installation

1. Copy the `weather_for_kids.star` file to your Tidbyt apps directory
2. Configure the app with your Home Assistant settings:
   - Home Assistant URL
   - Long-lived access token
   - Entity IDs for temperature and rain forecast
3. The app will update automatically

## 📊 Data Sources

The app connects to Home Assistant to get:
- Current temperature
- Temperature forecast
- Rain forecast
- UV index

Make sure your Home Assistant has weather integration configured with the appropriate entities.

## 🎨 Display Features

- **Color-coded information**: Different colors for different types of information
- **German language**: All text is in German for German-speaking children
- **Automatic updates**: Refreshes every 5 minutes
- **Error handling**: Graceful handling of missing or invalid data

## 🔍 Troubleshooting

- Check that all entity IDs exist in your Home Assistant
- Verify your long-lived token has the correct permissions
- Ensure your Home Assistant URL is accessible
- Test the app locally with pixlet: `pixlet render weather_for_kids.star ha_url=your_url ha_token=your_token current_temp_entity=your_entity forecast_temp_entity=your_entity rain_forecast_entity=your_entity uv_index_entity=your_entity`
- For testing with mock data, use `ha_url=http://test` and any entity names: `pixlet render weather_for_kids.star ha_url=http://test ha_token=test current_temp_entity=test forecast_temp_entity=test rain_forecast_entity=test uv_index_entity=test`

### **Pixlet Serve Issues:**
- **Configuration Required**: When using `pixlet serve`, you must configure the app through the web interface at http://127.0.0.1:8080
- **Entity Validation**: The app will show errors until all required entities are configured
- **Mock Data**: Use `http://test` as Home Assistant URL and `test` for all entity IDs to see mock data

## 📝 Requirements

- Tidbyt display
- Home Assistant with weather integration
- Long-lived access token from Home Assistant

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 🚧 Known Issues & Future Improvements

### 🎨 **Visual Improvements Needed**
- **Icons for Non-Readers**: Current text-based icons (🌡️👕👖☔🧢🧴) may not be clear enough for very young children
- **Pixel Art Suggestions**: Consider using simple pixel art symbols instead of emoji
- **Color Coding**: Enhance color coding for different weather conditions
- **Visual Indicators**: Add simple visual indicators (dots, bars, etc.) for quick recognition

### 📊 **Data Source Improvements**
- **Forecast Data Parsing**: Many weather APIs provide combined forecast data rather than separate entities
- **Time-based Recommendations**: Consider time of day for clothing recommendations (morning vs afternoon)
- **Seasonal Adjustments**: Add seasonal logic for clothing recommendations
- **Location-based UV**: UV index varies significantly by location and time of day

### 🔧 **Technical Enhancements**
- **Error Handling**: Better handling of missing or invalid weather data
- **Caching**: Implement smarter caching for weather data
- **Fallback Values**: Provide sensible defaults when data is unavailable
- **Multiple Weather Sources**: Support for different weather APIs

### 🎯 **User Experience**
- **Age-appropriate Language**: Consider different text complexity for different age groups
- **Parent Controls**: Allow parents to customize recommendations
- **Weather Alerts**: Add special alerts for extreme weather conditions
- **Localization**: Support for multiple languages

## 💡 **Suggested Solutions**

### **For Visual Improvements:**
- Use simple geometric shapes instead of emoji
- Implement a color-coded system (red for hot, blue for cold, etc.)
- Add visual bars or dots to represent temperature/UV levels
- Consider using the Tidbyt's built-in icon library if available

### **For Data Source Issues:**
- Parse combined forecast entities to extract specific data
- Use time-based logic to determine appropriate clothing
- Implement fallback logic when specific entities are unavailable
- Add configuration for different weather API formats

## 📄 License

This project is open source and available under the MIT License.
