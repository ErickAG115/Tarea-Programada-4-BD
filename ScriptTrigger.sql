USE [ProyectoBD]
GO

CREATE TRIGGER TriggerDed ON dbo.Obrero
	AFTER INSERT
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @TipoDec INT;
	DECLARE @Monto MONEY;

	SELECT @TipoDec = TD.ID, @Monto = TD.Valor
	FROM dbo.TipoDeduccion TD 
	WHERE TD.Obligatorio = 'Si'

	INSERT dbo.Deducciones (IdObrero, IdTipoDeduccion, Monto)
	SELECT
		I.ID,
		@TipoDec,
		@Monto
	FROM INSERTED I

END