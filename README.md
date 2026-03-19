# 📦 Business Supply Database System 📦

This project implements a relational database for managing a business supply and logistics ecosystem, developed as part of CS4400: Introduction to Database Systems.

The system models real-world operations involving users, employees, businesses, delivery services, and inventory distribution through a structured SQL schema with enforced constraints and relationships.


# Features

### Relational Schema Design

- Fully normalized tables with primary keys, foreign keys, and constraints
- Enforces data integrity using `CHECK`, `UNIQUE`, and referential constraints

### User & Employee Management

- Base `user` entity extended into: `employee`, `owner`, `driver`, `worker`

### Business & Services

- Businesses tied to physical locations
- Delivery services managed by workers
- Investment tracking via `fund`

### Logistics & Fleet Management

- Vans assigned to services and drivers
- Fuel, capacity, and sales tracking
- Parking locations and movement modeling

### Inventory System

- Products tracked via barcodes
- Inventory stored in vans (`contain` table)
- Pricing and quantity management

# Database Schema Overview

### Key entities include:

- Users & Roles: `user`, `employee`, `driver`, `worker`, `owner`
- Business Layer: `business`, `service`, `fund`
- Logistics: `van`, `work_for`
- Inventory: `product`, `contain`
- Geography: `location`

## Relationships

- Employees inherit from users
- Drivers and workers are specialized employee roles
- Services operate at locations and are managed by workers
- Vans belong to services and may be assigned drivers
- Products are distributed via vans
- Owners invest in businesses
