-- Create an order in ORDER table according to values in params
CREATE PROC uspCreatePurchaseOrder
@UserId INT,
@UserAddressId INT, 
@RecipientId INT, 
@Message NVARCHAR(1000), 
@TodaysDate DATETIME, 
@GiftOption BIT, 
@PendingStatusId INT, 
@SumCartPrice NUMERIC(12,2),
@Order_ID INT OUT
AS
BEGIN
	BEGIN TRAN InsertOrder
	INSERT INTO [ORDER](SenderId, BillingAddressId, RecipientId,OrderMessage, OrderDate, GiftOption, OrderUserConfirmation, GrandTotal)
	VALUES (@UserId, @UserAddressId, @RecipientId, @Message, @TodaysDate, @GiftOption, @PendingStatusId, @SumCartPrice)
	SET @Order_ID = (SELECT Scope_Identity())
	
	IF @@ERROR <> 0
	ROLLBACK TRAN InsertOrder
	ELSE
	COMMIT TRAN InsertOrder
END