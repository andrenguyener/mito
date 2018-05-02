-- select all card information for a specific user
ALTER PROC uspcGetAllPaymentCards
@UserId INT
AS
BEGIN
	(SELECT UCC.CreditCardId, CardType, CardNumber, ExpMonth, ExpYear, CardCVV, IsDefault FROM USER_CREDIT_CARD UCC
	JOIN CREDIT_CARD CC ON UCC.CreditCardId = CC.CreditCardId
	WHERE UCC.UserId = @UserId AND UCC.IsDelete = 0)
END

--delete the card associated with the user
ALTER PROC uspcDeletePaymentCard
@UserId INT,
@CardId INT,
@IsDelete BIT
AS 
BEGIN
	IF NOT EXISTS (SELECT * FROM USER_CREDIT_CARD WHERE UserId = @UserId AND CreditCardId = @CardId)
		BEGIN
			PRINT'Unauthorized request to update card'
			RAISERROR('@UserId and @CardId does not match',11,1)
			RETURN
		END
	BEGIN TRAN deleteCard
	UPDATE USER_CREDIT_CARD
	SET IsDelete = @IsDelete WHERE UserId = @UserId AND CreditCardId = @CardId

	IF @@ERROR <> 0
	ROLLBACK TRAN deletedCard
	ELSE COMMIT TRAN deletedCard
END

--example call
EXEC dbo.uspcDeletePaymentCard 8,5,1
EXEC dbo.uspcGetAllPaymentCards 8
