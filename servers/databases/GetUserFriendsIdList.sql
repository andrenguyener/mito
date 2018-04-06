ALTER PROC uspGetUserFriendsIdList
@UserId INT
AS
	DECLARE @NotFriendType INT
	EXEC uspGetFriendTypeId 'Pending', @FriendType_Id = @NotFriendType OUT
	DECLARE @totalFriendCount INT = (SELECT COUNT(*) FROM FRIEND WHERE (User1Id = @UserId OR User2Id = @UserId)
		AND FriendTypeId <> @NotFriendType)
	IF @totalFriendCount < 1
		BEGIN
		PRINT 'This user has no friend'
		RETURN
		END

	DECLARE @friendId INT

	SELECT * INTO #TempFriendTable FROM FRIEND WHERE (User1Id = @UserId OR User2Id = @UserId)
	AND FriendTypeId <> @NotFriendType
	DECLARE @friendUserId INT
	DECLARE @friendsIdList TABLE(FriendId INT)

	WHILE @totalFriendCount > 0
		BEGIN
			--get minimum friendid from temp table
			SET @friendId = (SELECT MIN(FriendId) FROM #TempFriendTable)
			-- get the friendId of given user
			SET @friendUserId = (SELECT User1Id FROM #TempFriendTable WHERE User1Id <> @UserId AND FriendId = @friendId)
			-- if not found (NULL), get the opposite friendId
			IF @friendUserId IS NULL
				BEGIN
					SET @friendUserId = (SELECT User2Id FROM #TempFriendTable WHERE FriendId = @friendId)
				END
			-- now that's the friend id is found, insert into the returning table
			INSERT @friendsIdList VALUES(@friendUserId)
			
			-- delete from temp table
			DELETE FROM #TempFriendTable WHERE FriendId = @friendId;
			--decrement loop count
			SET @totalFriendCount = @totalFriendCount - 1
		END
		SELECT * FROM @friendsIdList
GO

EXEC sp_rename 'GetUserFriendsIdList', 'uspGetUserFriendsIdList'