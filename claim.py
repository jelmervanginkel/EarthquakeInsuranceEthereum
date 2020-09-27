#import depandencies
import sys
import os
import requests
import json
from math import radians, cos, sin, asin, sqrt

# input
arg = [os.environ['ARG0'], os.environ['ARG1']]

# defining input 
lat1 = float(arg[0])
lon1 = float(arg[1])

# earthquake location from seismicportal.eu API x
data = json.loads(requests.get("http://www.seismicportal.eu/fdsnws/event/1/query?limit=1&format=json&minmag=5.0").text)
for i in data["features"]:
    # Magnitude is a float between 5.0 and 9.9 (10.0)
    Mag = i["properties"]["mag"]
    lat2 = i["properties"]["lat"]
    lon2 = i["properties"]["lon"]

# convert decimal degrees to radians 
lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])

# haversine formula 
dlon = lon2 - lon1 
dlat = lat2 - lat1 
a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
c = 2 * asin(sqrt(a)) 
r = 6371 # Radius of earth in kilometers. Use 3956 for miles
Dis = int(c * r)

# Coverage levels based on magnitude and distance
if Dis < 32 and 4.9 < Mag < 6.0: # 32 KM = 20 miles
    # dataset.Class[i] = "Moderate"
    result = 10
if Dis < 80 and 5.9 < Mag < 7.0: # 80 KM = 50 miles 
    # dataset.Class[i] = "Strong"
    result = 30
if Dis < 160 and 6.9 < Mag < 8.0: # 160 KM = 100 miles 
    # dataset.Class[i] = "Major"
    result = 80
if Dis < 1600 and 7.9 < Mag < 10.0: # 1600 KM = 1000 miles 
    # dataset.Class[i] = "Great"
    result = 100
else: 
    result = 0

print(result)