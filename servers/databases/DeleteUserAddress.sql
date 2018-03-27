-- @param: UserAddressId that users want to delete
-- "Delete" the address from user address book based on the given UserAddressId
CREATE PROC uspDeleteUserAddress
@UserAddressId INT
AS
	IF @UserAddressId IS NULL
		BEGIN
			PRINT'The UserAddressId is not valid'
			RAISERROR('@UserAddressId cannot be null',11,1)
			RETURN
		END

	BEGIN TRAN
		UPDATE USER_ADDRESS
		SET IsDeleted = 1
		WHERE UserAddressId = @UserAddressId
		IF @@ERROR <> 0
			ROLLBACK TRAN
		ELSE
			COMMIT TRAN
GO

EXEC sp_rename 'DeleteUserAddress', 'uspDeleteUserAddress'