###################################################################################################
# Step 4 - Climate App
#
#   Now that you have completed your initial analysis, design a Flask api 
#   based on the queries that you have just developed.
#
#      * Use FLASK to create your routes.
#
#   Routes
#
#       * `/api/v1.0/precipitation`
#           * Query for the dates and precipitation observations from the last year.
#           * Convert the query results to a Dictionary using `date` as the key and `prcp` as the value.
#           * Return the json representation of your dictionary.
#       * `/api/v1.0/stations`
#           * Return a json list of stations from the dataset.
#       * `/api/v1.0/tobs`
#           * Return a json list of Temperature Observations (tobs) for the previous year
#       * `/api/v1.0/<start>` and `/api/v1.0/<start>/<end>`
#           * Return a json list of the minimum temperature, the average temperature, and
#               the max temperature for a given start or start-end range.
#           * When given the start only, calculate `TMIN`, `TAVG`, and `TMAX` for all dates 
#               greater than and equal to the start date.
#           * When given the start and the end date, calculate the `TMIN`, `TAVG`, and `TMAX` 
#               for dates between the start and end date inclusive.
###################################################################################################
# import dependencies 
import datetime as dt
import numpy as np
import pandas as pd
import datetime as dt
import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, func
from flask import Flask, jsonify


#################################################
# Database Setup
#################################################
engine = create_engine("sqlite:///Resources/hawaii.sqlite")
# reflect the database into a new model
Base = automap_base()
# reflect the tables
Base.prepare(engine, reflect=True)

# Save reference to the table
Measurement = Base.classes.measurement
Station = Base.classes.station

# Create our session (link) from Python to the DB
session = Session(engine)

#################################################
# Last Date calculation
#################################################




#################################################
# Flask Setup
#################################################
app = Flask(__name__)

#################################################
# Flask Routes
#################################################
@app.route("/")
def welcome():
    """List all available api routes."""
    return (
        f"Available Routes:<br/>"
        f"<br/>"
        f"/api/v1.0/precipitation<br/>"
        f"- List of prior year rain totals from all stations<br/>"
        f"<br/>"
        f"/api/v1.0/stations<br/>"
        f"- List of Station numbers and names<br/>"
        f"<br/>"
        f"/api/v1.0/tobs<br/>"
        f"- List of prior year temperatures from all stations<br/>"
        f"<br/>"
        f"/api/v1.0/start<br/>"
        f"- When given the start date (YYYY-MM-DD), calculates the MIN/AVG/MAX temperature for all dates greater than and equal to the start date<br/>"
        f"<br/>"
        f"/api/v1.0/start/end<br/>"
        f"- When given the start and the end date (YYYY-MM-DD), calculate the MIN/AVG/MAX temperature for dates between the start and end date inclusive<br/>"
    )

#########################################################################################

@app.route("/api/v1.0/precipitation")
def precipitation():
    """Return a list of rain fall for prior year"""
#    * Query for the dates and precipitation observations from the last year.
#           * Convert the query results to a Dictionary using `date` as the key and `prcp` as the value.
#           * Return the json representation of your dictionary.
# Calculate the date 1 year ago from the last data point in the database

    last_date = session.query(Measurement.date).order_by(Measurement.date.desc()).limit(1).all()

    for l in last_date:
        y, m, d = l[0].split('-')

    query_date = dt.date(int(y), int(m), int(d)) - dt.timedelta(days=365)
    rain = session.query(Measurement.date, Measurement.prcp).\
        filter(Measurement.date >= query_date).\
        order_by(Measurement.date).all()

# Create a list of dicts with `date` and `prcp` as the keys and values
    all_rain = []
    for date, prcp in rain:
        rain_dict = {}
        rain_dict['date'] = date
        rain_dict['prcp'] = prcp
        all_rain.append(rain_dict)

    return jsonify(all_rain)

#########################################################################################
@app.route("/api/v1.0/stations")
def stations():
    all_stations = session.query(Station.name, Station.station).all()
    station_name = []
    for n, s in all_stations:
        st_dict = {}
        st_dict['name'] = n
        st_dict['station'] = s
        station_name.append(st_dict)
    
    return jsonify(station_name)
#########################################################################################
@app.route("/api/v1.0/tobs")
def tobs():
    """Return a list of temperatures for prior year"""
#    * Query for the dates and temperature observations from the last year.
#           * Convert the query results to a Dictionary using `date` as the key and `tobs` as the value.
#           * Return the json representation of your dictionary.
    last_date = session.query(Measurement.date).order_by(Measurement.date.desc()).limit(1).all()

    for l in last_date:
        y, m, d = l[0].split('-')

    query_date = dt.date(int(y), int(m), int(d)) - dt.timedelta(days=365)

    temperature = session.query(Measurement.date, Measurement.tobs).\
        filter(Measurement.date >= query_date).\
        order_by(Measurement.date).all()

# Create a list of dicts with `date` and `tobs` as the keys and values
    temperature_totals = []
    for result in temperature:
        row = {}
        row["date"] = result[0]
        row["tobs"] = result[1]
        temperature_totals.append(row)

    return jsonify(temperature_totals)
#########################################################################################
@app.route("/api/v1.0/<start>")
def trip1(start):

    last_date = session.query(Measurement.date).order_by(Measurement.date.desc()).limit(1).all()
    for l in last_date:
        y, m, d = l[0].split('-')

 # go back one year from start date and go to end of data for Min/Avg/Max temp  
    start_date= dt.datetime.strptime(start, '%Y-%m-%d')
    last_year = dt.timedelta(days=365)
    start = start_date-last_year
    end =  dt.date(int(y), int(m), int(d))
    trip_data = session.query(func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)).\
        filter(Measurement.date >= start).filter(Measurement.date <= end).all()
    trip = list(np.ravel(trip_data))
    return jsonify(trip)

#########################################################################################
@app.route("/api/v1.0/<start>/<end>")
def trip2(start,end):

  # go back one year from start/end date and get Min/Avg/Max temp     
    start_date= dt.datetime.strptime(start, '%Y-%m-%d')
    end_date= dt.datetime.strptime(end,'%Y-%m-%d')
    last_year = dt.timedelta(days=365)
    start = start_date-last_year
    end = end_date-last_year
    trip_data = session.query(func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)).\
        filter(Measurement.date >= start).filter(Measurement.date <= end).all()
    trip = list(np.ravel(trip_data))
    return jsonify(trip)

#########################################################################################

if __name__ == "__main__":
    app.run(debug=True)