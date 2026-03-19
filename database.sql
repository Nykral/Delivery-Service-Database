-- CS4400: Introduction to Database Systems (Fall 2024)
-- Phase II: Create Table & Insert Statements [v0] Monday, September 15, 2024 @ 17:00 EST

-- Team 76
-- Anson Goo (agoo3)
-- Thanh Ngo (tngo70)
-- Tony Kang (tkang67)

-- Directions:
-- Please follow all instructions for Phase II as listed on Canvas.
-- Fill in the team number and names and GT usernames for all members above.
-- Create Table statements must be manually written, not taken from an SQL Dump file.
-- This file must run without error for credit.

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'business_supply';
drop database if exists business_supply;
create database if not exists business_supply;
use business_supply;

-- Define the database structures
/* You must enter your tables definitions, along with your primary, unique and foreign key
declarations, and data insertion statements here.  You may sequence them in any order that
works for you.  When executed, your statements must create a functional database that contains
all of the data, and supports as many of the constraints as reasonably possible. */

DROP DATABASE IF EXISTS business_supply;
CREATE DATABASE IF NOT EXISTS business_supply;
USE business_supply;

DROP TABLE IF EXISTS user;
CREATE TABLE user (
	username VARCHAR(40) NOT NULL,
	first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL,
	address VARCHAR(500) NOT NULL,
	birthdate DATE NOT NULL,
	PRIMARY KEY (username)
);

DROP TABLE IF EXISTS product;
CREATE TABLE product (
	barcode VARCHAR(40) NOT NULL,
	iname VARCHAR(100) NOT NULL,
	weight INT NOT NULL,
	PRIMARY KEY (barcode)
);

DROP TABLE IF EXISTS employee;
CREATE TABLE employee (
	username VARCHAR(40) NOT NULL,
	taxID CHAR(11) UNIQUE,
	hired DATE,
	salary DECIMAL(10, 2) DEFAULT 0.00,
	experience INT,
	PRIMARY KEY (username),
	FOREIGN KEY (username) REFERENCES user(username)
);

DROP TABLE IF EXISTS owner;
CREATE TABLE owner (
	username VARCHAR(40) NOT NULL,
	PRIMARY KEY (username),
	FOREIGN KEY (username) REFERENCES user(username)
);

DROP TABLE IF EXISTS driver;
CREATE TABLE driver (
	username VARCHAR(40) NOT NULL,
	licenseID VARCHAR(40) UNIQUE NOT NULL,
	license_type VARCHAR(100) NOT NULL,
	successful_trips INT NOT NULL,
	PRIMARY KEY (username),
	FOREIGN KEY (username) REFERENCES employee(username)
);

DROP TABLE IF EXISTS worker;
CREATE TABLE worker (
	username VARCHAR(40) NOT NULL,
	PRIMARY KEY (username),
	FOREIGN KEY (username) REFERENCES employee(username)
);

DROP TABLE IF EXISTS location;
CREATE TABLE location (
	label VARCHAR(100) NOT NULL,
	x_coord INT NOT NULL,
	y_coord INT NOT NULL,
	space INT,
	PRIMARY KEY (label)
);

DROP TABLE IF EXISTS business;
CREATE TABLE business (
	name VARCHAR(100) NOT NULL,
	label VARCHAR(40) NOT NULL,
	spent DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
	rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
	PRIMARY KEY (name),
	FOREIGN KEY(label) REFERENCES location(label)
);

DROP TABLE IF EXISTS service;
CREATE TABLE service (
	ID VARCHAR(40) NOT NULL,
	label VARCHAR(40) NOT NULL,
	name VARCHAR(100) NOT NULL,
	manager VARCHAR(40) NOT NULL,
	PRIMARY KEY (ID),
	FOREIGN KEY (label) REFERENCES location(label),
	FOREIGN KEY (manager) REFERENCES worker(username)
);

