ALTER PROC uspGetOrderInformationForZinc
@OrderId INT,
@UserResponse NVARCHAR(50)
AS
	IF @UserResponse <> 'Denied'
	BEGIN
	DECLARE @SenderId INT = (SELECT SenderId FROM [ORDER] WHERE OrderId = @OrderId)
	DECLARE @RecipientId INT = (SELECT RecipientId FROM [ORDER] WHERE OrderId = @OrderId)
	DECLARE @SenderAddressId INT = (SELECT BillingAddressId FROM [ORDER] WHERE OrderId = @OrderId)
	DECLARE @RecipientAddressId INT = (SELECT ShippingAddressId FROM [ORDER] WHERE OrderId = @OrderId)
	
		(SELECT O.OrderId, O.GrandTotal, Sender.UserFname AS BillingFname, Sender.UserLname AS BillingLname,
		SenderAddress.StreetAddress AS BillingStreet1, SenderAddress.StreetAddress2 AS BillingStreet2,
		SenderAddress.CityName AS BillingCity, SenderAddress.StateName AS BillingState, SenderAddress.ZipCode AS BillingZip,
		Recipient.UserFname AS ShippingFname, Recipient.UserLname AS ShippingLname, 
		RecipientAddress.StreetAddress AS ShippingStreet1, RecipientAddress.StreetAddress2 AS ShippingStreet2,
		RecipientAddress.CityName AS ShippingCity, RecipientAddress.ZipCode AS ShippingZip,
		OP.AmazonItemId, Op.Quantity, O.GiftOption
		FROM [ORDER] O
		JOIN 
		(SELECT * FROM [USER] WHERE UserId = @SenderId) Sender
		ON O.SenderId = Sender.UserId
		JOIN
		(SELECT * FROM [USER] WHERE UserId = @RecipientId) Recipient
		ON O.RecipientId = Recipient.UserId
		JOIN
		(SELECT ADDR.AddressId, StreetAddress, StreetAddress2, CityName, StateName, ZipCode FROM [ADDRESS] ADDR
		JOIN [STREET_ADDRESS] SA ON ADDR.StreetAddressId = SA.StreetAddressId
		JOIN [CITY] C ON ADDR.CityId = C.CityId
		JOIN [STATE] S ON ADDR.StateId = S.StateId
		JOIN [ZIPCODE] Z ON ADDR.ZipCodeId = Z.ZipCodeId
		WHERE AddressId = @SenderAddressId) SenderAddress
		ON O.BillingAddressId = SenderAddress.AddressId
		JOIN
		(SELECT ADDR.AddressId, StreetAddress, StreetAddress2, CityName, StateName, ZipCode FROM [ADDRESS] ADDR
		JOIN [STREET_ADDRESS] SA ON ADDR.StreetAddressId = SA.StreetAddressId
		JOIN [CITY] C ON ADDR.CityId = C.CityId
		JOIN [STATE] S ON ADDR.StateId = S.StateId
		JOIN [ZIPCODE] Z ON ADDR.ZipCodeId = Z.ZipCodeId
		WHERE AddressId = @RecipientAddressId) RecipientAddress
		ON O.ShippingAddressId = RecipientAddress.AddressId
		JOIN [ORDER_PRODUCT] OP ON O.OrderId = OP.OrderId 
		WHERE O.OrderId = @OrderId)
	END
GO

EXEC dbo.uspcGetMyPendingPackages 34
EXEC dbo.uspcConfirmPackage 34, 7, 16, 'Accepted', 8 
SELECT * FROM [ORDER] WHERE OrderId = 16
SELECT * FROM [ORDER] WHERE OrderId = 40
SELECT * FROM [USER] WHERE UserId = 7
EXEC dbo.uspGetOrderInformationForZinc 16, 'Accepted'
SELECT * FROM ADDRESS