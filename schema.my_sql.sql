drop database seerema;
create database seerema;

use seerema;

create table module (
	id int,
	name varchar(25) not null unique,
	entity_name varchar(25) not null unique,

	primary key(id)
) ENGINE = InnoDB;

create table user (
	id int not null auto_increment,
	name varchar(191) not null unique,
	created timestamp not null default CURRENT_TIMESTAMP,

	primary key(id)
) ENGINE = InnoDB;

create table bfile_category (
	id int not null auto_increment,
	name varchar(25) not null unique,
	is_system char(1) default 'N',
	module_id int not null,

	unique index unq_module_fcat (name, module_id),

	foreign key (module_id)
        	references module(id) on delete restrict,

	primary key(id)
) ENGINE = InnoDB;

create table binary_file (
	id int not null auto_increment,

	file_name varchar(50) not null,
	file_type varchar(25) not null,
	file_size int not null,
	bfile_category_id int not null,
	description varchar(255),

	unique index unq_binary_file (file_name, bfile_category_id),

	foreign key (bfile_category_id)
        	references bfile_category(id) on delete restrict,

	primary key(id)
) ENGINE = InnoDB;

create table field_category(
	id int not null auto_increment,
	name varchar(50) not null,
	is_system char(1) default 'N',
	module_id int not null,

	unique index unq_module_fcat (module_id, name),

	foreign key (module_id)
        	references module(id) on delete restrict,

	primary key(id)
) ENGINE = InnoDB;

create table field(
	id int not null auto_increment,
	name varchar(50) not null,
	field_category_id int not null,
	is_system char(1) default 'N',

	unique index unq_field_name (field_category_id, name),

	foreign key (field_category_id)
        	references field_category(id) on delete restrict,

	primary key(id)
) ENGINE = InnoDB;

create table entity(
	id int not null auto_increment,
	field_cat_id int not null,
	name varchar(191) not null,
	module_id int not null,
	parent_id int,

	unique index unq_entity_name (module_id, name),

	foreign key (module_id)
        	references module(id) on delete restrict,
	foreign key (field_cat_id)
        	references field_category(id) on delete restrict,
	foreign key (parent_id)
        	references entity(id) on delete restrict,

	primary key(id)
) ENGINE = InnoDB;

create table entity_field(
	id int not null auto_increment,
	field_id int not null,
	entity_id int not null,
	value varchar(255) not null,

	unique index unq_entity_field (field_id, entity_id),

	foreign key (field_id)
        	references field(id) on delete restrict,
	foreign key (entity_id)
        	references entity(id) on delete cascade,

	primary key(id)
) ENGINE = InnoDB;

create table status (
	id int auto_increment,
	name varchar(25) not null,
	module_id int not null,
	is_system char(1) default 'N',

	unique index unq_status_name (module_id, name),

	foreign key (module_id)
        	references module(id) on delete restrict,

	primary key(id)
) ENGINE = InnoDB;

create table entity_status_history (
	id int auto_increment,
	status_id int not null,
	entity_id int not null,
	user_id int not null,
	created timestamp not null default CURRENT_TIMESTAMP,

	foreign key (status_id)
        	references status(id) on delete restrict,
	foreign key (entity_id)
        	references entity(id) on delete cascade,
	foreign key (user_id)
        	references user(id) on delete restrict,

	primary key(id)
) ENGINE = InnoDB;

create table entity_user_history (
	id int auto_increment,
	entity_id int not null,
	owner_id int not null,
	user_id int not null,
	created timestamp not null default CURRENT_TIMESTAMP,

	foreign key (entity_id)
        	references entity(id) on delete cascade,
	foreign key (owner_id)
        	references user(id) on delete restrict,
	foreign key (user_id)
        	references user(id) on delete restrict,

	primary key(id)
) ENGINE = InnoDB;

create table entity_ex(
	id int not null,
	entity_id int not null,
	status_id int not null,
	user_id int not null,

	foreign key (status_id)
        	references status(id) on delete restrict,
	foreign key (entity_id)
        	references entity(id) on delete restrict,
	foreign key (user_id)
        	references user(id) on delete restrict,

	primary key(id)
) ENGINE = InnoDB;

-- CATALOG
create table country (
	id int auto_increment,
	name varchar(100) not null unique,
	region_name varchar(25) not null,
	postal_name varchar(25) not null,
	region_field varchar(25) not null default 'name',
	addr_formatter varchar(25) not null default 'get_us_address',

	primary key(id)
) ENGINE = InnoDB;

