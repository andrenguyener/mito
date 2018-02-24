CREATE PROC GetCurrentFriendTypeId
@FriendId INT,
@CurrentFriendType_Id INT OUT
AS
	SET @CurrentFriendType_Id = (SELECT FriendTypeId FROM FRIEND WHERE FriendId = @FriendId)
GO 