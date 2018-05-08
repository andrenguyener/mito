ALTER PROC uspcGetAllNonFriendUsers 
@UserId INT
AS
BEGIN
	-- stores the list of user1's friend in a table variable
	DECLARE @UserFriendIdList TABLE(FriendId INT)
	INSERT @UserFriendIdList
	EXEC uspGetUserFriendsIdList @UserId, 1
	
	SELECT UserId, UserFname, UserLname, UserEmail, PhotoUrl, UserDOB, Username FROM
	[USER] U
	LEFT JOIN @UserFriendIdList UF ON U.UserId = UF.FriendId 
	WHERE UF.FriendId IS NULL AND IsDelete = 0
	ORDER BY UserFname
END

EXEC dbo.uspcGetAllNonFriendUsers 7
