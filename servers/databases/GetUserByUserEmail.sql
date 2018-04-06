/*
@param useremail
Find relevant user information based on the given email address
*/

ALTER PROC uspcGetUserByUserEmail
@Useremail NVARCHAR(100)
As	
	--DECLARE @err_msg NVARCHAR(255)
	-- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.
	SET NOCOUNT ON
	IF EXISTS(SELECT UserId FROM [USER] WHERE UserEmail = @Useremail)
		BEGIN
		SELECT * FROM [USER] WHERE UserEmail = @Useremail
		--FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
		END
	ELSE
		BEGIN 
		PRINT'This Useremail does not exist.'
		RAISERROR('Useremail is not found.', 11,1)
		RETURN
		END

EXEC sp_rename 'uspGetUserByUserEmail', 'uspcGetUserByUserEmail'

EXEC dbo.uspGetUserByUserEmail 'tombrady@uw.edu'