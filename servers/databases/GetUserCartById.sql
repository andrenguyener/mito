
ALTER PROC uspGetUserCartById
@UserId INT
AS
	BEGIN
		--SELECT C.AmazonItemId, Quantity, AmazonItemPrice, AmazonItemPrice * Quantity AS SumPrice
		SELECT C.AmazonItemId, Quantity, AmazonItemPrice
		FROM CART C 
		JOIN
		(SELECT AmazonItemId, MAX(CartDateTime) AS MostRecentDate
		FROM CART WHERE UserId = @UserId GROUP BY AmazonItemId) AS MostRecentSelection
		ON C.AmazonItemId = MostRecentSelection.AmazonItemId
		AND C.CartDateTime = MostRecentSelection.MostRecentDate
		WHERE UserId = @UserId
		FOR JSON AUTO
	END
GO

EXEC sp_rename 'uspGetUserCart', 'uspGetUserCartById'

-- example calls
EXEC uspInsertIntoCart '12345678', '13.00', 7, 10
EXEC uspInsertIntoCart '1234', '11.00', 7, 1
EXEC uspInsertIntoCart '12345678', '13.00', 7, 5

EXEC uspGetUserCartById 7

