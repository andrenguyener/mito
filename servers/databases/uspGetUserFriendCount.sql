-- returns the count of friend a user has
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