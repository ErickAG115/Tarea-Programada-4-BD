use [ProyectoBD];

--------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS [dbo].[filtrarNombre];

CREATE PROCEDURE [dbo].[filtrarNombre]
	AS BEGIN
		SELECT [Puesto].[ID],[Puesto].[NombreP],[Puesto].[SalarioXHora] FROM [dbo].[Puesto] WHERE [Puesto].[Borrado] = 1 ORDER BY [Puesto].[NombreP] ;           
	END
GO
EXEC filtrarNombre
--------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS [dbo].[insertarPuesto];

CREATE PROCEDURE [dbo].[insertarPuesto] @inNombre NVARCHAR(128), @inSalario INT
	AS BEGIN
		INSERT INTO [dbo].[Puesto] ([NombreP], [SalarioXHora]) VALUES	(@inNombre,@inSalario);
	END
GO

EXEC insertarPuesto @inNombre = 'Seguridad', @inSalario = 1520
--------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS [dbo].[editarPuesto];

CREATE PROCEDURE [dbo].[editarPuesto] @inId INT, @inNombre NVARCHAR(128), @inSalario INT
	AS BEGIN
		UPDATE [dbo].[Puesto] SET [Puesto].[NombreP] = @inNombre,[Puesto].[SalarioXHora] = @inSalario WHERE [Puesto].[ID] = @inId;
	END
GO

EXEC [dbo].[editarPuesto] @inId = 1, @inNombre = 'yooooo', @inSalario = 1234;
--------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS [dbo].[listarEmpleados];

CREATE PROCEDURE [dbo].[listarEmpleados]
	AS BEGIN
		SELECT [Obrero].[ID], [Obrero].[Nombre], [Puesto].[NombreP], [TipoDocIdentidad].[NombreTip],[Obrero].[ValorDocIdentidad], [Obrero].[FechaNacimiento], [Departamentos].[NombreDep]  
		FROM [dbo].[Obrero] INNER JOIN [dbo].[Puesto] ON [Obrero].[Puesto] = [Puesto].[NombreP] INNER JOIN [dbo].[TipoDocIdentidad] ON [Obrero].[IdTipoDocIdentidad] = [TipoDocIdentidad].[ID] 
		INNER JOIN [dbo].[Departamentos] ON [Obrero].[IdDepartamento] = [Departamentos].[ID]
		WHERE [Obrero].[Borrado] = 1  ORDER BY [Puesto].[NombreP];           
	END
GO
EXEC [listarEmpleados]

-------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS [dbo].[insertarEmpleado];

CREATE PROCEDURE [dbo].[insertarEmpleado] @inNombre NVARCHAR(128), @inIdTipoDocIdentidad INT, @inValorDocIdentidad INT, @inPuesto NVARCHAR(128), @inFechaNacimiento NVARCHAR(128), @inIdDepartamento INT
	AS BEGIN
		INSERT INTO [dbo].[Obrero] ([Nombre], [idTipoDocIdentidad],[ValorDocIdentidad], [Puesto],[FechaNacimiento], [IdDepartamento]) VALUES	(@inNombre,@inIdTipoDocIdentidad, @inValorDocIdentidad, @inPuesto, CAST(@inFechaNacimiento as date), @inIdDepartamento);
	END
GO

EXEC [insertarEmpleado]

EXEC [dbo].[insertarEmpleado] @inNombre = 'Ken', @inIdTipoDocIdentidad = 1, @inValorDocIdentidad = 1122, @inPuesto = 'Guardia', @inFechaNacimiento = '20001204', @inIdDepartamento = 1

---------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS  [dbo].[listarEmpleadosFiltro];

