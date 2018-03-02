/*
@param: UserId
Return all information on the user's friends
*/

ALTER PROC GetUserFriendsById
@UserId INT
AS
	DECLARE @NotFriendType INT
	EXEC GetFriendTypeId'Pending', @FriendType_Id = @NotFriendType OUT

	IF @NotFriendType IS NULL
	BEGIN 
		PRINT'This friend type Id does not exist.'
		RAISERROR('@NotFriendType is not found in FRIEND_TYPE', 11,1)
		RETURN
	END

	DECLARE @friendsIdList TABLE(FriendId INT)
	INSERT @friendsIdList
	EXEC GetUserFriendsIdList @UserId

	IF EXISTS(SELECT * FROM FRIEND WHERE (User1Id = @UserId OR User2Id = @UserId)
		AND FriendTypeId <> @NotFriendType )
		BEGIN
		SELECT UserId, Username, UserFname, UserLname,UserEmail, PhotoUrl FROM [USER] U
		JOIN (SELECT * FROM @friendsIdList) UserFriendList
		ON U.UserId = UserFriendList.FriendId
		END
	ELSE
		BEGIN 
		PRINT'This user does not have any friend.'
		END