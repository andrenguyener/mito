-- Retrieve all users notifcation is that relevant for
-- them to see on their application
-- excluding: send a friend request, send a package
CREATE PROC uspcGetMyNotification
@UserId INT
AS
BEGIN
	SELECT * FROM [NOTIFICATION] N
	WHERE SendTo = @UserId
	ORDER BY NotificationDate DESC
END
--example call
EXEC dbo.uspcGetMyNotification 72


SELECT * FROM NOTIFICATION