CREATE PROCEDURE  [dbo].[listarEmpleadosFiltro] @inNombre NVARCHAR(128)
	AS BEGIN

		IF (@inNombre = '') -- excepcion forzada del programador
			SELECT [Obrero].[ID], [Obrero].[Nombre], [Puesto].[NombreP], [TipoDocIdentidad].[NombreTip],[Obrero].[ValorDocIdentidad], [Obrero].[FechaNacimiento], [Departamentos].[NombreDep]  
			FROM [dbo].[Obrero] INNER JOIN [dbo].[Puesto] ON [Obrero].[Puesto] = [Puesto].[NombreP] INNER JOIN [dbo].[TipoDocIdentidad] ON [Obrero].[IdTipoDocIdentidad] = [TipoDocIdentidad].[ID] 
			INNER JOIN [dbo].[Departamentos] ON [Obrero].[IdDepartamento] = [Departamentos].[ID]
			WHERE [Obrero].[Borrado] = 1  ORDER BY [Puesto].[NombreP];             
		ELSE
			SELECT [Obrero].[ID], [Obrero].[Nombre], [Puesto].[NombreP], [TipoDocIdentidad].[NombreTip],[Obrero].[ValorDocIdentidad], [Obrero].[FechaNacimiento], [Departamentos].[NombreDep]  
			FROM [dbo].[Obrero] INNER JOIN [dbo].[Puesto] ON [Obrero].[Puesto] = [Puesto].[NombreP] INNER JOIN [dbo].[TipoDocIdentidad] ON [Obrero].[IdTipoDocIdentidad] = [TipoDocIdentidad].[ID] 
			INNER JOIN [dbo].[Departamentos] ON [Obrero].[IdDepartamento] = [Departamentos].[ID] 
			WHERE [Obrero].[Borrado] = 1 AND [Obrero].[Nombre]  LIKE '%'+@inNombre+'%' ORDER BY [Puesto].[NombreP] ;

		END
GO

------------------------------------------------------
DROP PROCEDURE IF EXISTS [dbo].[editarEmpleado];

CREATE PROCEDURE [dbo].[editarEmpleado] @inId INT, @inNombre NVARCHAR(128), @inTipoDocIdentidad INT, @inValorDocIdentidad INT, @inFechaNacimiento NVARCHAR(128), @inIdDepartamento INT, @inPuesto NVARCHAR(128)
	AS BEGIN
		UPDATE [dbo].[Obrero] SET [Obrero].[Nombre] = @inNombre, [Obrero].[IdTipoDocIdentidad] = @inTipoDocIdentidad, [Obrero].[ValorDocIdentidad] = @inValorDocIdentidad, 
		[Obrero].[FechaNacimiento] = CAST(@inFechaNacimiento AS DATE), [Obrero].[IdDepartamento] = @inIdDepartamento, [Obrero].[Puesto] = @inPuesto WHERE [Obrero].[ID] = @inId;
	END
GO



------------------------------------------------------

DROP PROCEDURE IF EXISTS [dbo].[borrarEmpleado];

CREATE PROCEDURE [dbo].[borrarEmpleado] @inId INT
	AS BEGIN
		UPDATE [dbo].[Obrero] SET [Obrero].[Borrado] = 0 WHERE [Obrero].[ID] = @inId;
	END
GO

DROP PROCEDURE IF EXISTS [dbo].[borrarPuesto]

CREATE PROCEDURE [dbo].[borrarPuesto] @inId INT
	AS BEGIN
		UPDATE [dbo].[Puesto] SET [Puesto].[Borrado] = 0 WHERE [Puesto].[ID] = @inId;
	END
GO

DROP PROCEDURE IF EXISTS [dbo].[retornarUsers];

CREATE PROCEDURE [dbo].[retornarUsers]
	AS BEGIN
		SELECT [Usuarios].[UserName],[Usuarios].[Password] FROM [dbo].[Usuarios];
	END
GO

CREATE PROCEDURE [dbo].[retornarPuestos]
	AS BEGIN
		SELECT [Puesto].[NombreP] FROM [dbo].[Puesto];
	END
