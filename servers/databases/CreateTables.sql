-- CREATE TABLE STATEMENTS

CREATE TABLE NOTIFICATION (
	NotificationId INT IDENTITY(1,1) PRIMARY KEY,
	NotificationTypeId INT FOREIGN KEY REFERENCES NOTIFICATION_TYPE(NotificationTypeId) NOT NULL,
	SendFrom INT NOT NULL,
	SendTo INT NOT NULL,
	NotificationDate DATETIME NOT NULL	 
)


CREATE TABLE NOTIFICATION_TYPE (
	NotificationTypeId INT IDENTITY(1,1) PRIMARY KEY,
	NotificationType nvarchar(50) NOT NULL,
	LinkToView nvarchar(1000) NOT NULL,
	[Message] nvarchar(1000) NOT NULL
)
ALTER TABLE NOTIFICATION_TYPE
ADD Category NVARCHAR(50)


CREATE TABLE STREET_ADDRESS (
	StreetAddressId INT IDENTITY(1,1) PRIMARY KEY,
	StreetAddress nvarchar(100)
)

ALTER TABLE STREET_ADDRESS
ADD StreetAddress2 NVARCHAR(100) NULL

CREATE TABLE STATE (
	StateId INT IDENTITY(1,1) PRIMARY KEY,
	StateName nvarchar(30)
)

CREATE TABLE CITY (
	CityID INT IDENTITY(1,1) PRIMARY KEY,
	CityName nvarchar(75)
)

CREATE TABLE ZIPCODE (
	ZipCodeId INT IDENTITY(1,1) PRIMARY KEY,
	ZipCode nvarchar(12)
)

CREATE TABLE ADDRESS (
	AddressId INT IDENTITY(1,1) PRIMARY KEY,
	StreetAddressId INT FOREIGN KEY REFERENCES STREET_ADDRESS(StreetAddressId) NOT NULL,
	CityId INT FOREIGN KEY REFERENCES CITY(CityId) NOT NULL,
	StateId INT FOREIGN KEY REFERENCES STATE(StateId) NOT NULL,
	ZipCodeId INT FOREIGN KEY REFERENCES ZIPCODE(ZipCodeId) NOT NULL
)

CREATE TABLE USER_ADDRESS (
	UserAddressId INT IDENTITY(1,1) PRIMARY KEY,
	AddressId INT FOREIGN KEY REFERENCES [ADDRESS](AddressId) NOT NULL,
	UserId INT FOREIGN KEY REFERENCES[User] NOT NULL,
	IsDefault Bit NOT NULL,
	Alias nvarchar(50)
)

ALTER TABLE USER_ADDRESS
ADD IsDefaultCreatedDate DATETIME NOT NULL,
CreatedDate DATETIME NOT NULL

ALTER TABLE USER_ADDRESS
ADD IsDeleted BIT NOT NULL DEFAULT 0

CREATE TABLE FRIEND (
	FriendId INT IDENTITY(1,1) PRIMARY KEY,
	User1Id INT FOREIGN KEY REFERENCES [USER](UserId) NOT NULL,
	User2Id INT FOREIGN KEY REFERENCES [User](UserId) NOT NULL,
	FriendTypeId INT FOREIGN KEY REFERENCES FRIEND_TYPE(FriendTypeId) NOT NULL,
)
ALTER TABLE FRIEND
ADD IsDeleted BIT NOT NULL DEFAULT 0

CREATE TABLE FRIEND_TYPE (
	FriendTypeId INT IDENTITY(1,1) PRIMARY KEY,
	FriendType nvarchar(25) NOT NULL,
	FriendTypeDescr nvarchar(1000)
)

CREATE TABLE USER_CREDIT_CARD (
	UserCreditCardId INT IDENTITY(1,1) PRIMARY KEY,
	UserId INT FOREIGN KEY REFERENCES [USER](UserId) NOT NULL,
	CreditCardId INT FOREIGN KEY REFERENCES CREDIT_CARD(CreditCardId) NOT NULL
)
ALTER TABLE USER_CREDIT_CARD
ADD IsDelete BIT NOT NULL

ALTER TABLE USER_CREDIT_CARD
ADD IsDefault BIT 

CREATE TABLE CREDIT_CARD (
	CreditCardId INT IDENTITY(1,1) PRIMARY KEY,
	CardType NVARCHAR(50) NOT NULL,
	CardNumber NVARCHAR(25) NOT NULL,
	ExpMonth TINYINT NOT NULL,
	ExpYear SMALLINT NOT NULL,
	ModifiedDate DATETIME NOT NULL
)

--Add CardCVV Column
ALTER TABLE CREDIT_CARD ADD CardCVV SMALLINT NOT NULL

CREATE TABLE CART (
CartId INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
UserId INT FOREIGN KEY REFERENCES [USER](UserId) NOT NULL,
AmazonItemId INT NOT NULL,
Quantity INT NOT NULL
)

ALTER TABLE CART
ADD AmazonItemPrice NUMERIC(12,2) NOT NULL

ALTER TABLE CART
ADD CartDateTime DATETIME NOT NULL

ALTER TABLE CART
ALTER COLUMN AmazonItemId NVARCHAR(50)

CREATE TABLE ORDER_PRODUCT(
OrderProductId INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
OrderId INT FOREIGN KEY REFERENCES [Order](OrderId) NOT NULL,
AmazonItemId INT NOT NULL,
Quantity INT NOT NULL,
PriceExtended NUMERIC(12,2) NOT NULL
)
ALTER TABLE ORDER_PRODUCT
ALTER COLUMN AmazonItemId NVARCHAR(50)

ALTER TABLE ORDER_PRODUCT
ADD AmazonItemPrice NUMERIC(12,2) NOT NULL

ALTER TABLE [ORDER]
ALTER COLUMN ZincOrderId INT NULL