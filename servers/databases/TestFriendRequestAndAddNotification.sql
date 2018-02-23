-- EXEC insert new friendship into [FRIEND] table

-- EXEC insert two new users into [USER] table
DECLARE @pwd varbinary(max) = CAST('wat' AS VARBINARY(MAX))
EXEC insertUser @UserFname = 'Benny', 
				@UserLname = 'Souriyadeth', 
				@UserEmail = 'bennys@uw.edu',
				@PasswordHash = @pwd,
				@PhotoUrl = NULL,
				@UserDOB = '01-02-1995',
				@Username = 'bennys'
DECLARE @pwd2 varbinary(max) = CAST('wat' AS VARBINARY(MAX))
EXEC insertUser @UserFname = 'Victor', 
				@UserLname = 'Quach', 
				@UserEmail = 'victor@uw.edu',
				@PasswordHash = @pwd2,
				@PhotoUrl = NULL,
				@UserDOB = '01-02-1995',
				@Username = 'victor'
-- Benny sends a friend request to Victor
EXEC insertFriend @Username1 = 'bennys', @Username2 = 'victor', @FriendType = 'Pending'
-- Victor accepts the friend request from Benny
EXEC updateAcceptFriendRequest @Username1 = 'bennys', @Username2 = 'victor'

DELETE FROM [NOTIFICATION] WHERE NotificationTypeId = 2
SELECT * FROM FRIEND
SELECT * FROM FRIEND_TYPE
SELECT * FROM [NOTIFICATION]
SELECT * FROM NOTIFICATION_TYPE
SELECT * FROM [USER]
DELETE FROM [USER] WHERE UserFname = 'Benny' OR UserFname = 'Victor'
DELETE FROM FRIEND WHERE FriendId = 10

-- UPDATE TABLE [USER]
-- SET 