GO
-------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------Nuevos Stored procedures--------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS [dbo].[DeduccionesMonto];
-- Consulta el movimiento del obrero en un tiempo determinado 
CREATE PROCEDURE [dbo].[HorasMontos] @inIdUsuario INT, @inFechaInicio date, @inFechaFin date

	AS BEGIN
		SET NOCOUNT ON;
			SELECT [TipoMovimiento].[Nombre],
			[MovimientoCredito].[Monto]
			FROM [dbo].[Usuarios]
			INNER JOIN [dbo].[Obrero] ON [Obrero].[ID] = [Usuarios].[IdObrero]
			INNER JOIN [dbo].[Jornada] ON [Jornada].[ID] = [Obrero].[IdJornada]
			INNER JOIN [dbo].[MarcasDeAsistencia] ON [MarcasDeAsistencia].[IdJornada] = [Jornada].[ID]
			INNER JOIN [dbo].[MovimientoCredito] ON [MovimientoCredito].[IdAsistencia] = [MarcasDeAsistencia].[ID]
			INNER JOIN [dbo].[TipoMovimiento] ON [TipoMovimiento].[ID] = [MovimientoCredito].[IdTipoMov]
			WHERE @inIdUsuario = [Usuarios].[ID] AND 
			[MovimientoCredito].[Fecha] BETWEEN @inFechaInicio AND @inFechaFin
			ORDER BY [TipoMovimiento].[Nombre];
		SET NOCOUNT OFF;
	END
GO

EXEC [HorasMontos] @inIdUsuario = 2, @inFechaInicio = '2022-02-04', @inFechaFin = '2022-02-10'



-------------------------------------------------------------------------------------------------------------------------------

------DROP PROCEDURE [dbo].[SalariosAnuales]
-- Consulta los salario anuales del obrero
CREATE PROCEDURE [dbo].[SalariosAnuales] @inUsername VARCHAR(128)

	AS BEGIN
		SET NOCOUNT ON
			DECLARE @EMP INT
			SELECT @EMP = U.IdObrero FROM dbo.Usuarios U WHERE U.UserName = @inUsername
			SELECT PM.FechaInicio AS FechaInicio, PM.FechaFinal AS FechaFinal, PM.TotalDeducciones AS Deducciones, PM.SalarioTotal AS SalarioBruto, PM.SalarioNeto AS SalarioNeto
			FROM dbo.PlanillaMesXEmpleado PM
			WHERE PM.IdObrero = @EMP
		SET NOCOUNT OFF
	END
GO

EXEC [SalariosAnuales] @inUsername = 'LGomes'


-------------------------------------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS [dbo].[RetornarJueves]


CREATE PROCEDURE [dbo].[RetornarFinPlanillaMes] @inFecha DATE, @outFecha DATE OUTPUT --SE REALIZA UN CALCULO PARA RETORNAR EL JUEVES 
																					 --ANTES DEL PRIMER VIERNES DEL SIGUIENTE MES
	AS BEGIN

		SET NOCOUNT ON
		
		DECLARE @InicioMes DATE = DATEADD(DAY,1,EOMONTH(@inFecha))

		DECLARE @NumDia INT = DATEPART(WEEKDAY,@InicioMes)

		DECLARE @DiferenciaJ INT = 5-@NumDia

		DECLARE @Jueves DATE = DATEADD(DAY,@DiferenciaJ,@InicioMes)

		SELECT @outFecha = @Jueves

		SET NOCOUNT OFF
	END
GO

DECLARE @F DATE
EXECUTE RetornarFinPlanillaMes @inFecha = '2022-02-28', @outFecha = @F OUTPUT
SELECT @F

