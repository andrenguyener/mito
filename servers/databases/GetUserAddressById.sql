/*
@param: UserId (valid UserId in the database)
Return raw address of the given UserId along with 
User profile information if the UserId has an
existing address in their address book
*/

ALTER PROC uspGetUserAddressById
@UserId INT
AS
	-- Check if the UserId exist in USER
	IF NOT EXISTS (SELECT * FROM [USER] WHERE UserId = @UserId)
		BEGIN
			PRINT'This user does not exist in the database'
			RAISERROR('@UserId must be a valid ID in USER',11,1)
			RETURN
		END
	-- Check if the UserId has an address in USER_ADDRESS
	IF EXISTS (SELECT * FROM USER_ADDRESS WHERE UserId = @UserId)

	(SELECT U.UserId, U.UserFname, U.UserLname, U.UserEmail,U.Username, UA.UserAddressId,
		SA.StreetAddress, StreetAddress2, CityName, StateName, ZipCode, UA.IsDefault FROM [USER] U
		JOIN USER_ADDRESS UA ON U.UserId = UA.UserId
		JOIN [ADDRESS] A ON UA.AddressId = A.AddressId
		JOIN STREET_ADDRESS SA ON A.StreetAddressId = SA.StreetAddressId
		JOIN CITY C ON A.CityId = C.CityId
		JOIN [STATE] S ON A.StateId = S.StateId
		JOIN ZIPCODE Z ON A.ZipCodeId = Z.ZipCodeId
		WHERE U.UserId = @UserId AND UA.IsDeleted <> 1)
		FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
	ELSE 
		BEGIN
			PRINT'This user does not have the given address in their address book'
			RAISERROR('@UserId must have at least one address in USER_ADDRESS',11,1)
			RETURN
		END
GO

EXEC sp_rename 'GetUserAddressById', 'uspGetUserAddressById'

-- example success (uncomment the line below): 7 is a valid userId
EXEC uspGetUserAddressById 7

-- example error (uncomment the line below): 3 is a valid user but doesn't have any address
--EXEC GetUserAddressById 3

-- example error (uncomment the line below): 4 is not a valid user in the database
--EXEC GetUserAddressById 4