create table region(
	id int not null auto_increment,
	name varchar(50) not null,
	short_name varchar(25),
	country_id int not null,

	unique index unq_sandbox_coord (country_id, name),

	foreign key (country_id)
        references country(id) on delete restrict,

	primary key(id)
) ENGINE = InnoDB;

create table city(
	id int not null auto_increment,
	name varchar(50) not null,
	region_id int not null,

	unique index unq_sandbox_coord (region_id, name),

	foreign key (region_id)
        references region(id) on delete restrict,

	primary key(id)
) ENGINE = InnoDB;

create table address(
	id int not null auto_increment,
	line_1 varchar(191) not null,
	line_2 varchar(255),
	zip varchar(25) not null,
	city_id int not null,

	unique index unq_sandbox_coord (line_1, city_id),

	foreign key (city_id)
        references city(id) on delete restrict,

	primary key(id)
) ENGINE = InnoDB;

create table comm_media(
	id int not null auto_increment,
	name varchar(25) not null unique,
	is_system char(1) default 'N',

	primary key(id)
) ENGINE = InnoDB;

-- CRM

create table cust_comm_history(
	id int auto_increment,
	entity_id int not null,
	user_id int not null,
	comm_media_id int not null,
	body text not null,
	created timestamp not null default CURRENT_TIMESTAMP,

	foreign key (entity_id)
        	references entity_ex(id) on delete cascade,
	foreign key (user_id)
        	references user(id) on delete restrict,
	foreign key (comm_media_id)
        	references comm_media(id) on delete restrict,

	primary key(id)
) ENGINE = InnoDB;

-- CATALOG
insert into module(id, name, entity_name) values(0, 'catalog', 'business_unit');

insert into country(name, region_name, postal_name, region_field, addr_formatter)
	values('Canada', 'LL_PROVINCE', 'LL_POSTAL_CODE', 'short_name', 'get_us_address');
insert into country(name, region_name, postal_name, region_field, addr_formatter)
	values('USA', 'LL_STATE', 'LL_ZIP_CODE', 'short_name', 'get_us_address');

-- Canada Provinces
insert into region(name, short_name, country_id) values('Alberta', 'AB', 1);
insert into region(name, short_name, country_id) values('British Columbia', 'BC', 1);
insert into region(name, short_name, country_id) values('New Brunswick', 'NB', 1);
insert into region(name, short_name, country_id) values('Newfoundland and Labrador', 'NL', 1);
insert into region(name, short_name, country_id) values('Nova Scotia', 'NS', 1);
insert into region(name, short_name, country_id) values('Northwest Territories', 'NT', 1);
insert into region(name, short_name, country_id) values('Nunavut', 'NU', 1);
insert into region(name, short_name, country_id) values('Manitoba', 'MB', 1);
insert into region(name, short_name, country_id) values('Ontario', 'ON', 1);
insert into region(name, short_name, country_id) values('Prince Edward Island', 'PE', 1);
insert into region(name, short_name, country_id) values('Quebec', 'QC', 1);
insert into region(name, short_name, country_id) values('Saskatchewan', 'SK', 1);
insert into region(name, short_name, country_id) values('Yukon', 'YT', 1);

