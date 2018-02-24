CREATE PROC GetFriendTypeId
@FriendType NVARCHAR(25),
@FriendType_Id INT OUT
AS
	SET @FriendType_Id = (SELECT FriendTypeId FROM FRIEND_TYPE 
		WHERE FriendType = @FriendType)
GO