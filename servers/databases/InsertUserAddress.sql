/*
@params: userId, streetAddress1, streetAddress2, cityName, zipCode, stateName
Insert an address for the given userId and return the newly made addressId
as an output parameter
*/

ALTER PROC InsertUserAddress
@userId INT,
@streetAddress1 NVARCHAR(100),
@streetAddress2 NVARCHAR(100),
@cityName NVARCHAR(75),
@stateName NVARCHAR(30),
@zipCode NVARCHAR(12),
@aliasName NVARCHAR(50)
AS
	--retrieve matching StreetAddressId based on the given streetaddress1 and streetaddress 2
	DECLARE @streetAddressId INT
	EXEC GetStreetAddressId @streetAddress1, @streetAddress2, @StreetAddress_Id = @streetAddressId OUT

	-- retrieve matching CityId based on the given city name
	DECLARE @cityId INT
	EXEC GetCityId @cityName, @City_Id = @cityId OUT

	-- retrieve matching ZipCodeId based on the given zip code
	DECLARE @zipCodeId INT
	EXEC GetZipCodeId @zipCode, @ZipCode_Id = @zipCodeId OUT

	-- retrieve matching StateId based on the given state name
	DECLARE @stateId INT
	EXEC GetStateId @stateName, @State_Id = @stateId OUT

	-- a placeholder for newly added Address Scope_Identity()
	DECLARE @newAddressId INT
	DECLARE @todaysDate DATETIME = (SELECT GETDATE())

	IF @streetAddressId IS NULL OR @cityId IS NULL
	OR @zipCodeId IS NULL OR @stateId IS NULL
		BEGIN
			PRINT'Invalid address data are attempted on insertion. Please provide valid address information'
			RAISERROR('@streetAddressId, @cityId, @zipCodeId, and @stateId cannot be NULL',11,1)
			RETURN
		END
	--insert the address into the ADDRESS table first
	EXEC InsertAddress @streetAddress1,@streetAddress2, @cityName, 
	@stateName, @zipCode, @Address_Id = @newAddressId OUT

	IF EXISTS (SELECT * FROM USER_ADDRESS WHERE AddressId = @newAddressId AND UserId = @UserId)
		BEGIN
			PRINT'This address already exists with the given user'
			RAISERROR('@newAddressId and @UserId must not already exist when insert into USER_ADDRESS',11,1)
			RETURN
		END

	BEGIN TRAN addUserAddress
		INSERT INTO USER_ADDRESS(AddressId,UserId,IsDefault,Alias,IsDefaultCreatedDate,CreatedDate)
		VALUES(@newAddressId,@userId,1,@aliasName,@todaysDate,@todaysDate)
		--SET @UserAddress_ID = (SELECT SCOPE_IDENTITY())
		IF @@ERROR <> 0
			ROLLBACK TRAN addUserAddress
		ELSE
			COMMIT TRAN addUserAddress

/*
DECLARE @Test INT
EXEC InsertUserAddress 7,'124 Pizza Way', '2nd Floor', 'Seattle', 'WA', '98144', 
'Sopheak Test', @UserAddress_ID = @TEST OUT
PRINT @TEST
*/
