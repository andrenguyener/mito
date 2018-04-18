ALTER PROC uspcGetOrderDetails 
@OrderId INT
AS
	IF EXISTS (SELECT * FROM [ORDER] WHERE OrderId = @OrderId AND GiftOption = 0)
		BEGIN
			SELECT AmazonItemId, ProductName, ProductImageUrl, Quantity
			FROM ORDER_PRODUCT 
			WHERE OrderId = @OrderId
		END
GO

--example call
EXEC dbo.uspcGetOrderDetails 42