-------------------------------------------------------------------------------------------------------------------------------
-- Consulta las semanas del obrero
CREATE PROCEDURE [dbo].[ConsultaSemanas] @inUsername VARCHAR(128)
	AS BEGIN
		SET NOCOUNT ON

		DECLARE @EMP INT
		SELECT @EMP = U.IdObrero FROM dbo.Usuarios U WHERE U.UserName = @inUsername
		DECLARE @DOC INT 
		SELECT @DOC = O.ValorDocIdentidad FROM dbo.Obrero O WHERE O.ID = @EMP
		DECLARE @Planillas TABLE (ID INT IDENTITY(1,1), FechaInicio DATE, FechaFin DATE, SalarioBruto MONEY, SalarioNeto MONEY, Deducciones INT, HorasO INT, HorasE INT, HorasD INT)
		DECLARE @FirstID INT
		DECLARE @LastID INT
		DECLARE @FechaINI DATE
		DECLARE @FechaFIN DATE
		DECLARE @HO INT = 0
		DECLARE @HE INT = 0
		DECLARE @HD INT = 0

		INSERT @Planillas (FechaInicio,FechaFin,SalarioBruto,SalarioNeto,Deducciones,HorasO,HorasE,HorasD)
		SELECT PSE.FechaInicio, PSE.FechaFinal,PSE.SalarioTotal,PSE.SalarioNeto,PSE.TotalDeducciones,0,0,0
		FROM dbo.PlanillaSemanaXEmpleado PSE
		WHERE PSE.IdObrero = @EMP

		SELECT @FirstID = MIN(P.ID)
		FROM @Planillas P

		SELECT @LastID = MAX(P.ID)
		FROM @Planillas P

		WHILE (@FirstID<=@LastID)
		BEGIN
			SELECT @FechaINI = P.FechaInicio, @FechaFIN = p.FechaFin
			FROM @Planillas P
			WHERE P.ID = @FirstID

			SELECT @HO = SUM(MC.Horas)
			FROM dbo.MovimientoCredito MC
			INNER JOIN dbo.MarcasDeAsistencia MA ON MC.IdAsistencia = ma.ID
			WHERE MA.ValorTipoDocu = @DOC AND MC.IdTipoMov = 1 AND MC.Fecha BETWEEN @FechaINI AND @FechaFIN

			SELECT @HD = ISNULL(SUM(MC.Horas),0)
			FROM dbo.MovimientoCredito MC
			INNER JOIN dbo.MarcasDeAsistencia MA ON MC.IdAsistencia = ma.ID
			WHERE MA.ValorTipoDocu = @DOC AND MC.IdTipoMov = 3 AND MC.Fecha BETWEEN @FechaINI AND @FechaFIN

			SELECT @HE = ISNULL(SUM(MC.Horas),0)
			FROM dbo.MovimientoCredito MC
			INNER JOIN dbo.MarcasDeAsistencia MA ON MC.IdAsistencia = ma.ID
			WHERE MA.ValorTipoDocu = @DOC AND MC.IdTipoMov = 2 AND MC.Fecha BETWEEN @FechaINI AND @FechaFIN

			UPDATE @Planillas 
			SET HorasO = @HO, HorasE = @HE, HorasD = @HD
			WHERE ID = @FirstID
	
			SET @FirstID = @FirstID+1
		END
		SET NOCOUNT OFF
		SELECT P.FechaInicio AS FechaInicio,P.FechaFin AS FechaFinal,P.SalarioBruto AS SalarioBruto,P.SalarioNeto AS SalarioNeto,
		P.Deducciones AS Deducciones,P.HorasO AS HO,P.HorasE AS HE,P.HorasD AS HD 
		FROM @Planillas P
	END
GO

EXEC dbo.ConsultaSemanas @inUsername = 'LGomes'

