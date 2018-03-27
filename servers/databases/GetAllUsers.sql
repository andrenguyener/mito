/*
Get all users basic information
*/

CREATE PROC uspGetAllUsers 
As	
	--DECLARE @err_msg NVARCHAR(255)
	-- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.
	SET NOCOUNT ON
	IF EXISTS(SELECT * FROM [USER])
		BEGIN
		SELECT * FROM [USER]
		END
	ELSE
		BEGIN 
		PRINT'There is no user in the database'
		RAISERROR('No user not found.', 11,1)
		RETURN
		END

EXEC sp_rename 'GetAllUsers', 'uspGetAllUsers'