DROP TABLE IF EXISTS van;
CREATE TABLE van (
	tag VARCHAR(40) NOT NULL,
	serviceID VARCHAR(40) NOT NULL,
	capacity INT NOT NULL CHECK (capacity >= 0),
	sales DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
	fuel INT NOT NULL CHECK (fuel >= 0),
	driver VARCHAR(40),
	parkLocation VARCHAR(40) NOT NULL,
	PRIMARY KEY (tag, serviceID),
	FOREIGN KEY (serviceID) REFERENCES service(ID),
	FOREIGN KEY (driver) REFERENCES driver(username),
	FOREIGN KEY (parkLocation) REFERENCES location(label)
);

DROP TABLE IF EXISTS fund;
CREATE TABLE fund (
	owner VARCHAR (40) NOT NULL,
	business VARCHAR(100) NOT NULL,
	invested DECIMAL(10, 2),
	date DATE,
	PRIMARY KEY (owner, business),
	FOREIGN KEY (owner) REFERENCES owner(username),
	FOREIGN KEY (business) REFERENCES business(name)
);

DROP TABLE IF EXISTS work_for;
CREATE TABLE work_for (
	worker VARCHAR(40) NOT NULL,
	service VARCHAR(40) NOT NULL,
	PRIMARY KEY (worker, service),
	FOREIGN KEY (worker) REFERENCES worker(username),
	FOREIGN KEY (service) REFERENCES service(ID)
);

DROP TABLE IF EXISTS contain;
CREATE TABLE contain (
	product VARCHAR(40) NOT NULL,
	van_tag VARCHAR(40) NOT NULL,
	van_serviceID VARCHAR(40) NOT NULL,
	price DECIMAL(10, 2) CHECK (price >= 0),
	quantity INT CHECK (quantity >= 0),
	PRIMARY KEY(product, van_tag, van_serviceID),
	FOREIGN KEY (product) REFERENCES product(barcode),
	FOREIGN KEY (van_tag, van_serviceID) REFERENCES van(tag, serviceID)
);

INSERT INTO user VALUES ('agarcia7', 'Alejandro', 'Garcia', '710 Living Water Drive', '1966-10-29');
INSERT INTO user VALUES ('awilson5', 'Aaron', 'Wilson', '220 Peachtree Street', '1963-11-11');
INSERT INTO user VALUES ('bsummers4', 'Brie', 'Summers', '5105 Dragon Star Circle', '1976-02-09');
INSERT INTO user VALUES ('cjordan5', 'Clark', 'Jordan', '77 Infinite Stars Road', '1966-06-05');
INSERT INTO user VALUES ('ckann5', 'Carrot', 'Kann', '64 Knights Square Trail', '1972-09-01');
INSERT INTO user VALUES ('csoares8', 'Claire', 'Soares', '706 Living Stone Way', '1965-09-03');
INSERT INTO user VALUES ('echarles19', 'Ella', 'Charles', '22 Peachtree Street', '1974-05-06');
INSERT INTO user VALUES ('eross10', 'Erica', 'Ross', '22 Peachtree Street', '1975-04-02');
INSERT INTO user VALUES ('fprefontaine6', 'Ford', 'Prefontaine', '10 Hitch Hikers Lane', '1961-01-28');
INSERT INTO user VALUES ('hstark16', 'Harmon', 'Stark', '53 Tanker Top Lane', '1971-10-27');
INSERT INTO user VALUES ('jstone5', 'Jared', 'Stone', '101 Five Finger Way', '1961-01-06');
INSERT INTO user VALUES ('lrodriguez5', 'Lina', 'Rodriguez', '360 Corkscrew Circle', '1975-04-02');
INSERT INTO user VALUES ('mrobot1', 'Mister', 'Robot', '10 Autonomy Trace', '1988-11-02');
INSERT INTO user VALUES ('mrobot2', 'Mister', 'Robot', '10 Clone Me Circle', '1988-11-02');
INSERT INTO user VALUES ('rlopez6', 'Radish', 'Lopez', '8 Queens Route', '1999-09-03');
INSERT INTO user VALUES ('sprince6', 'Sarah', 'Prince', '22 Peachtree Street', '1968-06-15');
INSERT INTO user VALUES ('tmccall5', 'Trey', 'McCall', '360 Corkscrew Circle', '1973-03-19');