-------------------------------------------------------------------------------------------------------------------------------
-- Consulta las deducciones del obrero
CREATE PROCEDURE [dbo].[ConsultarDeducciones] @inUsername VARCHAR(128), @inFechaIni VARCHAR(128), @inFechaFin VARCHAR(128)

	AS BEGIN
		SET NOCOUNT ON

		DECLARE @FInicio DATE = CAST(@inFechaIni AS DATE)
		DECLARE @FFin DATE = CAST(@inFechaFin AS DATE)
		DECLARE @EMP INT
		SELECT @EMP = U.IdObrero FROM dbo.Usuarios U WHERE U.UserName = @inUsername

		SELECT TD.Nombre AS Nombre, TD.Porcentual AS Porcentual, D.Monto AS Monto
		FROM dbo.MovimientoDebito MD
		INNER JOIN dbo.Deducciones D ON MD.IdDeduccion = D.ID
		INNER JOIN dbo.TipoDeduccion TD ON D.IdTipoDeduccion = TD.ID
		WHERE D.IdObrero = @EMP AND MD.Fecha BETWEEN @FInicio AND @FFin

		SET NOCOUNT OFF
	END
GO

EXEC ConsultarDeducciones @inUsername = 'LGomes', @inFechaIni = '2022-02-04', @inFechaFin = '2022-02-10'
-------------------------------------------------------------------------------------------------------------------------------
-- Consulta las asistencias del obrero
CREATE PROCEDURE [dbo].[ConsultarAsistencias] @inUsername VARCHAR(128), @inFechaIni VARCHAR(128), @inFechaFin VARCHAR(128)

	AS BEGIN
		
		DECLARE @FInicio DATE = CAST(@inFechaIni AS DATE)
		DECLARE @FFin DATE = CAST(@inFechaFin AS DATE)
		DECLARE @EMP INT
		SELECT @EMP = U.IdObrero FROM dbo.Usuarios U WHERE U.UserName = @inUsername
		DECLARE @DOC INT 
		SELECT @DOC = O.ValorDocIdentidad FROM dbo.Obrero O WHERE O.ID = @EMP

		SET NOCOUNT ON
		SELECT (TM.Nombre) AS Nombre, (MA.FechaEntrada) FechaEntrada, (MA.FechaSalida) AS FechaSalida, (MC.Horas) AS Horas, (MC.Monto) AS Monto 
		FROM dbo.MovimientoCredito MC
		INNER JOIN dbo.MarcasDeAsistencia MA ON MC.IdAsistencia = MA.ID
		INNER JOIN dbo.TipoMovimiento TM ON MC.IdTipoMov = TM.ID
		WHERE MA.ValorTipoDocu = @DOC AND MC.Fecha BETWEEN @FInicio AND @FFin
		SET NOCOUNT OFF
	END
GO

-------------------------------------------------------------------------------------------------------------------------------

EXEC dbo.ConsultarAsistencias @inUsername = 'LGomes', @inFechaIni = '2022-02-04', @inFechaFin = '2022-02-10'

