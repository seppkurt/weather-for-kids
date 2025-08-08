load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")
load("encoding/json.star", "json")
load("cache.star", "cache")
load("http.star", "http")
load("math.star", "math")

def get_entity_status(ha_server, entity_id, token):
    if ha_server == None:
        fail("Home Assistant server not configured")

    if entity_id == None:
        fail("Entity ID not configured")

    if token == None:
        fail("Bearer token not configured")

    # For testing, return mock data if using test URLs
    if ha_server == "http://test":
        # Return different mock data based on entity type
        if "temp" in entity_id.lower():
            return {"state": "22.5"}  # Mock temperature
        elif "rain" in entity_id.lower():
            return {"state": "2.5"}  # Mock: moderate rain (2.5 mm/h)
        elif "uv" in entity_id.lower():
            return {"state": "5.2"}   # Mock: high UV index
        else:
            return {"state": "22.5"}  # Default mock temperature

    state_res = None
    cache_key = "%s.%s" % (ha_server, entity_id)
    cached_res = cache.get(cache_key)
    if cached_res != None:
        state_res = json.decode(cached_res)
    else:
        rep = http.get("%s/api/states/%s" % (ha_server, entity_id), headers = {
            "Authorization": "Bearer %s" % token
        })
        if rep.status_code != 200:
            print("HTTP request failed with status %d", rep.status_code)
            return None

        state_res = rep.json()
        cache.set(cache_key, rep.body(), ttl_seconds = 300)
    return state_res

def skip_execution():
    print("skip_execution")
    return []

def get_conditional_items(umbrella_text, hat_text, sun_cream_text):
    """Return only the items that are needed (not 'kein' or 'keine')"""
    items = []
    
    if "kein" not in umbrella_text and "keine" not in umbrella_text:
        items.append(umbrella_text)
    
    if "kein" not in hat_text and "keine" not in hat_text:
        items.append(hat_text)
    
    if "kein" not in sun_cream_text and "keine" not in sun_cream_text:
        items.append(sun_cream_text)
    
    if len(items) == 0:
        return "Alles gut!"
    else:
        return " + ".join(items)

def get_clothing_recommendations(temp, rain_forecast, uv_index):
    recommendations = {}
    
    # Upper body recommendation
    if temp >= 16:
        recommendations["shirt"] = "Shirt"
    else:
        recommendations["shirt"] = "Pullover"
    
    # Pants recommendation
    if temp >= 12:
        recommendations["pants"] = "kurze Hose"
    else:
        recommendations["pants"] = "lange Hose"
    
    # Umbrella recommendation
    if rain_forecast:
        recommendations["umbrella"] = "Schirm"
    else:
        recommendations["umbrella"] = "kein Schirm"
    
    # Hat recommendation
    if temp < 7:
        recommendations["hat"] = "Mütze"
    else:
        recommendations["hat"] = "keine Mütze"
    
    # Sun cream recommendation based on UV index
    if uv_index >= 3:
        recommendations["sun_cream"] = "Creme"
    else:
        recommendations["sun_cream"] = "keine Creme"
    
    return recommendations

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "ha_url",
                name = "Home Assistant URL",
                desc = "Home Assistant URL. The address of your HomeAssistant instance, as a full URL.",
                icon = "home",
            ),
            schema.Text(
                id = "ha_token",
                name = "Home Assistant Token",
                desc = "Home Assistant token. Navigate to User Settings > Long-lived access tokens.",
                icon = "key",
            ),
            schema.Text(
                id = "current_temp_entity",
                name = "Current Temperature Entity",
                desc = "Entity for current temperature in Celsius.",
                icon = "thermometer-half",
            ),
            schema.Text(
                id = "forecast_temp_entity",
                name = "Temperature Forecast Entity",
                desc = "Entity for temperature forecast in Celsius.",
                icon = "thermometer-half",
            ),
            schema.Text(
                id = "rain_forecast_entity",
                name = "Rain Forecast Entity",
                desc = "Entity for rain intensity in mm/h (e.g., 0.0 = no rain, 2.5 = moderate rain).",
                icon = "cloud-rain",
            ),
            schema.Text(
                id = "uv_index_entity",
                name = "UV Index Entity",
                desc = "Entity for UV index (number 0-11+).",
                icon = "sun",
            ),
        ],
    )

