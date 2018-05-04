-- return the matching user id
-- use to compare if the given exists
CREATE PROC uspGetMatchingUserId
@UserId INT,
@Id INT OUT
AS
	BEGIN
		SET @Id = (SELECT UserId FROM [USER] WHERE UserId = @UserId)
	END
GO
	