CREATE TYPE [dbo].[Deduccion] AS TABLE(
    ID INT IDENTITY(1,1) NOT NULL,
	Monto MONEY NOT NULL,
	Porcentaje FLOAT NOT NULL,
	Porcentual VARCHAR(128) NOT NULL,
	IdDed INT NOT NULL,
	Obligatorio INT NOT NULL
)
GO
-- Transaccion del programa
CREATE PROCEDURE [dbo].[Transaccion] @inValorDocIdentidad INT, @inEntradaF SMALLDATETIME, @inSalidaF SMALLDATETIME, @inMontoGanadoHo MONEY, @inMontoGanadoHED MONEY, @inMontoGanadoHE MONEY,
									@inFechaItera DATE, @inHorasOrdinarias INT, @inHorasExtras INT, @inEsFinMes BIT, @inEsJueves BIT, @inFinNextMes DATE, @inIdEmpleado INT,
									@inSalarioNeto MONEY, @inDeduccionesObrero Deduccion READONLY, @inFechaIniMes DATE, @inFechaFinMes DATE, @OutResultCode INT OUTPUT

	AS BEGIN
		
		SET NOCOUNT ON
		DECLARE @NextDay DATE
		DECLARE @Deduccion INT
		DECLARE @MAXDeduccion INT
		DECLARE @SB INT
		DECLARE @SN INT
		DECLARE @TD INT
		BEGIN TRY
			SET @OutResultCode=0
			BEGIN TRANSACTION procesarAsistencia
				INSERT dbo.MarcasDeAsistencia(ValorTipoDocu,FechaEntrada,FechaSalida,IdJornada)
				SELECT @inValorDocIdentidad,@inEntradaF,@inSalidaF,O.IdJornada
				FROM dbo.Obrero O
				WHERE @inValorDocIdentidad = O.ValorDocIdentidad
				
				IF @inMontoGanadoHo>0
				BEGIN
					INSERT dbo.MovimientoCredito (Fecha,Monto,IdAsistencia,IdTipoMov,Horas)
					SELECT @inFechaItera, @inMontoGanadoHO, MAX(A.ID),1,@inHorasOrdinarias
					FROM dbo.MarcasDeAsistencia A
					WHERE @inMontoGanadoHo>0
				END
			
				IF @inMontoGanadoHED>0
				BEGIN
					INSERT dbo.MovimientoCredito (Fecha,Monto,IdAsistencia,IdTipoMov,Horas)
					SELECT @inFechaItera, @inMontoGanadoHED, MAX(A.ID),3,@inHorasExtras
					FROM dbo.MarcasDeAsistencia A
				END
				
				IF @inMontoGanadoHE>0
				BEGIN
					INSERT dbo.MovimientoCredito (Fecha,Monto,IdAsistencia,IdTipoMov,Horas)
					SELECT @inFechaItera, @inMontoGanadoHE, MAX(A.ID),2,@inHorasExtras
					FROM dbo.MarcasDeAsistencia A
				END
					
				IF @inEsFinMes = 1
				BEGIN
					
					SET @NextDay = DATEADD(DAY, 1, @inFechaItera)

					EXECUTE RetornarFinPlanillaMes @inFecha = @NextDay, @outFecha = @inFinNextMes OUTPUT
						
					INSERT dbo.PlanillaMesXEmpleado (FechaInicio,FechaFinal,SalarioNeto,SalarioTotal,TotalDeducciones,IdObrero)
					SELECT
						DATEADD(DAY, 1, @inFechaItera),
						@inFinNextMes,
						0,
						0,
						0,
						@inIdEmpleado

				END

				UPDATE dbo.PlanillaSemanaXEmpleado
				SET SalarioNeto = SalarioNeto + @inSalarioNeto
				WHERE IdObrero = @inIdempleado and @inFechaItera BETWEEN FechaInicio and FechaFinal

				UPDATE dbo.PlanillaMesXEmpleado
				SET  SalarioNeto = SalarioNeto + @inSalarioNeto				
				WHERE IdObrero = @inIdempleado AND @inFechaItera BETWEEN FechaInicio AND FechaFinal
				
				UPDATE dbo.PlanillaSemanaXEmpleado
				SET SalarioTotal=SalarioTotal + @inMontoGanadoHO+@inMontoGanadoHE+@inMontoGanadoHED
				WHERE IdObrero=@inIdEmpleado and @inFechaItera BETWEEN FechaInicio and FechaFinal

				IF @inEsJueves = 1
				BEGIN
					SELECT @Deduccion = MIN(DO.ID) FROM @inDeduccionesObrero DO
					SELECT @MAXDeduccion = MAX(DO.ID) FROM @inDeduccionesObrero DO

					WHILE (@Deduccion<=@MAXDeduccion)
					BEGIN
						INSERT dbo.MovimientoDebito (Fecha, Monto, IdDeduccion, IdTipoMov)
						SELECT
							@inFechaItera,
							DO.Monto,
							DO.IdDed,
							DO.Obligatorio
							FROM @inDeduccionesObrero DO
							WHERE DO.ID = @Deduccion
						SET @Deduccion = @Deduccion+1

						UPDATE PlanillaSemanaXEmpleado
						SET TotalDeducciones=TotalDeducciones+1
						WHERE IdObrero = @inIdempleado AND @inFechaItera BETWEEN FechaInicio AND FechaFinal

						UPDATE PlanillaMesXEmpleado
						SET TotalDeducciones=TotalDeducciones+1
						WHERE IdObrero = @inIdempleado AND @inFechaItera BETWEEN FechaInicio AND FechaFinal
						
					END

					INSERT dbo.PlanillaSemanaXEmpleado (FechaInicio,FechaFinal,SalarioNeto,SalarioTotal,TotalDeducciones,IdObrero,IdMes,IdJornada)
					SELECT
						(DATEADD(day, 1, @inFechaItera)),
						(DATEADD(day, 7, @inFechaItera)),
						(0),
						(0),
						(0),
						(@inIdempleado),
						(SELECT M.ID
						FROM dbo.PlanillaMesXEmpleado M
						WHERE (@inFechaItera BETWEEN M.FechaInicio AND M.FechaFinal) AND (IdObrero=@inIdempleado)),
						(SELECT O.IdJornada
						FROM dbo.Obrero O
						WHERE O.ValorDocIdentidad = @inValorDocIdentidad)
							
				END

				UPDATE dbo.PlanillaMesXEmpleado
				SET  SalarioTotal = SalarioTotal + (@inMontoGanadoHED+@inMontoGanadoHE+@inMontoGanadoHO)				
				WHERE IdObrero = @inIdempleado AND @inFechaItera BETWEEN FechaInicio AND FechaFinal
			
			COMMIT TRANSACTION procesarAsistencia
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT>0
			BEGIN
				ROLLBACK TRAN procesarAsistencia;
			END
			SET @OutResultCode=50005; -- Error de BD
				INSERT INTO dbo.Error
				(UserName
				, ErrorNumber
				, ErrorState
				, ErrorSeverity
				, ErrorLine
				, ErrorProcedure
				, ErrorMessage
				, ErrorDateTime)
			VALUES (
				SUSER_SNAME(),
				ERROR_NUMBER(),
				ERROR_STATE(),
				ERROR_SEVERITY(),
				ERROR_LINE(),
				ERROR_PROCEDURE(),
				ERROR_MESSAGE(),
				GETDATE()
			);
			END CATCH;
		SET NOCOUNT OFF
	END
