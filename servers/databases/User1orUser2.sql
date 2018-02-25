ALTER PROC User1orUser2
@UserFriendId INT,
@UserId INT,
@User1 BIT OUT
AS
	IF EXISTS (SELECT User1Id FROM FRIEND WHERE FriendId = @UserFriendId 
		AND User1Id = @UserId)
		BEGIN
		SET @User1 = 0
		END
	ELSE
		BEGIN
		SET @User1 = 1
		END
GO
