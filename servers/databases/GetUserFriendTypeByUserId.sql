-- @params: users id 
-- returns the current friend type of these users
ALTER PROC uspcGetUserFriendTypeByUserId
@User1Id INT,
@User2Id INT,
@FriendType NVARCHAR(50) OUT
AS
	-- Check whether or not both of the given usernames are in the database
	IF @User1Id IS NULL OR @User2Id IS NULL
		BEGIN
			PRINT 'One or both of these users are not registered in our system'
			RAISERROR('@User1Id and @User2Id cannot be NULL', 11, 1)
			RETURN
		END
	DECLARE @FriendId INT
	EXEC dbo.uspGetFriendId @User1Id, @User2Id, @MatchedFriendId = @FriendId OUT
	
	IF @FriendId IS NULL
		BEGIN
		PRINT 'These users are not yet a friend'
		SET @FriendType = 'Friendship does not exist'
		END
	EXEC dbo.uspGetFriendTypeValue @FriendId, @CurrentFriendType = @FriendType OUT
GO

--example call
DECLARE @Test NVARCHAR(50)
EXEC dbo.uspcGetUserFriendTypeByUserId 7, 72, @FriendType = @Test OUT
PRINT @Test