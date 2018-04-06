--return all items in a user cart based on userId
--return a table that has the product that is only in the 
-- the user cart
CREATE PROC uspGetUserCartItemList
@UserId INT
AS
BEGIN
	SELECT C.AmazonItemId, Quantity, AmazonItemPrice, AmazonItemPrice * Quantity AS SumPrice
	FROM CART C
	JOIN 
	(SELECT AmazonItemId, MAX(CartDateTime) AS MostRecentDate
	FROM CART WHERE UserId = @UserId GROUP BY AmazonItemId) AS MostRecentSelection
	ON C.AmazonItemId = MostRecentSelection.AmazonItemId
	AND C.CartDateTime = MostRecentSelection.MostRecentDate
END

EXEC sp_rename 'uspGetUserCartItemList', 'uspcGetUserCartItemList'