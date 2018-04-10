CREATE PROC uspGetUserConfirmationTypeId
@TypeName NVARCHAR(50),
@Type_Id INT OUT
AS
	BEGIN
		SET @Type_Id = (SELECT OrderUserConfirmationId FROM ORDER_USER_CONFIRMATION
		WHERE OrderUserConfirmation = @TypeName)
	END
GO

SELECT * FROM ORDER_USER_CONFIRMATION
INSERT INTO ORDER_USER_CONFIRMATION VALUES('Accepted'), ('Denied')
