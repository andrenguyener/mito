-- Retrieve all users notifcation is that relevant for
-- them to see on their application
-- excluding: send a friend request, send a package
ALTER PROC uspcGetMyNotification
@UserId INT
AS
BEGIN
	SELECT NotificationId,SendFrom AS SendFromId, UserFname AS SenderFname, UserLname AS SenderLname, 
	Username AS SenderUsername, [Message], LinkToView  
	FROM [NOTIFICATION] N
	JOIN NOTIFICATION_TYPE NT ON N.NotificationTypeId = NT.NotificationTypeId
	JOIN [USER] U ON N.SendFrom = U.UserId
	WHERE SendTo = @UserId
	ORDER BY NotificationDate DESC
END
--example call
EXEC dbo.uspcGetMyNotification 72