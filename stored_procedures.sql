-- CS4400: Introduction to Database Systems (Fall 2024)
-- Project Phase III: Stored Procedures SHELL [v0] Monday, Oct 21, 2024
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

use business_supply;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [1] add_owner()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new owner.  A new owner must have a unique
username. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_owner;
delimiter //
create procedure add_owner (in ip_username varchar(40), in ip_first_name varchar(100),
	in ip_last_name varchar(100), in ip_address varchar(500), in ip_birthdate date)
sp_main: begin
     -- Ensure the new owner has a unique username in both users and business_owners
    if exists (select 1 from users where username = ip_username) then 
        leave sp_main; 
    end if;

    -- Insert the new owner into the users table
    insert into users (username, first_name, last_name, address, birthdate)
    values (ip_username, ip_first_name, ip_last_name, ip_address, ip_birthdate);

    -- Insert the owner into the business_owners table
    insert into business_owners (username)
    values (ip_username);
end //
delimiter ;

-- [2] add_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new employee without any designated driver or
worker roles.  A new employee must have a unique username and a unique tax identifier. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_employee;
delimiter //
create procedure add_employee (in ip_username varchar(40), in ip_first_name varchar(100),
	in ip_last_name varchar(100), in ip_address varchar(500), in ip_birthdate date,
    in ip_taxID varchar(40), in ip_hired date, in ip_employee_experience integer,
    in ip_salary integer)
sp_main: begin
    -- ensure new user has a unique username
    -- ensure new employee has a unique tax identifier
    
    # first check if the taxID is in the employee table - yes? exit
    if ip_taxID in (select taxID from employees) then leave sp_main; end if;
    
    # then check if the user exists in the employee table
    if ip_username in (select username from employees) then leave sp_main; end if;
    
    # at this point both the username and taxID is unique
    # if user not existent in current user database, then add them as a user first
    if ip_username not in (select username from employees) then 
        insert into users values (ip_username, ip_first_name, ip_last_name, ip_address, ip_birthdate);
	end if;

    # add them into employee table (they are guaranteed to be in the user table now)
    if ip_taxID not in (select taxID from employees) then 
		insert into employees values (ip_username, ip_taxID, ip_hired, ip_employee_experience, ip_salary);
	end if;
    
end //
delimiter ;

