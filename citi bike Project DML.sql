USE citi_bike;
## we use import function to import data to the data base



# insertion of the joint table dim_bus_stop_station
INSERT INTO dim_bus_stop_station(has_station_id,has_shelter_id)
SELECT  dim_station.station_id,dim_bus_stop.shelter_id
FROM dim_station
CROSS JOIN dim_bus_stop;

UPDATE citi_bike.dim_bus_stop_station
SET  `Distance Between` = (SELECT ST_Distance_Sphere(
    point(bus.Longtitude, bus.Latitude),
    point(station.Longitude, station.Latitude))
    FROM dim_bus_stop AS bus, dim_station AS station
    WHERE bus.shelter_id = citi_bike.dim_bus_stop_station.has_shelter_id
      AND station.station_id = citi_bike.dim_bus_stop_station.has_station_id); 