INSERT INTO product VALUES ('gc_4C6B9R', 'glass cleaner', '4');
INSERT INTO product VALUES ('pn_2D7Z6C', 'pens', '5');
INSERT INTO product VALUES ('sd_6J5S8H', 'screwdrivers', '4');
INSERT INTO product VALUES ('pt_16WEF6', 'paper towels', '6');
INSERT INTO product VALUES ('st_2D4E6L', 'shipping tape', '3');
INSERT INTO product VALUES ('hm_5E7L23M', 'hammer', '3');

INSERT INTO employee VALUES ('agarcia7', '999-99-9999', '2019-03-17', '41000', '24');
INSERT INTO employee VALUES ('awilson5', '111-11-1111', '2020-03-15', '46000', '9');
INSERT INTO employee VALUES ('bsummers4', '000-00-0000', '2018-12-06', '35000', '17');
INSERT INTO employee VALUES ('ckann5', '640-81-2357', '2019-08-03', '46000', '27');
INSERT INTO employee VALUES ('csoares8', '888-88-8888', '2019-02-25', '57000', '26');
INSERT INTO employee VALUES ('echarles19', '777-77-7777', '2021-01-02', '27000', '3');
INSERT INTO employee VALUES ('eross10', '444-44-4444', '2020-04-17', '61000', '10');
INSERT INTO employee VALUES ('fprefontaine6', '121-21-2121', '2020-04-19', '20000', '5');
INSERT INTO employee VALUES ('hstark16', '555-55-5555', '2018-07-23', '59000', '20');
INSERT INTO employee VALUES ('lrodriguez5', '222-22-2222', '2019-04-15', '58000', '20');
INSERT INTO employee VALUES ('mrobot1', '101-01-0101', '2015-05-27', '38000', '8');
INSERT INTO employee VALUES ('mrobot2', '010-10-1010', '2015-05-27', '38000', '8');
INSERT INTO employee VALUES ('rlopez6', '123-58-1321', '2017-02-05', '64000', '51');
INSERT INTO employee VALUES ('tmccall5', '333-33-3333', '2018-10-17', '33000', '29');

INSERT INTO owner VALUES ('cjordan5');
INSERT INTO owner VALUES ('jstone5');
INSERT INTO owner VALUES ('sprince6');

INSERT INTO driver VALUES ('agarcia7', '610623', 'CDL', '38');
INSERT INTO driver VALUES ('awilson5', '314159', 'commercial', '41');
INSERT INTO driver VALUES ('bsummers4', '411911', 'private', '35');
INSERT INTO driver VALUES ('csoares8', '343563', 'commercial', '7');
INSERT INTO driver VALUES ('fprefontaine6', '657483', 'private', '2');
INSERT INTO driver VALUES ('lrodriguez5', '287182', 'CDL', '67');
INSERT INTO driver VALUES ('mrobot1', '101010', 'CDL', '18');
INSERT INTO driver VALUES ('rlopez6', '235711', 'private', '58');

INSERT INTO worker VALUES ('ckann5');
INSERT INTO worker VALUES ('echarles19');
INSERT INTO worker VALUES ('eross10');
INSERT INTO worker VALUES ('hstark16');
INSERT INTO worker VALUES ('mrobot2');
INSERT INTO worker VALUES ('tmccall5');

INSERT INTO location VALUES ('southside', '1', '-16', '5');
INSERT INTO location VALUES ('buckhead', '7', '10', '8');
INSERT INTO location VALUES ('airport', '5', '-6', '15');
INSERT INTO location VALUES ('plaza', '-4', '-3', '10');
INSERT INTO location VALUES ('avalon', '2', '15', '12');
INSERT INTO location VALUES ('highlands', '2', '1', '7');
INSERT INTO location VALUES ('downtown', '-4', '-3', '10');
INSERT INTO location VALUES ('springs', '7', '10', '8');
INSERT INTO location VALUES ('mercedes', '-8', '5', Null);
INSERT INTO location VALUES ('midtown', '2', '1', '7');

