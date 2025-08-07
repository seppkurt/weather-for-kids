import appdaemon.plugins.hass.hassapi as hass
import requests
import json
from datetime import datetime, timedelta

class WeatherForKids(hass.Hass):
    def initialize(self):
        # Configuration
        self.home_assistant_url = self.args.get("home_assistant_url")
        self.long_living_token = self.args.get("long_living_token")
        self.temperature_forecast_entity = self.args.get("temperature_forecast_entity")
        self.rain_forecast_entity = self.args.get("rain_forecast_entity")
        self.current_temperature_entity = self.args.get("current_temperature_entity")
        
        # Headers for Home Assistant API
        self.headers = {
            "Authorization": f"Bearer {self.long_living_token}",
            "Content-Type": "application/json",
        }
        
        # Run every 5 minutes
        self.run_every(self.update_display, "now", 5 * 60)
        
    def get_entity_state(self, entity_id):
        """Get entity state from Home Assistant"""
        try:
            url = f"{self.home_assistant_url}/api/states/{entity_id}"
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            self.log(f"Error getting entity state for {entity_id}: {e}")
            return None
    
    def get_weather_data(self):
        """Get weather data from Home Assistant entities"""
        weather_data = {
            "current_temp": None,
            "forecast_temp": None,
            "rain_forecast": False
        }
        
        # Get current temperature
        current_temp_state = self.get_entity_state(self.current_temperature_entity)
        if current_temp_state:
            try:
                weather_data["current_temp"] = float(current_temp_state["state"])
            except (ValueError, TypeError):
                self.log(f"Invalid current temperature value: {current_temp_state['state']}")
        
        # Get temperature forecast
        forecast_temp_state = self.get_entity_state(self.temperature_forecast_entity)
        if forecast_temp_state:
            try:
                weather_data["forecast_temp"] = float(forecast_temp_state["state"])
            except (ValueError, TypeError):
                self.log(f"Invalid forecast temperature value: {forecast_temp_state['state']}")
        
        # Get rain forecast
        rain_forecast_state = self.get_entity_state(self.rain_forecast_entity)
        if rain_forecast_state:
            weather_data["rain_forecast"] = rain_forecast_state["state"].lower() in ["true", "yes", "1", "on"]
        
        return weather_data
    
    def get_clothing_recommendations(self, weather_data):
        """Get clothing recommendations based on weather data"""
        temp = weather_data.get("forecast_temp") or weather_data.get("current_temp")
        rain_forecast = weather_data.get("rain_forecast", False)
        
        recommendations = {
            "shirt": "T-Shirt" if temp and temp >= 16 else "Pullover",
            "pants": "Short pants" if temp and temp >= 12 else "Long pants",
            "umbrella": "Regenschirm" if rain_forecast else "Kein Regenschirm",
            "hat": "Mütze" if temp and temp < 7 else "Keine Mütze"
        }
        
        return recommendations
    
    def create_display_data(self, weather_data, recommendations):
        """Create the display data for Tidbyt"""
        current_temp = weather_data.get("current_temp")
        temp_text = f"{current_temp:.1f}°C" if current_temp is not None else "N/A"
        
        # Create the display layout
        display_data = {
            "text": [
                {"text": "Wetter für Kinder", "color": "white", "font": "5x7"},
                {"text": f"Temperatur: {temp_text}", "color": "yellow", "font": "5x7"},
                {"text": f"Oberteil: {recommendations['shirt']}", "color": "blue", "font": "5x7"},
                {"text": f"Hose: {recommendations['pants']}", "color": "green", "font": "5x7"},
                {"text": f"Regenschirm: {recommendations['umbrella']}", "color": "cyan", "font": "5x7"},
                {"text": f"Mütze: {recommendations['hat']}", "color": "red", "font": "5x7"}
            ]
        }
        
        return display_data
    
    def update_display(self, kwargs):
        """Update the Tidbyt display"""
        try:
            # Get weather data
            weather_data = self.get_weather_data()
            
            # Get clothing recommendations
            recommendations = self.get_clothing_recommendations(weather_data)
            
            # Create display data
            display_data = self.create_display_data(weather_data, recommendations)
            
            # Update the Tidbyt display
            self.set_state("sensor.weather_for_kids_display", state="updated", attributes=display_data)
            
            self.log("Weather for kids display updated successfully")
            
        except Exception as e:
            self.log(f"Error updating display: {e}")
