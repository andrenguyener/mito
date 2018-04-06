/*
A stored procedure that gets the FriendType Id based on the given FriendType string
@param a valid FriendType string
output param: FriendTypeId according to the given FriendType name
*/

ALTER PROC uspGetFriendTypeId
@FriendType NVARCHAR(25),
@FriendType_Id INT OUT
AS
	SET @FriendType_Id = (SELECT FriendTypeId FROM FRIEND_TYPE 
		WHERE FriendType = @FriendType)
GO

EXEC sp_rename 'GetFriendTypeId', 'uspGetFriendTypeId'