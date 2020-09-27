#import dependencies
import os
import pandas
from math import radians, cos, sin, asin, sqrt

# Import data and data engereering (change file path)
data = pandas.read_csv("./earthquakes.csv")
data = data.drop([3378,7512,20650])
dataset = data.loc[:,["Date","Latitude","Longitude","Type","Depth","Magnitude"]]
dataset = dataset.rename(columns={'Latitude':'lat2', 'Longitude': 'lon2'})
dataset = dataset[dataset.Type == "Earthquake"]
# optimize in 
dataset.pop('Type')
dataset.pop('Date')
dataset.pop('Depth')
dataset['Distance']= 0
dataset['Class_Score']= 0
#dataset['Class']= ""

#input from smartcontract 1
arg = [os.environ['ARG0'], os.environ['ARG1']]

#Distance caluclation
i = 1
for i, row in dataset.iterrows():
    lat1 = float(arg[0])
    lon1 = float(arg[1])
    lon2 = dataset.lon2[i]
    lat2 = dataset.lat2[i]
    #convert decimal degrees to radians 
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])

    # haversine formula
    dlon = lon2 - lon1 
    dlat = lat2 - lat1 
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a)) 
    r = 6371 # Radius of earth in kilometers. Use 3956 for miles
    result = c * r
    if result <= 1600:
        dataset.Distance[i] = result
    i = i + 1
    
dataset = dataset[dataset.Distance != 0]

# classification of distance and magnitude 
# https://sciencestruck.com/richter-scale-formula
i = 1
for i, row in dataset.iterrows():
    if dataset.Distance[i] < 32 and 4.9 < dataset.Magnitude[i] < 6.0: # 32 KM = 20 miles
        # dataset.Class[i] = "Moderate"
        dataset.Class_Score[i] = 10
    if dataset.Distance[i] < 80 and 5.9 < dataset.Magnitude[i] < 7.0: # 80 KM = 50 miles 
        # dataset.Class[i] = "Strong"
        dataset.Class_Score[i] = 30
    if dataset.Distance[i] < 160 and 6.9 < dataset.Magnitude[i] < 8.0: # 160 KM = 100 miles 
        # dataset.Class[i] = "Major"
        dataset.Class_Score[i] = 80
    if dataset.Distance[i] < 1600 and 7.9 < dataset.Magnitude[i] < 10.0: # 1600 KM = 1000 miles 
        # dataset.Class[i] = "Great"
        dataset.Class_Score[i] = 100
    i = i + 1
dataset = dataset[dataset.Class_Score != 0]
if len(dataset) == 0:
    #Preventing return of nan when dataframe is empty
    result = 1
else:
    # Risk calculation
    Sum_Score = dataset["Class_Score"].sum()
    Number = len(dataset)
    result = Sum_Score / Number

print(result)