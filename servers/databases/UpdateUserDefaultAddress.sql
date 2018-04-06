/*
@params: user address information
return an AddressId if this address exists, else return NULL

warning: if the components of address do not exist, it adds the address into the database
*/

ALTER PROC uspGetAddressId
@streetAddress1 NVARCHAR(100),
@streetAddress2 NVARCHAR(100),
@cityName NVARCHAR(75),
@stateName NVARCHAR(30),
@zipCode NVARCHAR(12),
@MatchedAddress_Id INT OUT
AS
	--retrieve matching StreetAddressId based on the given streetaddress1 and streetaddress 2
	DECLARE @streetAddressId INT
	EXEC uspGetStreetAddressId @streetAddress1, @streetAddress2, @StreetAddress_Id = @streetAddressId OUT

	-- retrieve matching CityId based on the given city name
	DECLARE @cityId INT
	EXEC uspGetCityId @cityName, @City_Id = @cityId OUT

	-- retrieve matching ZipCodeId based on the given zip code
	DECLARE @zipCodeId INT
	EXEC uspGetZipCodeId @zipCode, @ZipCode_Id = @zipCodeId OUT

	-- retrieve matching StateId based on the given state name
	DECLARE @stateId INT
	EXEC uspGetStateId @stateName, @State_Id = @stateId OUT
	IF @streetAddressId IS NULL OR @cityId IS NULL
	OR @zipCodeId IS NULL OR @stateId IS NULL
		BEGIN
			PRINT'Invalid address data are attempted on insertion. Please provide valid address information'
			RAISERROR('@streetAddressId, @cityId, @zipCodeId, and @stateId cannot be NULL',11,1)
			RETURN
		END
		
	SET @MatchedAddress_Id = (SELECT AddressId FROM [ADDRESS] WHERE StreetAddressId = @streetAddressId
	AND CityId = @cityId AND StateId = @stateId AND ZipCodeId = @zipCodeId)
GO		

DECLARE @Test INT
EXEC uspGetAddressId '124 Pizza Way', '2nd Floor', 'Seattle', 'WA', '98144', 
@MatchedAddress_ID = @TEST OUT
PRINT @Test

EXEC sp_rename 'GetAddressId', 'uspGetAddressId'

/*
@params: user address id
update the given address based on the addressId 
to be default's user address

may need to optimize the UPDATE IsDefault statement to a table function instead
*/
ALTER PROC uspUpdateUserDefaultAddress
@userId INT,
@ExistingAddressId INT
AS
	IF @ExistingAddressId IS NULL
		BEGIN
			PRINT'This address does not exist in the database'
			RAISERROR('@ExistingAddressId cannot be NULL',11,1)
			RETURN
		END

	DECLARE @TodaysDate DATETIME = (SELECT GETDATE())
	IF EXISTS (SELECT * FROM USER_ADDRESS WHERE AddressId = @ExistingAddressId AND UserId = @userId)
		BEGIN
			UPDATE USER_ADDRESS
			SET IsDefault = 0
			WHERE UserId = @userId
			UPDATE USER_ADDRESS
			SET IsDefault = 1, IsDefaultCreatedDate = @TodaysDate
			WHERE UserId = @userId AND AddressId = @ExistingAddressId
		END
	ELSE
		BEGIN
			PRINT'This user does not have the given address in their address book'
			RAISERROR('@ExistingAddressId and @UserId must already exist in USER_ADDRESS',11,1)
			RETURN
		END

EXEC sp_rename 'UpdateUserDefaultAddress', 'uspUpdateUserDefaultAddress'

--testing code
EXEC uspUpdateUserDefaultAddress 7,7
SELECT * FROM USER_ADDRESS

