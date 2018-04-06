
ALTER TABLE ORDER_PRODUCT
ADD PriceExtended AS (AmazonItemPrice * Quantity)
GO

-- calcute the grand total of all items in the cart
CREATE FUNCTION fnCalculateOrderGrandTotal (@OrderID INT)
RETURNS NUMERIC(12,2)
AS
BEGIN
DECLARE @RET NUMERIC(12,2) =
	(SELECT SUM(PriceExtended) FROM ORDER_PRODUCT WHERE OrderID = @OrderID)
RETURN @RET
END
GO

ALTER TABLE [ORDER]
ADD GrandTotal NUMERIC(12,2) NOT NULL

-- params: Amazon product ASIN, Item price for the product, UserId, and Quantity
-- Insert into the cart based on the params above
EXEC sp_rename 'uspInsertIntoCart', 'uspcInsertIntoCart'

ALTER PROC uspcInsertIntoCart
@AmazonASIN INT,
@AmazonPrice NUMERIC(12,2),
@UserId INT,
@Qty INT
AS

IF @AmazonASIN IS NULL 
	BEGIN
		PRINT'Amazon Product ASIN is not provided'
		RAISERROR('@AmazonASIN cannot be NULL',11,1)
		RETURN
	END

IF @Qty < 1
	BEGIN
		PRINT'Quantity must be at least 1'
		RAISERROR('@Qty cannot be less than 1', 11,1)
		RETURN
	END

DECLARE @CurrentDateTime DATETIME = (SELECT GETDATE())

BEGIN TRAN InsertToCart
	INSERT INTO CART VALUES(@UserId, @AmazonASIN, @Qty, @AmazonPrice, @CurrentDateTime)
IF @@ERROR <> 0
	ROLLBACK TRAN InsertToCart
ELSE
	COMMIT TRAN InsertToCart
GO

-- params: UserId, The billing address of the user, UserId of the recipient
-- checkout the items in users cart to process an order for the given receipient
-- default confirmation for the order will be "pending"
EXEC sp_rename 'uspProcessCheckout', 'uspcProcessCheckout'
ALTER PROC uspcProcessCheckout
@UserId INT,
@UserAddressId INT,
@RecipientId INT,
@Message NVARCHAR(1000),
@GiftOption BIT
AS

-- create a temp cart
DECLARE @CART TABLE 
(tempCartId INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
AmazonASIN INT NOT NULL,
Qty INT NOT NULL,
AmazonItemPrice NUMERIC(12,2) NOT NULL,
SumPrice NUMERIC(12,2))

-- populate the temp table @CART with values from user's CART
-- only select MOST RECENT (DATETIME) of distinct products in the cart
INSERT INTO @CART
EXEC dbo.uspcGetUserCartItemList @UserId

DECLARE @Count INT = (SELECT COUNT(*) FROM @CART)
DECLARE @SumCartPrice NUMERIC(12,2) = (SELECT SUM(SumPrice) FROM @CART)
-- CartId in the temp @CART table
DECLARE @ID INT
-- AmazonItemId in the temp @CART table
DECLARE @ProdID INT
-- Most recent/update quantity
DECLARE @Qty INT
DECLARE @OrderID INT
DECLARE @ItemPrice NUMERIC(12,2)
DECLARE @PendingStatusId INT = (SELECT OrderUserConfirmationId FROM ORDER_USER_CONFIRMATION
								WHERE OrderUserConfirmation = 'Pending') 
DECLARE @TodaysDate DATE = (SELECT GETDATE())
-- SET XACT_ABORT ON will render the transaction uncommittable
-- when the constraint violation occurs.
SET XACT_ABORT ON

BEGIN TRY
BEGIN TRANSACTION G1
EXEC dbo.uspCreatePurchaseOrder @UserId, @UserAddressId, @RecipientId, @Message, 
@TodaysDate, @GiftOption, @PendingStatusId, @SumCartPrice, @Order_Id = @OrderID OUT

IF @OrderID IS NULL
	BEGIN
		PRINT'There is a problem creating a purchase order'
		RAISERROR('@OrderID cannot be NULL',11,1)
		RETURN
	END

WHILE @Count > 0 --begin loop to process all rows from #CART; @Count is number of rows to be processed
    BEGIN
        SET @ID = (SELECT MIN(tempCartId) FROM @CART)
        SET @ProdID = (SELECT TOP 1 AmazonASIN FROM @CART WHERE tempCartId = @ID)
        SET @Qty = (SELECT Qty FROM @CART WHERE tempCartId = @ID)
		SET @ItemPrice = (SELECT AmazonItemPrice FROM @CART WHERE tempCartId = @ID)
    --'old-school'error-handling method
    -- sp_addmessage 50011, 11, 'OrderID cannot be NULL' was previously added to system
    IF @OrderID IS NULL
        BEGIN
			RAISERROR (50011, 11, 1)
        END
    ELSE
	INSERT INTO ORDER_PRODUCT(OrderId,AmazonItemId,Quantity, AmazonItemPrice) VALUES (@OrderID, @ProdID, @Qty, @ItemPrice)
        -- Clean-up the row just INSERTed into tblLINE_ITEM by DELETING it from #CART
        DELETE 
        FROM @CART 
        WHERE tempCartID = @ID --anchoring to @ID ensures we are deleting only one row

        -- we must also decrement the boolean variable that keeps the loop alive; if we do not have
        -- this line then the loop will never reach zero and run infinitely
        SET @Count = @Count -1
END

IF @@ERROR <> 0 --just looking for any global errors at this time
	BEGIN
		ROLLBACK TRANSACTION G1
	END
ELSE
    -- Test whether the transaction is active and valid.
    IF (XACT_STATE()) = 1
    BEGIN
        COMMIT TRANSACTION G1
       END
DELETE 
FROM CART
WHERE UserId = @UserId

END TRY

BEGIN CATCH
    -- Test XACT_STATE for 0 or -1
    -- If -1, the transaction is uncommittable and should be rolled back
    -- XACT_STATE = 0 means there is no transaction and a commit or rollback operation would generate an error

    -- Test whether the transaction is uncommittable.
    IF (XACT_STATE()) = -1
    BEGIN
        PRINT 'The transaction is in an uncommittable state.' +
              ' Rolling back transaction.'
        SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
        ROLLBACK TRANSACTION G1
    END
END CATCH

-- example cart processing
SELECT * FROM CART
SELECT * FROM ORDER_PRODUCT
SELECT * FROM [ORDER]
EXEC dbo.uspcInsertIntoCart '1245','12.00',7,5
EXEC dbo.uspcInsertIntoCart '10394','12.00',7,5
EXEC dbo.uspcProcessCheckout 7, 7, 8, 'Testing checkout cart', 0
