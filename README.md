# 🌤️ Weather for Kids - Tidbyt App

A child-friendly weather visualization app for Tidbyt displays that provides clothing recommendations based on temperature and weather conditions.

## 📱 What it Shows

The app displays weather information in a kid-friendly format with German text:

```
┌─────────────────────────┐
│    Wetter für Kinder    │
│  Temperatur: 18.5°C    │
│  Oberteil: T-Shirt     │
│  Hose: Short pants      │
│  Regenschirm: Nein      │
│  Mütze: Keine Mütze     │
└─────────────────────────┘
```

## 🎯 Clothing Recommendations

The app automatically recommends appropriate clothing based on temperature:

### 👕 Upper Body (Oberteil)
- **T-Shirt**: When temperature ≥ 16°C
- **Pullover**: When temperature < 16°C

### 👖 Pants (Hose)
- **Short pants**: When temperature ≥ 12°C
- **Long pants**: When temperature < 12°C

### ☔ Umbrella (Regenschirm)
- **Regenschirm**: When rain is forecasted
- **Kein Regenschirm**: When no rain is forecasted

### 🧢 Hat (Mütze)
- **Mütze**: When temperature < 7°C
- **Keine Mütze**: When temperature ≥ 7°C

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

1. Copy the `app.py` file to your AppDaemon apps directory
2. Add the configuration to your `apps.yaml` file
3. Restart AppDaemon
4. The app will update every 5 minutes

## 📊 Data Sources

The app connects to Home Assistant to get:
- Current temperature
- Temperature forecast
- Rain forecast

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
- Check AppDaemon logs for any error messages

## 📝 Requirements

- AppDaemon 4.x
- Home Assistant with weather integration
- Tidbyt display
- Python requests library

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is open source and available under the MIT License.
