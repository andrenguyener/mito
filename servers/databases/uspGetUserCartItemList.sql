--return all items in a user cart based on userId
--return a table that has the product that is only in the 
-- the user cart
ALTER PROC uspcGetUserCartItemList
@UserId INT
AS
BEGIN
	SELECT C.AmazonItemId, Quantity, AmazonItemPrice, AmazonItemPrice * Quantity AS SumPrice, 
	ProductImageUrl, ProductName
	FROM CART C
	JOIN 
	(SELECT AmazonItemId, MAX(CartDateTime) AS MostRecentDate
	FROM CART WHERE UserId = @UserId GROUP BY AmazonItemId) AS MostRecentSelection
	ON C.AmazonItemId = MostRecentSelection.AmazonItemId
	AND C.CartDateTime = MostRecentSelection.MostRecentDate
	AND C.Quantity > 0
END

EXEC sp_rename 'uspGetUserCartItemList', 'uspcGetUserCartItemList'