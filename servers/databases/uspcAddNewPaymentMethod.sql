--Add a new card to corresponding user
--error if the card month and year is not valid or earlier than current year 
--error if the card already exists in the user account
ALTER PROC uspcAddNewPaymentMethod
@UserId INT,
@CardTypeName NVARCHAR(50),
@CardNumber NVARCHAR(50), 
@ExpMonth TINYINT, 
@ExpYear SMALLINT,
@CardCVV SMALLINT
AS
BEGIN
	IF @UserId IS NULL 
	BEGIN
		PRINT'The user id is not valid'
		RAISERROR('@UserId cannot be null', 11,1)
		RETURN
	END

	IF @ExpMonth > 12 OR DATEDIFF(year, (SELECT GETDATE()),CAST(@ExpYear AS NVARCHAR)) < 0 
		BEGIN
			PRINT'Invalid value for payment method year or month'
			RAISERROR('@ExpMonth cannot be more than 12 and @ExpYear cannot be less than current year',11,1)
			RETURN
		END
	DECLARE @CardAlreadyExists BIT
	EXEC dbo.uspCheckIfUserCardExists @UserId, @CardNumber, @ExpMonth, @ExpYear, @CardCVV, @Found = @CardAlreadyExists OUT
	IF @CardAlreadyExists = 1
		BEGIN
			PRINT'This card already exists in your account'
			RAISERROR('@CardAlreadyExists cannot be 1. User can only add new card.', 11,1)
			RETURN
		END

	DECLARE @NewCardId INT
	DECLARE @TodaysDate DATETIME = (SELECT GETDATE())

	BEGIN TRAN AddNewUserCard
		BEGIN TRAN AddNewCard
			INSERT INTO CREDIT_CARD(CardType, CardNumber, ExpMonth, ExpYear, LastModifiedDate,CardCVV)
			VALUES(@CardTypeName, @CardNumber, @ExpMonth, @ExpYear, @TodaysDate,@CardCVV)
			SET @NewCardId = (SELECT SCOPE_IDENTITY())
			IF @@ERROR <> 0
			ROLLBACK TRAN AddNewCard
			ELSE COMMIT TRAN AddNewCard
			
			INSERT INTO USER_CREDIT_CARD(UserId, CreditCardId, IsDelete) VALUES(@UserId, @NewCardId, 0)

			IF @@ERROR <> 0
			ROLLBACK TRAN AddNewUserCard
			ELSE COMMIT TRAN AddNewUserCard
END

-- return the id of the card in CREDIT_CARD table
CREATE PROC uspGetCardId
@CardNumber NVARCHAR(50), 
@ExpMonth TINYINT, 
@ExpYear SMALLINT,
@CardCVV SMALLINT,
@Card_Id INT OUT
AS
BEGIN
	SET @Card_Id = (SELECT CreditCardId FROM CREDIT_CARD
	WHERE CardNumber = @CardNumber AND ExpMonth = @ExpMonth
	AND ExpYear = @ExpYear AND CardCVV = @CardCVV)
END
GO

-- return 1 if the card already exists with this user
CREATE PROC uspCheckIfUserCardExists
@UserId INT,
@CardNumber NVARCHAR(50), 
@ExpMonth TINYINT, 
@ExpYear SMALLINT,
@CardCVV SMALLINT,
@Found BIT OUT
AS
BEGIN
	DECLARE @CardId INT
	EXEC dbo.uspGetCardId @CardNumber, @ExpMonth, @ExpYear, @CardCVV, @Card_Id = @CardId OUT
	IF EXISTS(SELECT * FROM USER_CREDIT_CARD WHERE UserId = @UserId AND CreditCardId = @CardId)
	SET @Found = 1
END
GO

--Example call
EXEC dbo.uspcAddNewPaymentMethod 7, 'Visa', '1234465689', 12, 2018, 123