INSERT INTO business VALUES ('Aircraft Electrical Svc', 'airport', '10', '5');
INSERT INTO business VALUES ('Homestead Insurance', 'downtown', '30', '5');
INSERT INTO business VALUES ('Jones and Associates', 'springs', '0', '3');
INSERT INTO business VALUES ('Prime Solutions', 'buckhead', '30', '4');
INSERT INTO business VALUES ('Innovative Ventures', 'avalon', '0', '4');
INSERT INTO business VALUES ('Blue Horizon Enterprises', 'mercedes', '10', '4');
INSERT INTO business VALUES ('Peak Performance Group', 'highlands', '20', '5');
INSERT INTO business VALUES ('Summit Strategies', 'southside', '0', '2');
INSERT INTO business VALUES ('Elevate Consulting', 'midtown', '30', '5');
INSERT INTO business VALUES ('Pinnacle Partners', 'plaza', '10', '4');

INSERT INTO service VALUES ('mbm', 'southside', 'Metro Business Movers', 'hstark16');
INSERT INTO service VALUES ('lcc', 'plaza', 'Local Commerce Couriers', 'eross10');
INSERT INTO service VALUES ('pbl', 'avalon', 'Pro Business Logistics', 'echarles19');

INSERT INTO van VALUES ('1', 'mbm', '6', '0', '100', 'fprefontaine6', 'southside');
INSERT INTO van VALUES ('5', 'mbm', '7', '100', '27', 'fprefontaine6', 'buckhead');
INSERT INTO van VALUES ('8', 'mbm', '8', '0', '100', 'bsummers4', 'southside');
INSERT INTO van VALUES ('11', 'mbm', '10', '0', '25', NULL, 'southside');
INSERT INTO van VALUES ('16', 'mbm', '5', '40', '17', 'fprefontaine6', 'southside');
INSERT INTO van VALUES ('1', 'lcc', '9', '0', '100', 'awilson5', 'airport');
INSERT INTO van VALUES ('2', 'lcc', '7', '0', '75', NULL, 'plaza');
INSERT INTO van VALUES ('3', 'pbl', '5', '50', '100', 'agarcia7', 'avalon');
INSERT INTO van VALUES ('7', 'pbl', '5', '100', '53', 'agarcia7', 'avalon');
INSERT INTO van VALUES ('8', 'pbl', '6', '0', '100', 'agarcia7', 'highlands');
INSERT INTO van VALUES ('11', 'pbl', '6', '0', '90', NULL, 'avalon');

INSERT INTO fund VALUES ('jstone5', 'Jones and Associates', '20', '2022-10-25');
INSERT INTO fund VALUES ('sprince6', 'Blue Horizon Enterprises', '10', '2022-03-06');
INSERT INTO fund VALUES ('jstone5', 'Peak Performance Group', '30', '2022-09-08');
INSERT INTO fund VALUES ('jstone5', 'Elevate Consulting', '5', '2022-07-25');

INSERT INTO work_for VALUES ('ckann5', 'lcc');
INSERT INTO work_for VALUES ('echarles19', 'pbl');
INSERT INTO work_for VALUES ('eross10', 'lcc');
INSERT INTO work_for VALUES ('hstark16', 'mbm');
INSERT INTO work_for VALUES ('tmccall5', 'mbm');
INSERT INTO work_for VALUES ('mrobot2', 'pbl');

INSERT INTO contain VALUES ('pn_2D7Z6C', '3', 'pbl', '28', '2');
INSERT INTO contain VALUES ('pn_2D7Z6C', '5', 'mbm', '30', '1');
INSERT INTO contain VALUES ('pt_16WEF6', '1', 'lcc', '20', '5');
INSERT INTO contain VALUES ('pt_16WEF6', '8', 'mbm', '18', '4');
INSERT INTO contain VALUES ('st_2D4E6L', '1', 'lcc', '23', '3');
INSERT INTO contain VALUES ('st_2D4E6L', '11', 'mbm', '19', '3');
INSERT INTO contain VALUES ('st_2D4E6L', '1', 'mbm', '27', '6');
INSERT INTO contain VALUES ('hm_5E7L23M', '2', 'lcc', '14', '7');
INSERT INTO contain VALUES ('hm_5E7L23M', '3', 'pbl', '15', '2');
INSERT INTO contain VALUES ('hm_5E7L23M', '5', 'mbm', '17', '4');




