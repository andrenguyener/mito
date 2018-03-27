ALTER PROC uspInsertAddress
@streetAddress1 NVARCHAR(100),
@streetAddress2 NVARCHAR(100),
@cityName NVARCHAR(75),
@stateName NVARCHAR(30),
@zipCode NVARCHAR(12),
@Address_Id INT OUT
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
	
	IF EXISTS (SELECT AddressId FROM [ADDRESS] WHERE StreetAddressId = @streetAddressId
		AND CityId = @cityId AND StateId = @stateId AND ZipCodeId = @zipCodeId)
		BEGIN
		SET @Address_Id = (SELECT AddressId FROM [ADDRESS] WHERE StreetAddressId = @streetAddressId
		AND CityId = @cityId AND StateId = @stateId AND ZipCodeId = @zipCodeId)
		END
	ELSE
		BEGIN
		BEGIN TRAN addAddress
		INSERT INTO ADDRESS(StreetAddressId,CityId,StateId,ZipCodeId)
		VALUES(@streetAddressId,@cityId,@stateId,@zipCodeId)
		SET @Address_Id = (SELECT SCOPE_IDENTITY())
		IF @@ERROR <> 0
			ROLLBACK TRAN addAddress
		ELSE
			COMMIT TRAN addAddress
		END

EXEC sp_rename 'InsertAddress', 'uspInsertAddress'