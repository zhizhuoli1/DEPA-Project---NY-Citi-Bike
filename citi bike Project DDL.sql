SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
#drop schema if exists citi_bike;
-- -----------------------------------------------------
-- Schema citi_bike
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema citi_bike
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `citi_bike` DEFAULT CHARACTER SET utf8 ;
USE `citi_bike` ;

-- -----------------------------------------------------
-- Table `citi_bike`.`dim_date`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `citi_bike`.`dim_date` (
  `date_value` DATE NOT NULL COMMENT 'date value that was formatted by dd/mm/yyyy.',
  `day_name` VARCHAR(45) NOT NULL COMMENT 'Weekday\'s name From Monday to Sunday.',
  `week in year` TINYINT NOT NULL COMMENT 'The numbers of week that the date represtented in its year.',
  `week in month` TINYINT NOT NULL COMMENT 'The numbers of week that the date represtented in its month.',
  `month number` TINYINT NOT NULL COMMENT 'Month number of its year from 1-12.',
  `month name` VARCHAR(45) NOT NULL COMMENT 'string month name of its month number .',
  `year` SMALLINT(4) NOT NULL COMMENT 'year number in 20xx format.',
  `quarter number` TINYINT(3) NOT NULL COMMENT 'the quarter number that the date represtented in its year.',
  `holiday` BINARY NOT NULL COMMENT 'Binary number (1,0) that represent if the date is holiday or not 1 for yes 0 for no.' ,
  PRIMARY KEY (`date_value`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `citi_bike`.`dim_station`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `citi_bike`.`dim_station` (
  `station_id` INT NOT NULL COMMENT 'ID that represented each citibike station.' ,
  `station_name` VARCHAR(45) NOT NULL COMMENT 'station name of citibike station located always choose the first street if station located in intersection',
  `Longitude` FLOAT NOT NULL COMMENT 'Lontitue index of the citibike station\'s locaiton cordinate.',
  `Latitude` FLOAT NOT NULL COMMENT 'Lat index of the citibike station\'s locaiton cordinate.',
  PRIMARY KEY (`station_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `citi_bike`.`dim_bus_stop`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `citi_bike`.`dim_bus_stop` (
  `shelter_id` VARCHAR(45) NOT NULL COMMENT 'Unique ID that represent each bus shelter' ,
  `county_id` INT NOT NULL COMMENT 'Unique ID that represent each country.',
  `county_Name` VARCHAR(45) NOT NULL COMMENT 'County area name that show where the busstop located in NYC',
  `Latitude` FLOAT NOT NULL COMMENT 'Latitude number of busstop\'s location cordinate (comma removed)',
  `Longtitude` FLOAT NOT NULL COMMENT 'Longtitude number of busstop\'s location cordinate (comma removed)',
  `Street_Name` TEXT NOT NULL COMMENT 'the street name of the location where the busstop located in' ,
  PRIMARY KEY (`shelter_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `citi_bike`.`dim_bus_stop_station`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `citi_bike`.`dim_bus_stop_station` (
  `has_station_id` INT NOT NULL COMMENT 'Int that represent if bike station has its unique statiion id .'  ,
  `has_shelter_id` VARCHAR(45) NOT NULL COMMENT 'Int that represent if bus station has its unique statiion id .',
  `Distance Between` FLOAT NULL DEFAULT NULL COMMENT 'The linear distance between busstop station and citibike station calcuated by each station\'s cordinate.' ,
  INDEX `fk_station_idx` (`has_station_id` ASC) VISIBLE,
  INDEX `fk_bus_stop_idx` (`has_shelter_id`) VISIBLE,
  PRIMARY KEY (`has_station_id`,`has_shelter_id`),
  CONSTRAINT `fk_bus_stop_shelter_id`
    FOREIGN KEY (`has_shelter_id`)
    REFERENCES `citi_bike`.`dim_bus_stop` (`shelter_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_station_id`
    FOREIGN KEY (`has_station_id`)
    REFERENCES `citi_bike`.`dim_station` (`station_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `citi_bike`.`fact_Trip`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `citi_bike`.`fact_Trip` (
  `trip_id` INT NOT NULL COMMENT 'unique trip id which represetented each trip.',
  `trip_duration` INT NOT NULL COMMENT 'the duraiton of trip in seconds.', 
  `usetype` VARCHAR(45) NOT NULL COMMENT 'customer type either subscriber or non subscriber.',
  `user age` VARCHAR(45) NOT NULL COMMENT 'age of user.',
  `user gender` VARCHAR(45) NOT NULL COMMENT '0-undefine, 1 male, 2 female.',
  `trip_date` DATE NOT NULL ,
  `start_station_id` INT NOT NULL cOMMENT 'starting station id when user rent the bike.',
  `end_station_id` INT NOT NULL COMMENT 'end station id when user rent the bike.',
  `trip_distance` FLOAT NOT NULL COMMENT 'the linear distance betweeen staarting and ending station.',
  PRIMARY KEY (`trip_id`),
  INDEX `fk_Fact_Trip_dim_date_idx` (`trip_date` ASC) VISIBLE,
  INDEX `fk_Fact_Trip_dim_station_idx` (`start_station_id` ASC) VISIBLE,
  INDEX `fk_Fact_Trip_dim_station_idx2` (`end_station_id` ASC) VISIBLE,
  CONSTRAINT `fk_Fact_Trip_dim_date`
    FOREIGN KEY (`trip_date`)
    REFERENCES `citi_bike`.`dim_date` (`date_value`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Fact_Trip_dim_station`
    FOREIGN KEY (`start_station_id`)
    REFERENCES `citi_bike`.`dim_station` (`station_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Fact_Trip_dim_station2`
    FOREIGN KEY (`end_station_id`)
    REFERENCES `citi_bike`.`dim_station` (`station_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `citi_bike`.`fact_covid`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `citi_bike`.`fact_covid` (
  `covid_id` VARCHAR(45) NOT NULL COMMENT 'id that represent each date value during covid pandemic。',
  `date_value` DATE NOT NULL  ,
  `case_count` INT NOT NULL COMMENT 'total positive case that counted by each day In NYC.' ,
  `death_count` INT NOT NULL COMMENT 'total death case that counted by each day in NYC .',
  `hospitalized` INT NOT NULL COMMENT 'total hospitalzied count for this day IN nyc.',
  INDEX `fk_dim_Covid_dim_date_idx` (`date_value` ASC) VISIBLE,
  PRIMARY KEY (`covid_id`),
  CONSTRAINT `fk_dim_Covid_dim_date`
    FOREIGN KEY (`date_value`)
    REFERENCES `citi_bike`.`dim_date` (`date_value`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `citi_bike`.`fact_weather`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `citi_bike`.`fact_weather` (
  `weather_id` INT NOT NULL,
  `dim_date_date_value` DATE NOT NULL  COMMENT 'date value from dim_date table',
  `temp_average` INT NOT NULL COMMENT 'the avg temp of this day.' ,
  `temp_high` INT NOT NULL COMMENT 'the highest tep recorded this day .',
  `temp_low` INT NOT NULL COMMENT 'the lowest tep recorded this day .',
  `humid_average` INT NOT NULL COMMENT 'the avg humidity recorded this day .',
  `humid_low` INT NOT NULL COMMENT 'the lowest humidity recorded this day .' ,
  `humid_high` INT NOT NULL COMMENT 'the highest humidity recorded this day .',
  `wind_average` INT NOT NULL COMMENT 'the avg windspeed recorded in this day.',
  `wind_low` INT NOT NULL COMMENT 'the lowest number of windspeed recroded in this day.',
  `wind_high` INT NOT NULL cOMMENT 'the highest number of windspeed recroded in this day.',
  INDEX `fk_Weather_dim_date_idx` (`dim_date_date_value` ASC) VISIBLE,
  PRIMARY KEY (`weather_id`),
  CONSTRAINT `fk_Weather_dim_date`
    FOREIGN KEY (`dim_date_date_value`)
    REFERENCES `citi_bike`.`dim_date` (`date_value`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


