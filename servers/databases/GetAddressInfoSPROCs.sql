/*
Output param SPROCs for getting relevant Address data
*/

-- @params: street address 1 and 2
-- If found, return the StreetAddressId
-- If not found, insert the new street address into the table and return the newly made StreetAddressId
ALTER PROC GetStreetAddressId
@streetAddress1 NVARCHAR(100),
@streetAddress2 NVARCHAR(100),
@StreetAddress_Id INT OUT
AS
	SET @StreetAddress_Id = (SELECT StreetAddressId FROM STREET_ADDRESS 
	WHERE StreetAddress = @streetAddress1 AND
	StreetAddress2 = @streetAddress2)
	IF @StreetAddress_Id IS NULL
		BEGIN
		INSERT INTO STREET_ADDRESS(StreetAddress,StreetAddress2)
		VALUES(@streetAddress1,@streetAddress2)
		SET @StreetAddress_Id = (SELECT SCOPE_IDENTITY())
		END
GO

-- @params: zipcode
-- If found, return the matched ZipCodeId
-- If not found, insert the zipcode into the table and return the newly made ZipCodeId
ALTER PROC GetZipCodeId
@Zipcode NVARCHAR(12),
@ZipCode_Id INT OUT
AS
	SET @ZipCode_Id = (SELECT ZipCodeId FROM ZIPCODE 
	WHERE ZipCode = @Zipcode)
	IF @ZipCode_Id IS NULL
		BEGIN
		INSERT INTO ZIPCODE(ZipCode)
		VALUES(@Zipcode)
		SET @ZipCode_Id = (SELECT SCOPE_IDENTITY())
		END
GO

-- @params: city
-- If found, return the matched cityId
-- If not found, insert the city into the table and return the newly made CityId
CREATE PROC GetCityId
@city NVARCHAR(75),
@City_Id INT OUT
AS
	SET @City_Id = (SELECT CityId FROM CITY
	WHERE CityName = @city)
	IF @City_Id IS NULL
		BEGIN
		INSERT INTO CITY(CityName)
		VALUES(@city)
		SET @City_Id = (SELECT SCOPE_IDENTITY())
		END
GO

-- @params: state name (Abbr.)
-- If found, return the matched StateId
-- If not found, insert the state into the table and return the newly made StateId
CREATE PROC GetStateId
@state NVARCHAR(30),
@State_Id INT OUT
AS
	SET @State_Id = (SELECT StateId FROM [STATE]
	WHERE StateName = @state)
	IF @State_Id IS NULL
		BEGIN
		INSERT INTO [STATE](StateName)
		VALUES(@state)
		SET @State_Id = (SELECT SCOPE_IDENTITY())
		END
GO
