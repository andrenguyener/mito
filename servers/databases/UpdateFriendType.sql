CREATE PROC UpdateFriendType
@FriendId INT,
@FriendTypeId INT,
@Delete BIT
AS
	BEGIN TRAN
		UPDATE FRIEND
		SET FriendTypeId = @FriendTypeId, IsDeleted = @Delete
		WHERE FriendId = @FriendId
		IF @@ERROR<> 0
			ROLLBACK TRAN
		ELSE
			COMMIT TRAN
GO