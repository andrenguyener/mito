-- (no longer using this) returns the count of friend a user has
CREATE PROC uspGetUserFriendCount
@UserId INT,
@Count INT OUT
AS
	BEGIN
	DECLARE @FriendType INT
	EXEC uspGetFriendTypeId 'Friend', @FriendType_Id = @FriendType OUT
		SET @Count = (SELECT COUNT(*) FROM FRIEND 
		WHERE (User1Id = @UserId OR User2Id = @UserId) 
		AND FriendTypeId = @FriendType)
	END
GO

-- making above into a function instead

ALTER FUNCTION fnCalculateFriendCount(@UserId INT)
RETURNS INT
AS
	BEGIN
	DECLARE @FriendTypeId INT = (SELECT FriendTypeId 
	FROM FRIEND_TYPE WHERE FriendType = 'Friend')
	
	DECLARE @Ret INT = (SELECT COUNT(*) FROM FRIEND 
		WHERE (User1Id = @UserId OR User2Id = @UserId) 
		AND FriendTypeId = @FriendTypeId)	
	RETURN @Ret
	END
GO

ALTER TABLE [USER]
ADD NumFriends AS dbo.fnCalculateFriendCount(UserId)

SELECT * FROM [User]