-- US States
insert into region(name, short_name, country_id) values('Alabama', 'AL', 2);
insert into region(name, short_name, country_id) values('Alaska',  'AK', 2);
insert into region(name, short_name, country_id) values('Arizona', 'AZ', 2);
insert into region(name, short_name, country_id) values('Arkansas', 'AR', 2);
insert into region(name, short_name, country_id) values('California', 'CA', 2);
insert into region(name, short_name, country_id) values('Colorado', 'CO', 2);
insert into region(name, short_name, country_id) values('Connecticut', 'CT', 2);
insert into region(name, short_name, country_id) values('District of Columbia', 'DC', 2);
insert into region(name, short_name, country_id) values('Delaware', 'DE', 2);
insert into region(name, short_name, country_id) values('Florida', 'FL', 2);
insert into region(name, short_name, country_id) values('Georgia', 'GA', 2);
insert into region(name, short_name, country_id) values('Hawaii', 'HI', 2);
insert into region(name, short_name, country_id) values('Idaho', 'ID', 2);
insert into region(name, short_name, country_id) values('Illinois', 'IL', 2);
insert into region(name, short_name, country_id) values('Indiana', 'IN', 2);
insert into region(name, short_name, country_id) values('Iowa', 'IA', 2);
insert into region(name, short_name, country_id) values('Kansas', 'KS', 2);
insert into region(name, short_name, country_id) values('Kentucky', 'KY', 2);
insert into region(name, short_name, country_id) values('Louisiana', 'LA', 2);
insert into region(name, short_name, country_id) values('Maine', 'ME', 2);
insert into region(name, short_name, country_id) values('Maryland', 'MD', 2);
insert into region(name, short_name, country_id) values('Massachusetts', 'MA', 2);
insert into region(name, short_name, country_id) values('Michigan', 'MI', 2);
insert into region(name, short_name, country_id) values('Minnesota', 'MN', 2);
insert into region(name, short_name, country_id) values('Mississippi', 'MS', 2);
insert into region(name, short_name, country_id) values('Missouri', 'MO', 2);
insert into region(name, short_name, country_id) values('Montana', 'MT', 2);
insert into region(name, short_name, country_id) values('Nebraska', 'NE', 2);
insert into region(name, short_name, country_id) values('Nevada', 'NV', 2);
insert into region(name, short_name, country_id) values('New Hampshire', 'NH', 2);
insert into region(name, short_name, country_id) values('New Jersey', 'NJ', 2);
insert into region(name, short_name, country_id) values('New Mexico', 'NM', 2);
insert into region(name, short_name, country_id) values('New York', 'NY', 2);
insert into region(name, short_name, country_id) values('North Carolina', 'NC', 2);
insert into region(name, short_name, country_id) values('North Dakota', 'ND', 2);
insert into region(name, short_name, country_id) values('Ohio', 'OH', 2);
insert into region(name, short_name, country_id) values('Oklahoma', 'OK', 2);
insert into region(name, short_name, country_id) values('Oregon', 'OR', 2);
insert into region(name, short_name, country_id) values('Pennsylvania', 'PA', 2);
insert into region(name, short_name, country_id) values('Rhode Island', 'RI', 2);
insert into region(name, short_name, country_id) values('South Carolina', 'SC', 2);
insert into region(name, short_name, country_id) values('South Dakota', 'SD', 2);
insert into region(name, short_name, country_id) values('Tennessee', 'TN', 2);
insert into region(name, short_name, country_id) values('Texas', 'TX', 2);
insert into region(name, short_name, country_id) values('Utah', 'UT', 2);
insert into region(name, short_name, country_id) values('Vermont', 'VT', 2);
insert into region(name, short_name, country_id) values('Virginia', 'VA', 2);
insert into region(name, short_name, country_id) values('Washington', 'WA', 2);
insert into region(name, short_name, country_id) values('West Virginia', 'WV', 2);
insert into region(name, short_name, country_id) values('Wisconsin', 'WI', 2);
insert into region(name, short_name, country_id) values('Wyoming', 'WY', 2);

insert into city(name, region_id) values('Toronto', 9);

insert into field_category(name, module_id, is_system) values('LL_COMPANY', 0, 'Y');
insert into field_category(name, module_id, is_system) values('LL_PERSON', 0, 'Y');

insert into field(name, field_category_id, is_system) values('LL_WEB_SITE', 1, 'Y');
insert into field(name, field_category_id, is_system) values('LL_PHONE', 1, 'Y');
insert into field(name, field_category_id, is_system) values('LL_EMAIL', 1, 'Y');
insert into field(name, field_category_id, is_system) values('LL_ADDRESS', 1, 'Y');
insert into field(name, field_category_id, is_system) values('LL_FAX', 1, 'Y');
insert into field(name, field_category_id, is_system) values('LL_NOTES', 1, 'Y');

insert into field(name, field_category_id, is_system) values('LL_CELL_PHONE', 2, 'Y');
insert into field(name, field_category_id, is_system) values('LL_HOME_PHONE', 2, 'Y');
insert into field(name, field_category_id, is_system) values('LL_EMAIL', 2, 'Y');
insert into field(name, field_category_id, is_system) values('LL_ADDRESS', 2, 'Y');
insert into field(name, field_category_id, is_system) values('LL_NOTES', 2, 'Y');

insert into bfile_category (name, module_id, is_system) values('LL_GENERAL', 0, 'Y');
insert into bfile_category (name, module_id, is_system) values('LL_LOGO', 0, 'Y');

insert into comm_media(name, is_system) values('LL_EMAIL', 'Y');
insert into comm_media(name, is_system) values('LL_PHONE_CALL', 'Y');
insert into comm_media(name, is_system) values('LL_SMS', 'Y');
insert into comm_media(name, is_system) values('LL_VIDEO_CHAT', 'Y');

-- TASK
insert into module(id, name, entity_name) values(1, 'task', 'task');

