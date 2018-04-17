/*
@param: UserId
Return all information on the user's friends
*/

ALTER PROC uspcGetUserFriendsById
@UserId INT,
@IsFriend BIT
AS
	DECLARE @FriendTypeString NVARCHAR(50) = 'Friend'
	IF @IsFriend = 0 
	BEGIN
		SET @FriendTypeString = 'Pending'
	END

	DECLARE @NotFriendType INT
	EXEC uspGetFriendTypeId @FriendTypeString, @FriendType_Id = @NotFriendType OUT

	IF @NotFriendType IS NULL
	BEGIN 
		PRINT'This friend type Id does not exist.'
		RAISERROR('@NotFriendType is not found in FRIEND_TYPE', 11,1)
		RETURN
	END

	DECLARE @friendsIdList TABLE(FriendId INT)
	INSERT @friendsIdList
	EXEC uspGetUserFriendsIdList @UserId, @IsFriend

	IF EXISTS(SELECT * FROM FRIEND WHERE (User1Id = @UserId OR User2Id = @UserId)
		AND FriendTypeId = @NotFriendType )
		BEGIN
		SELECT UserId, Username, UserFname, UserLname,UserEmail, PhotoUrl, NumFriends
		FROM [USER] U
		JOIN (SELECT * FROM @friendsIdList) UserFriendList
		ON U.UserId = UserFriendList.FriendId
		--FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
		END
	ELSE
		BEGIN 
		PRINT'This user does not have any friend.'
		END

EXEC sp_rename 'uspGetUserFriendsById', 'uspcGetUserFriendsById'

