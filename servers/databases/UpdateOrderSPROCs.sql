-- retrieve all users pending incoming packages
ALTER PROC uspcGetMyPendingPackages
@UserId INT
AS
BEGIN
	IF @UserId IS NULL
		BEGIN
			PRINT'This user does not exist'
			RAISERROR('@UserId cannot be NULL',11,1)
			RETURN
		END
	DECLARE @PendingTypeId INT
	EXEC dbo.uspGetUserConfirmationTypeId 'Pending', @Type_Id = @PendingTypeId OUT
	SELECT OrderId, SenderId, OrderMessage, OrderDate FROM [ORDER] 
	WHERE RecipientId = @UserId AND OrderUserConfirmation = @PendingTypeId
	ORDER BY OrderDate DESC
END

-- update the order based on users response (Accepted or Denied)
-- then send a notification to the sender
ALTER PROC uspcConfirmPackage
@UserId INT,
@SenderId INT,
@OrderId INT,
@Response NVARCHAR(50),
@ShippingAddressId INT
AS
	IF @UserId IS NULL
		BEGIN
			PRINT'This user does not exist'
			RAISERROR('@UserId cannot be NULL',11,1)
			RETURN
		END
	IF NOT EXISTS (SELECT * FROM [Order] 
	WHERE OrderId = @OrderId AND RecipientId = @UserId)
		BEGIN
			PRINT'This package does not match with the given UserId'
			RAISERROR('@UserId must be match with the @OrderId recipient',11,1)
			RETURN
		END
	 DECLARE @PackageResponseId INT
	 EXEC dbo.uspGetUserConfirmationTypeId @Response, @Type_Id = @PackageResponseId OUT
	 IF @PackageResponseId IS NULL
		BEGIN
			PRINT'This response type doesn not exist'
			RAISERROR('@PackageResponseId cannot be null',11,1)
			RETURN
		END
	DECLARE @TodaysDate DATETIME = (SELECT GETDATE())
	DECLARE @NotificationTypeId INT
	EXEC dbo.uspGetNotificationType @Response, 'Orders', @NotificationType_Id = @NotificationTypeId OUT
	BEGIN TRAN CreateNotification
		BEGIN TRAN UpdateOrder
			EXEC dbo.uspUpdateOrder @OrderId, @PackageResponseId, @ShippingAddressId
			IF @@ERROR <> 0 
				ROLLBACK TRAN UpdateOrder
			ELSE
				COMMIT TRAN UpdateOrder
	EXEC dbo.uspInsertNotification @NotificationTypeId, @UserId, @SenderId, @TodaysDate
	IF @@ERROR <> 0 
		ROLLBACK TRAN CreateNotification
	ELSE
		COMMIT TRAN CreateNotification

-- uspUpdateOrder update the response type in ORDER table based on the OrderId 
-- to the corresponding response type id (given)
ALTER PROC uspUpdateOrder
@OrderId INT,
@ResponseId INT,
@AddressId INT
AS
BEGIN
	UPDATE [Order]
	SET OrderUserConfirmation = @ResponseId, ShippingAddressId = @AddressId
	WHERE OrderId = @OrderId 
END
GO
--example calls
SELECT * FROM [Order]
SELECT * FROM NOTIFICATION
EXEC dbo.uspcConfirmPackage 34, 7, 17, 'Accepted',7
EXEC dbo.uspcGetUserAddressById 7
SELECT * FROM USER_ADDRESS