-- [3] add_driver_role()
-- -----------------------------------------------------------------------------
/* This stored procedure adds the driver role to an existing employee.  The
employee/new driver must have a unique license identifier. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_driver_role;
delimiter //
create procedure add_driver_role (in ip_username varchar(40), in ip_licenseID varchar(40),
	in ip_license_type varchar(40), in ip_driver_experience integer)
sp_main: begin
    -- ensure employee exists and is not a worker
    -- ensure new driver has a unique license identifier
    
    # check if employee exists, leave if not true
    if ip_username not in (select username from employees) then leave sp_main; end if;
    
    # check if license id is unique, leave if not true
    if ip_licenseID in (select licenseID from drivers) then leave sp_main; end if;
    
    insert into drivers values (ip_username, ip_licenseID, ip_license_type, ip_driver_experience);
    
end //
delimiter ;

-- [4] add_worker_role()
-- -----------------------------------------------------------------------------
/* This stored procedure adds the worker role to an existing employee. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_worker_role;
delimiter //
create procedure add_worker_role (in ip_username varchar(40))
sp_main: begin
    -- ensure employee exists and is not a driver
    
    # check if employee exists, leave if not true
    if ip_username not in (select username from employees) then leave sp_main; end if;
    
    # check if employee is a driver, leave if true
    if ip_username in (select username from drivers) then leave sp_main; end if;
    
    insert into workers values (ip_username);
    
    
end //
delimiter ;

-- [5] add_product()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new product.  A new product must have a
unique barcode. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_product;
delimiter //
create procedure add_product (in ip_barcode varchar(40), in ip_name varchar(100),
	in ip_weight integer)
sp_main: begin
	-- ensure new product doesn't already exist
    
    # leave if product exists
    if ip_barcode in (select barcode from products) then leave sp_main; end if;
    
    insert into products values (ip_barcode, ip_name, ip_weight);
    
end //
delimiter ;

-- [6] add_van()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new van.  A new van must be assigned 
to a valid delivery service and must have a unique tag.  Also, it must be driven
by a valid driver initially (i.e., driver works for the same service). And the van's starting
location will always be the delivery service's home base by default. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_van;
delimiter //
create procedure add_van (in ip_id varchar(40), in ip_tag integer, in ip_fuel integer,
	in ip_capacity integer, in ip_sales integer, in ip_driven_by varchar(40))
sp_main: begin
	-- ensure new van doesn't already exist
    -- ensure that the delivery service exists
    -- ensure that a valid driver will control the van
    
    # leave if van already exists
	if (ip_id, ip_tag) in (select id, tag from vans where id = ip_id and tag = ip_tag) then leave sp_main; end if;
    if (select count(*) from vans where id != ip_id and driven_by = ip_driven_by) > 0 then leave sp_main; end if;
    
    # leave if delivery services DOESN'T exist
    if ip_id not in (select id from delivery_services) then leave sp_main; end if;
    
    # leave if the driver is not a valid driver
    if ip_driven_by not in (select username from drivers) then leave sp_main; end if;
    
    insert into vans values (ip_id, ip_tag, ip_fuel, ip_capacity, ip_sales, ip_driven_by, (select home_base from delivery_services where id = ip_id));
    
end //
delimiter ;

-- [7] add_business()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new business.  A new business must have a
unique (long) name and must exist at a valid location, and have a valid rating.
And a resturant is initially "independent" (i.e., no owner), but will be assigned
an owner later for funding purposes. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_business;
delimiter //
create procedure add_business (in ip_long_name varchar(40), in ip_rating integer,
	in ip_spent integer, in ip_location varchar(40))
sp_main: begin
	-- ensure new business doesn't already exist
    -- ensure that the location is valid
    -- ensure that the rating is valid (i.e., between 1 and 5 inclusively)
    
    # check if business exists
    if ip_long_name in (select long_name from businesses) then leave sp_main; end if;
    
    # check if location is valid
    if ip_location not in (select label from locations) then leave sp_main; end if;
    
    # check if rating is valid
    if ip_rating not between 1 and 5 then leave sp_main; end if;
    
    insert into businesses values (ip_long_name, ip_rating, ip_spent, ip_location);
    
end //
delimiter ;

-- [8] add_service()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new delivery service.  A new service must have
a unique identifier, along with a valid home base and manager. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_service;
delimiter //
create procedure add_service (in ip_id varchar(40), in ip_long_name varchar(100),
	in ip_home_base varchar(40), in ip_manager varchar(40))
sp_main: begin
	-- ensure new delivery service doesn't already exist
    -- ensure that the home base location is valid
    -- ensure that the manager is valid
    
    # exit if service already exists
    if ip_id in (select id from delivery_services) then leave sp_main; end if;
    
	# check if home base location is valid (not null & exists in locations table)
    if ip_home_base is NULL or ip_home_base not in (select label from locations) then leave sp_main; end if;
	
    # now home base location is valid, check if manager is valid
    if ip_manager is NULL
		then insert into delivery_services(id, long_name, home_base) values (ip_id, ip_long_name, ip_home_base);
        elseif ip_manager not in (select username from workers) or ip_manager in (select manager from delivery_services)
			or ip_manager in (select username from drivers) or ip_manager in (select username from work_for)
				then leave sp_main;
    end if;
    
    insert into delivery_services values (ip_id, ip_long_name, ip_home_base, ip_manager);
    
end //
delimiter ;

-- [9] add_location()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new location that becomes a new valid van
destination.  A new location must have a unique combination of coordinates. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_location;
delimiter //
create procedure add_location (in ip_label varchar(40), in ip_x_coord integer,
	in ip_y_coord integer, in ip_space integer)
sp_main: begin
	-- Ensure the location label is unique
    if exists (select 1 from locations where label = ip_label) then 
        leave sp_main; 
    end if;

    -- Ensure the coordinate combination is unique
    if exists (select 1 from locations where x_coord = ip_x_coord and y_coord = ip_y_coord) then 
        leave sp_main; 
    end if;

    -- Insert the new location
    insert into locations (label, x_coord, y_coord, space)
    values (ip_label, ip_x_coord, ip_y_coord, ip_space);
end //
delimiter ;

-- [10] start_funding()
-- -----------------------------------------------------------------------------
/* This stored procedure opens a channel for a business owner to provide funds
to a business. The owner and business must be valid. */
-- -----------------------------------------------------------------------------
drop procedure if exists start_funding;
delimiter //
create procedure start_funding (in ip_owner varchar(40), in ip_amount integer, in ip_long_name varchar(40), in ip_fund_date date)
sp_main: begin
	-- Ensure the owner is valid
    if not exists (select 1 from business_owners where username = ip_owner) then 
        leave sp_main; 
    end if;

    -- Ensure the business is valid
    if not exists (select 1 from businesses where long_name = ip_long_name) then 
        leave sp_main; 
    end if;

    -- Insert the funding record
    insert into fund (username, invested, business, invested_date)
    values (ip_owner, ip_amount, ip_long_name, ip_fund_date);