GO

-------------------------------------------------------------------------------------------------------------------------------
-- Retorna la fecha de la semana
CREATE PROCEDURE [dbo].[RetornarFechaS] @inUsername VARCHAR(128)
	AS BEGIN
		SET NOCOUNT ON

		DECLARE @EMP INT
		SELECT @EMP = U.IdObrero FROM dbo.Usuarios U WHERE U.UserName = @inUsername

		SELECT (PS.FechaInicio) AS FechaInicio, (PS.FechaFinal) AS FechaFinal
		FROM dbo.PlanillaSemanaXEmpleado PS
		WHERE PS.IdObrero = @EMP

		SET NOCOUNT OFF
	END
GO

EXEC RetornarFechaS @inUsername = 'LGomes'

-------------------------------------------------------------------------------------------------------------------------------
-- Retorna la fecha del mes
CREATE PROCEDURE [dbo].[RetornarFechaM] @inUsername VARCHAR(128)
	AS BEGIN
		SET NOCOUNT ON

		DECLARE @EMP INT
		SELECT @EMP = U.IdObrero FROM dbo.Usuarios U WHERE U.UserName = @inUsername

		SELECT (PS.FechaInicio) AS FechaInicio, (PS.FechaFinal) AS FechaFinal
		FROM dbo.PlanillaMesXEmpleado PS
		WHERE PS.IdObrero = @EMP

		SET NOCOUNT OFF
	END
GO