--assign the card as the default card and set every other card to non-default
CREATE PROC uspcUpdateUserDefaultPaymentCard
@UserId INT,
@ExistingCardId INT
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM USER_CREDIT_CARD WHERE UserId = @UserId AND CreditCardId = @ExistingCardId)
		BEGIN
			PRINT'Unauthorized request to update card'
			RAISERROR('@UserId and @ExistingCardId does not match',11,1)
			RETURN
		END
		
	BEGIN TRAN
		UPDATE USER_CREDIT_CARD
		SET IsDefault = 0
		WHERE UserId = @userId
		UPDATE USER_CREDIT_CARD
		SET IsDefault = 1 WHERE UserId = @UserId AND CreditCardId = @ExistingCardId
	IF @@ERROR <> 0
	ROLLBACK TRAN 
	ELSE COMMIT TRAN
END

--example call
EXEC dbo.uspcGetAllPaymentCards 8
EXEC dbo.uspcUpdateUserDefaultPaymentCard 8, 7