def main(config):
    ha_server = config.get("ha_url")
    token = config.get("ha_token")

    # Get current temperature
    entity_id_current_temp = config.get("current_temp_entity")
    print("Current temp entity ID:", entity_id_current_temp)
    entity_status = get_entity_status(ha_server, entity_id_current_temp, token)
    if entity_status == None:
        return skip_execution()
    
    current_temp = None
    if entity_status["state"] != "":
        current_temp = float(entity_status["state"])
        print("Current temp value:", current_temp)
    else:
        print("Current temp state is empty")

    # Get forecast temperature
    forecast_temp = None
    if ha_server == "http://test":
        forecast_temp = 25.0  # Mock: different from current for testing
        print("Forecast temp (mock):", forecast_temp)
    else:
        entity_id_forecast_temp = config.get("forecast_temp_entity")
        print("Forecast temp entity ID:", entity_id_forecast_temp)
        entity_status = get_entity_status(ha_server, entity_id_forecast_temp, token)
        if entity_status == None:
            return skip_execution()
        
        if entity_status["state"] != "":
            forecast_temp = float(entity_status["state"])
            print("Forecast temp value:", forecast_temp)
        else:
            print("Forecast temp state is empty")

    # Get rain forecast (mock data for testing)
    rain_forecast = False
    if ha_server == "http://test":
        rain_forecast = False  # Mock: no rain (sunny day)
        print("Rain forecast (mock):", rain_forecast)
    else:
        # Parse rain data from mm/h entity
        entity_id_rain_forecast = config.get("rain_forecast_entity")
        print("Rain forecast entity ID:", entity_id_rain_forecast)
        rain_entity_status = get_entity_status(ha_server, entity_id_rain_forecast, token)
        if rain_entity_status and rain_entity_status["state"] != "":
            rain_mmh = float(rain_entity_status["state"])
            print("Rain intensity (mm/h):", rain_mmh)
            # Threshold: 0.5 mm/h - light rain or drizzle
            rain_forecast = rain_mmh >= 0.5
            print("Rain forecast (calculated):", rain_forecast)
        else:
            print("Rain entity state is empty")

    # Get UV index
    entity_id_uv_index = config.get("uv_index_entity")
    print("UV index entity ID:", entity_id_uv_index)
    entity_status = get_entity_status(ha_server, entity_id_uv_index, token)
    if entity_status == None:
        return skip_execution()
    
    uv_index = 0
    if entity_status["state"] != "":
        uv_index = float(entity_status["state"])
        print("UV index value:", uv_index)
    else:
        print("UV index state is empty")

    # Use forecast temperature for recommendations, fallback to current
    temp_for_recommendations = current_temp
    if forecast_temp != None:
        temp_for_recommendations = forecast_temp
    
    # Get clothing recommendations
    recommendations = get_clothing_recommendations(temp_for_recommendations, rain_forecast, uv_index)
    
    # Format temperature display
    temp_display = "N/A"
    if current_temp != None:
        temp_display = str(current_temp) + "°C"
    
    # Create display text in German
    temp_now_text = temp_display
    temp_max_text = str(forecast_temp) + "°C" if forecast_temp != None else temp_display
    shirt_pants_text = recommendations["shirt"] + " + " + recommendations["pants"]
    umbrella_text = recommendations["umbrella"]
    hat_text = recommendations["hat"]
    sun_cream_text = recommendations["sun_cream"]

    return render.Root(
        render.Column(
            children=[
                # Row 1: Current Temperature, Max Temperature
                render.Row(
                    children=[
                        # Left column: Current Temperature
                        render.Padding(
                            pad=(1, 1, 1, 1),
                            child=render.WrappedText(
                                width=30,
                                font="tom-thumb",
                                content=temp_now_text,
                                color="#FFFF00",  # yellow
                                align="center",
                            ),
                        ),
                        # Right column: Max Temperature
                        render.Padding(
                            pad=(1, 1, 1, 1),
                            child=render.WrappedText(
                                width=30,
                                font="tom-thumb",
                                content=temp_max_text,
                                color="#FFA500",  # orange
                                align="center",
                            ),
                        ),
                    ]
                ),
                # Row 2: Shirt + Pants combined
                render.Row(
                    children=[
                        render.Padding(
                            pad=(1, 1, 1, 1),
                            child=render.WrappedText(
                                width=62,
                                font="tom-thumb",
                                content=shirt_pants_text,
                                color="#0088FF",  # blue
                                align="center",
                            ),
                        ),
                    ]
                ),
                # Row 3: Umbrella, Hat, Sun Cream (only if needed)
                render.Row(
                    children=[
                        # Only show items if they are needed
                        render.Padding(
                            pad=(1, 1, 1, 1),
                            child=render.WrappedText(
                                width=62,
                                font="tom-thumb",
                                content=get_conditional_items(umbrella_text, hat_text, sun_cream_text),
                                color="#00FF00",  # green
                                align="center",
                            ),
                        ),
                    ]
                ),
            ]
        ),
    )