insert into status(name, module_id, is_system) values('LL_NEW_F', 1, 'Y');
insert into status(name, module_id, is_system) values('LL_STARTED', 1, 'Y');
insert into status(name, module_id, is_system) values('LL_ON_HOLD', 1, 'Y');
insert into status(name, module_id, is_system) values('LL_COMPLETED', 1, 'Y');
insert into status(name, module_id, is_system) values('LL_CANCEL', 1, 'Y');

insert into field_category(name, module_id, is_system) values('LL_REGULAR', 1, 'Y');
insert into field_category(name, module_id, is_system) values('LL_CRM', 1, 'Y');

insert into field(name, field_category_id, is_system) values('LL_NOTES', 3, 'Y');
insert into field(name, field_category_id, is_system) values('LL_DUE_DATE', 3, 'Y');
insert into field(name, field_category_id, is_system) values('LL_NOTES', 4, 'Y');
insert into field(name, field_category_id, is_system) values('LL_DUE_DATE', 4, 'Y');
insert into field(name, field_category_id, is_system) values('LL_CRM_ID', 4, 'Y');

-- CRM
insert into module(id, name, entity_name) values(2, 'crm', 'customer');

insert into status(name, module_id, is_system) values('LL_LEAD', 2, 'Y');
insert into status(name, module_id, is_system) values('LL_CUSTOMER', 2, 'Y');
insert into status(name, module_id, is_system) values('LL_INACTIVE', 2, 'Y');

insert into field_category(name, module_id, is_system) values('LL_COMPANY', 2, 'Y');
insert into field_category(name, module_id, is_system) values('LL_PERSON', 2, 'Y');
insert into field_category(name, module_id, is_system) values('LL_OTHER', 2, 'Y');

insert into field(name, field_category_id, is_system) values('LL_WEB_SITE', 5, 'Y');
insert into field(name, field_category_id, is_system) values('LL_PHONE', 5, 'Y');
insert into field(name, field_category_id, is_system) values('LL_EMAIL', 5, 'Y');
insert into field(name, field_category_id, is_system) values('LL_ADDRESS', 5, 'Y');
insert into field(name, field_category_id) values('LL_FAX', 5);
insert into field(name, field_category_id) values('LL_SKYPE_ID', 5);
insert into field(name, field_category_id, is_system) values('LL_NOTES', 5, 'Y');

insert into field(name, field_category_id, is_system) values('LL_CELL_PHONE', 6, 'Y');
insert into field(name, field_category_id, is_system) values('LL_HOME_PHONE', 6, 'Y');
insert into field(name, field_category_id, is_system) values('LL_EMAIL', 6, 'Y');
insert into field(name, field_category_id, is_system) values('LL_ADDRESS', 6, 'Y');
insert into field(name, field_category_id) values('LL_SKYPE_ID', 6);
insert into field(name, field_category_id, is_system) values('LL_NOTES', 6, 'Y');

insert into field(name, field_category_id, is_system) values('LL_PHONE', 7, 'Y');
insert into field(name, field_category_id, is_system) values('LL_EMAIL', 7, 'Y');
insert into field(name, field_category_id) values('LL_SKYPE_ID', 7);
insert into field(name, field_category_id, is_system) values('LL_NOTES', 7, 'Y');

-- Custom data
insert into user(name) values('user1');
insert into address(line_1, zip, city_id) values('Here we are', 'ABC123', 1);

-- Example business_info
insert into entity(module_id, name, field_cat_id) values(0, 'Example', 1);
insert into entity_field(entity_id, field_id, value) values(1, 1, 'http://www.example.com/');
insert into entity_field(entity_id, field_id, value) values(1, 2, '1-888-1234567');
insert into entity_field(entity_id, field_id, value) values(1, 3, 'info@example.com');
insert into entity_field(entity_id, field_id, value) values(1, 4, '1');

-- Temp task
insert into entity(module_id, name, field_cat_id) values(1, 'TO-DO', 3);
insert into entity_ex(id, entity_id, user_id, status_id) values(2, 2, 1, 1);
insert into entity_field(entity_id, field_id, value) values(2, 12, 'Sample TO_DO task');
insert into entity_status_history(entity_id, status_id, user_id) values(2, 1, 1);
insert into entity_user_history(entity_id, owner_id, user_id) values(2, 1, 1);

-- Temp contact
insert into entity(module_id, name, field_cat_id) values(2, 'Temp', 4);
insert into entity_ex(id, entity_id, user_id, status_id) values(3, 3, 1, 6);
insert into entity_field(entity_id, field_id, value) values(3, 15, '1-888-1234567');
insert into entity_status_history(entity_id, status_id, user_id) values(3, 6, 1);
insert into entity_user_history(entity_id, owner_id, user_id) values(3, 1, 1);

commit;

