/*
An stored procedure for getting the friend type based on 
the friendId
@param a valid FriendId
*/
CREATE PROC uspGetFriendTypeValue
@FriendId INT,
@CurrentFriendType NVARCHAR(50) OUT
AS
	SET @CurrentFriendType = (SELECT FriendType 
	FROM FRIEND F
	JOIN FRIEND_TYPE FT ON F.FriendTypeId = FT.FriendTypeId 
	WHERE FriendId = @FriendId)
GO

-- example call
DECLARE @Test NVARCHAR(50)
EXEC dbo.uspGetFriendTypeValue 6, @CurrentFriendType = @Test OUT
PRINT @Test