end //
delimiter ;

-- [11] hire_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure hires a worker to work for a delivery service.
If a worker is actively serving as manager for a different service, then they are
not eligible to be hired.  Otherwise, the hiring is permitted. */
-- -----------------------------------------------------------------------------
drop procedure if exists hire_employee;
delimiter //
create procedure hire_employee (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	-- ensure that the employee hasn't already been hired by that service
	-- ensure that the employee and delivery service are valid
    -- ensure that the employee isn't a manager for another service
    
    # check if employee is already hired by that service
    if ip_username in (select username from work_for where id = ip_id) then leave sp_main; end if;
    
    if ip_username is NULL or ip_username not in (select username from employees) then leave sp_main; end if;
    if ip_id is NULL or ip_id not in (select id from delivery_services) then leave sp_main; end if;
    
    if ip_username in (select manager from delivery_services) then leave sp_main; end if;
    if ip_username in (select username from drivers) then leave sp_main; end if;
    
    insert into work_for values (ip_username, ip_id);
    
end //
delimiter ;

-- [12] fire_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure fires a worker who is currently working for a delivery
service.  The only restriction is that the employee must not be serving as a manager 
for the service. Otherwise, the firing is permitted. */
-- -----------------------------------------------------------------------------
drop procedure if exists fire_employee;
delimiter //
create procedure fire_employee (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	-- ensure that the employee is currently working for the service
    -- ensure that the employee isn't an active manager
    
    # leave if employee is NOT hired by the service
	if ip_username not in (select username from work_for where id = ip_id) then leave sp_main; end if;
    
    # leave if the employee IS an active manager
    if ip_username in (select manager from delivery_services) then leave sp_main; end if;
    
    delete from work_for where (work_for.username = ip_username and work_for.id = ip_id);
    
end //
delimiter ;

-- [13] manage_service()
-- -----------------------------------------------------------------------------
/* This stored procedure appoints a worker who is currently hired by a delivery
service as the new manager for that service.  The only restrictions is that
the worker must not be working for any other delivery service. Otherwise, the appointment 
to manager is permitted.  The current manager is simply replaced. */
-- -----------------------------------------------------------------------------
drop procedure if exists manage_service;
delimiter //
create procedure manage_service (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	-- Ensure the employee is currently working for the specified service
	if not exists (select 1 from work_for where username = ip_username and id = ip_id) then
		leave sp_main;
	end if;

	-- Ensure the employee isn't working for any other services
	if exists (select 1 from work_for where username = ip_username and id != ip_id) then
		leave sp_main;
	end if;

	-- Appoint the employee as the new manager by updating the delivery service record
	update delivery_services 
	set manager = ip_username 
	where id = ip_id;
end //
delimiter ;

-- [14] takeover_van()
-- -----------------------------------------------------------------------------
/* This stored procedure allows a valid driver to take control of a van owned by 
the same delivery service. The current controller of the van is simply relieved 
of those duties. */
-- -----------------------------------------------------------------------------
drop procedure if exists takeover_van;
delimiter //
create procedure takeover_van (in ip_username varchar(40), in ip_id varchar(40),
	in ip_tag integer)
sp_main: begin
    -- ensure that the employee is a valid driver
    if ip_username not in (select username from drivers) then leave sp_main; end if;
    -- ensure that the driver is not driving for another service
    if ip_username in (select driven_by from vans where id != ip_id) then leave sp_main; end if;
	-- ensure that the selected van is owned by the same service
    if ip_id not in (select id from vans where id = ip_id and tag = ip_tag) then leave sp_main; end if;
    
    update vans set driven_by = ip_username where id = ip_id and tag = ip_tag;
end //
delimiter ;

-- [15] load_van()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to add some quantity of fixed-size packages of
a specific product to a van's payload so that we can sell them for some
specific price to other businesses.  The van can only be loaded if it's located
at its delivery service's home base, and the van must have enough capacity to
carry the increased number of items.

The change/delta quantity value must be positive, and must be added to the quantity
of the product already loaded onto the van as applicable.  And if the product
already exists on the van, then the existing price must not be changed. */
-- -----------------------------------------------------------------------------
drop procedure if exists load_van;
delimiter //
create procedure load_van (in ip_id varchar(40), in ip_tag integer, in ip_barcode varchar(40),
	in ip_more_packages integer, in ip_price integer)
sp_main: begin
	-- ensure that the van being loaded is owned by the service
	-- ensure that the product is valid
    -- ensure that the van is located at the service home base
	-- ensure that the quantity of new packages is greater than zero
	-- ensure that the van has sufficient capacity to carry the new packages
    -- add more of the product to the van
    
    # check if van exists, leave if it doesnt
    if (ip_id, ip_tag) not in (select id, tag from vans where id = ip_id and tag = ip_tag) then leave sp_main; end if;
    
    # check if the van is at homebase
    if (select count(*) from vans v join delivery_services d on v.id = d.id 
        where v.id = ip_id and v.tag = ip_tag and d.home_base = v.located_at) = 0 then 
        leave sp_main; 
    end if;
        
	# check if the product is valid
    if ip_barcode not in (select barcode from products) then leave sp_main; end if;
    
    # check if the quanity is non-zero
    if ip_more_packages <= 0 then leave sp_main; end if;
    
    # check if the van has enough space
    if ip_more_packages > (select v.capacity - sum(c.quantity) from contain as c 
			natural join vans as v group by c.id, c.tag having (c.id = ip_id and c.tag = ip_tag)
            ) then leave sp_main; end if;
    -- if ip_more_packages > (select capacity from vans)
    
    if (ip_id, ip_tag, ip_barcode) in (select id, tag, barcode from contain where id = ip_id and tag = ip_tag and barcode = ip_barcode)
		then update contain set quantity = quantity + ip_more_packages;
        else insert into contain values (ip_id, ip_tag, ip_barcode, ip_more_packages, ip_price);
	end if;
    
    
end //
delimiter ;

-- [16] refuel_van()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to add more fuel to a van. The van can only
be refueled if it's located at the delivery service's home base. */
-- -----------------------------------------------------------------------------
drop procedure if exists refuel_van;
delimiter //
create procedure refuel_van (in ip_id varchar(40), in ip_tag integer, in ip_more_fuel integer)
sp_main: begin
	-- ensure that the van being switched is valid and owned by the service
    -- ensure that the van is located at the service home base
    
	# check if van exists, leave if it doesnt
    if (ip_id, ip_tag) not in (select id, tag from vans where id = ip_id and tag = ip_tag) then leave sp_main; end if;
    
    # check if the van is at homebase
    if (select count(*) from vans v join delivery_services d on v.id = d.id 
        where v.id = ip_id and v.tag = ip_tag and d.home_base = v.located_at) = 0 then 
        leave sp_main; 
    end if;
        
	update vans set fuel = fuel + ip_more_fuel where id = ip_id and tag = ip_tag;
    
end //
delimiter ;

-- [17] drive_van()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to move a single van to a new
location (i.e., destination). This will also update the respective driver's 
experience and van's fuel. The main constraints on the van(s) being able to 
move to a new  location are fuel and space.  A van can only move to a destination
if it has enough fuel to reach the destination and still move from the destination
back to home base.  And a van can only move to a destination if there's enough
space remaining at the destination. */
-- -----------------------------------------------------------------------------
drop function if exists fuel_required;
delimiter //
create function fuel_required (ip_departure varchar(40), ip_arrival varchar(40)) returns integer deterministic
begin
	if (ip_departure = ip_arrival) then return 0;
    else 
	return (select CEIL(sqrt(power(arrival.x_coord - departure.x_coord, 2) + power(arrival.y_coord - departure.y_coord, 2))) as fuel
			from (select x_coord, y_coord from locations where label = ip_departure) as departure,
				 (select x_coord, y_coord from locations where label = ip_arrival) as arrival);
    end if;
end //
delimiter ;

drop procedure if exists drive_van;
delimiter //
create procedure drive_van (in ip_id varchar(40), in ip_tag integer, in ip_destination varchar(40))
sp_main: begin
    # declare required variables
    declare roundtrip_required_fuel int;
    declare required_fuel int;
    
	# check if van exists, leave if it doesnt
    if (ip_id, ip_tag) not in (select id, tag from vans where id = ip_id and tag = ip_tag) then leave sp_main; end if;
    
    # check if destination is valid
    if ip_destination not in (select label from locations) then leave sp_main; end if;
    
    # check if van is already at location
    if ip_destination in (select located_at from vans where id = ip_id and tag = ip_tag) then leave sp_main; end if;
    
    # check if van has enough fuel to reach the destination and then homebase
    # get the required fuel for the trip
    
    set roundtrip_required_fuel = fuel_required((select located_at from vans where id = ip_id and tag = ip_tag), ip_destination) +
                        fuel_required(ip_destination, (select home_base from delivery_services where id = ip_id));
	set required_fuel = fuel_required((select located_at from vans where id = ip_id and tag = ip_tag), ip_destination);
    
    if (select fuel from vans where id = ip_id and tag = ip_tag) < roundtrip_required_fuel then leave sp_main; end if;
	
    # check if destination has enough space for the van
	if (select space from locations where label = ip_destination) <= 0 then leave sp_main; end if;
    
    -- Update the van's location and reduce fuel
    update vans set located_at = ip_destination where id = ip_id and tag = ip_tag;
    update vans set fuel = fuel - required_fuel where id = ip_id and tag = ip_tag;

    -- Increment driver's experience
    update drivers 
    set successful_trips = successful_trips + 1 
    where username = (select driven_by from vans where id = ip_id and tag = ip_tag);

end //
delimiter ;

-- [18] purchase_product()
-- -----------------------------------------------------------------------------
/* This stored procedure allows a business to purchase products from a van
at its current location.  The van must have the desired quantity of the product
being purchased.  And the business must have enough money to purchase the
products.  If the transaction is otherwise valid, then the van and business
information must be changed appropriately.  Finally, we need to ensure that all
quantities in the payload table (post transaction) are greater than zero. */
-- -----------------------------------------------------------------------------
drop procedure if exists purchase_product;
delimiter //
create procedure purchase_product (in ip_long_name varchar(40), in ip_id varchar(40),
    in ip_tag integer, in ip_barcode varchar(40), in ip_quantity integer)
sp_main: begin
    -- Declare variables
    declare total_cost int default 0;
    declare product_price int default 0;
    declare current_quantity int default 0;

    # ensure that the van is valid
    if (ip_id, ip_tag) not in (select id, tag from vans where id = ip_id and tag = ip_tag) then leave sp_main; end if;
    
    # ensure the business exists and is at the van’s location
    if not exists (
		select 1 from businesses b, vans v where b.long_name = ip_long_name and b.location = v.located_at 
        and v.id = ip_id and v.tag = ip_tag
        ) then leave sp_main;
	end if;

    -- Ensure the van has enough of the requested product and get its price
    select quantity, price into current_quantity, product_price from contain where id = ip_id and tag = ip_tag and barcode = ip_barcode;

    if ip_quantity > current_quantity then leave sp_main; end if;

    -- Calculate total cost
    set total_cost = ip_quantity * product_price;
    
    -- Update the van’s payload quantity and prevent quantity from becoming negative
    update contain set quantity = quantity - ip_quantity 
    where id = ip_id and tag = ip_tag and barcode = ip_barcode and quantity >= ip_quantity;
    
    # delete the row if quantity becomes zero after the update
    delete from contain where id = ip_id and tag = ip_tag and barcode = ip_barcode and quantity = 0;
    
    -- Update business's total spent, using COALESCE to handle NULL values
    update businesses set spent = COALESCE(spent, 0) + total_cost where long_name = ip_long_name;

    -- Increase the van's revenue (assuming a `sales` field in the `vans` table)
    update vans set sales = COALESCE(sales, 0) + total_cost where id = ip_id and tag = ip_tag;
    
end //
delimiter ;

-- [19] remove_product()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a product from the system.  The removal can
occur if, and only if, the product is not being carried by any vans. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_product;
delimiter //
create procedure remove_product (in ip_barcode varchar(40))
sp_main: begin
	-- ensure that the product exists
    -- ensure that the product is not being carried by any vans
    
    # check if product exists, leave if it doesnt
    if ip_barcode not in (select barcode from products) then leave sp_main; end if;
    
    # check if product is carried by van
    if ip_barcode in (select barcode from contain) then leave sp_main; end if;
    
    delete from products where ip_barcode = barcode;
    
end //
delimiter ;

-- [20] remove_van()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a van from the system.  The removal can
occur if, and only if, the van is not carrying any products.*/
-- -----------------------------------------------------------------------------
drop procedure if exists remove_van;
delimiter //
create procedure remove_van (in ip_id varchar(40), in ip_tag integer)
sp_main: begin
	-- ensure that the van exists
    -- ensure that the van is not carrying any products
    
    # check if van exists, leave if it doesnt
    if (ip_id, ip_tag) not in (select id, tag from vans where id = ip_id and tag = ip_tag) then leave sp_main; end if;
    
    # check if the van is in the contain table
    if (ip_id, ip_tag) in (select id, tag from contain where id = ip_id and tag = ip_tag) then leave sp_main; end if;
    
    delete from vans where id = ip_id and tag = ip_tag;
    
end //
delimiter ;

-- [21] remove_driver_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a driver from the system.  The removal can
occur if, and only if, the driver is not controlling any vans.  
The driver's information must be completely removed from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_driver_role;
delimiter //
create procedure remove_driver_role (in ip_username varchar(40))
sp_main: begin
	-- ensure that the driver exists
    -- ensure that the driver is not controlling any vans
    -- remove all remaining information
    
    # check if the employee is the driver
    if ip_username not in (select username from drivers) then leave sp_main; end if;
    
    # check if driver is controlling vans, leave if true
    if ip_username in (select driven_by from vans) then leave sp_main; end if;
    
    delete from drivers where ip_username = drivers.username;
    delete from employees where ip_username = employees.username;
    delete from users where  ip_username = users.username;
    
    
end //
delimiter ;

-- [22] display_owner_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of an owner.
For each owner, it includes the owner's information, along with the number of
businesses for which they provide funds and the number of different places where
those businesses are located.  It also includes the highest and lowest ratings
for each of those businesses, as well as the total amount of debt based on the
monies spent purchasing products by all of those businesses. And if an owner
doesn't fund any businesses then display zeros for the highs, lows and debt. */
-- -----------------------------------------------------------------------------
create or replace view display_owner_view as
select o.username,u.first_name, u.last_name, u.address,
    coalesce(count(distinct f.business),0) as num_businesses, coalesce(count(distinct b.location), 0) as num_places,
    coalesce(max(b.rating), 0) as highs, coalesce(min(b.rating), 0) as lows, coalesce(sum(b.spent),0) as debt
	from business_owners o join users u on o.username = u.username left join fund f on o.username = f.username 
    left join businesses b on f.business = b.long_name
group by 
    o.username, u.first_name, u.last_name, u.address, u.birthdate;
    
-- [23] display_employee_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of an employee.
For each employee, it includes the username, tax identifier, hiring date and
experience level, along with the license identifer and drivering experience (if
applicable), and a 'yes' or 'no' depending on the manager status of the employee. */
-- -----------------------------------------------------------------------------
create or replace view display_employee_view as
select e.username, e.taxID, e.salary, e.hired, e.experience AS employee_experience, 
    coalesce(d.licenseID, 'n/a'), coalesce(d.successful_trips, 'n/a') AS driving_experience,
    case 
        when e.username in (select manager from delivery_services) then 'yes' 
        else 'no' 
    end as manager_status
from employees as e
left join drivers as d on e.username = d.username;

-- [24] display_driver_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a driver.
For each driver, it includes the username, licenseID and drivering experience, along
with the number of vans that they are controlling. */
-- -----------------------------------------------------------------------------
create or replace view display_driver_view as
select d.username,d.licenseID, d.successful_trips as successful_trips, count(v.id) as num_vans
	from drivers d left join vans v on d.username = v.driven_by group by  d.username, d.licenseID, d.successful_trips;

-- [25] display_location_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a location.
For each location, it includes the label, x- and y- coordinates, along with the
name of the business or service at that location, the number of vans as well as 
the identifiers of the vans at the location (sorted by the tag), and both the 
total and remaining capacity at the location. */
-- -----------------------------------------------------------------------------
create or replace view display_location_view as
select l.label,  COALESCE(b.long_name, d.long_name) as long_name, l.x_coord, l.y_coord, l.space,
    count(v.id) as num_vans,
    group_concat(v.id, v.tag order by v.tag) as van_ids,
    (l.space - count(v.id)) as remaining_capacity
	from locations l
		left join businesses b on l.label = b.location
		left join delivery_services d on l.label = d.home_base
		join vans v on l.label = v.located_at
	group by l.label, long_name, l.x_coord, l.y_coord, l.space;

-- [26] display_product_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of the products.
For each product that is being carried by at least one van, it includes a list of
the various locations where it can be purchased, along with the total number of packages
that can be purchased and the lowest and highest prices at which the product is being
sold at that location. */
-- -----------------------------------------------------------------------------
create or replace view display_product_view as
select p.iname as product_name, l.label as location, 
	sum(c.quantity) as amount_available, min(c.price) as low_price,max(c.price) as high_price
	from products p 
		join contain c on p.barcode = c.barcode
		join vans v on c.id = v.id and c.tag = v.tag
		join locations l on v.located_at = l.label
	group by p.iname, l.label, l.x_coord, l.y_coord
	order by product_name;

-- [27] display_service_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a delivery
service.  It includes the identifier, name, home base location and manager for the
service, along with the total sales from the vans.  It must also include the number
of unique products along with the total cost and weight of those products being
carried by the vans. */
-- -----------------------------------------------------------------------------
create or replace view display_service_view as
select * from delivery_services as d 
natural join (select id, sum(sales) as revenue from vans group by id) as rev

natural join

(select v.id, count(distinct(c.barcode)) as products_carried, sum(c.quantity * c.price) as cost_carried, sum(p.weight * c.quantity) as weight_carried 
from (contain as c natural join vans as v) join products as p on c.barcode = p.barcode
group by v.id) as second_half;

