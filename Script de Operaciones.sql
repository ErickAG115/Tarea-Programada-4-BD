USE [ProyectoBD]
GO

/******Script Date: 5/19/2022 4:35:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET NOCOUNT ON

DECLARE @xmlData XML

SET @xmlData = (
		SELECT *
		FROM OPENROWSET(BULK 'C:\Users\eastorga\Documents\GitHub\Tarea-Programada-4-BD\Datos_Tarea3.xml', SINGLE_BLOB) 
		AS xmlData
		);

DECLARE @Fechas TABLE (ID INT IDENTITY (1, 1), fechaOperacion DATE)

DECLARE @Meses TABLE (ID INT IDENTITY (1, 1), fechaInicio DATE, fechaFin DATE)

DECLARE @EmpleadosInsertar TABLE (ID INT IDENTITY(1,1),FechaNacimiento DATE, Nombre VARCHAR(128), Passwrd VARCHAR(128),
		UserName VARCHAR(128),valorDocuIdent INT, IdDepartamento INT, IdPuesto INT, IdTipoDocu INT)

DECLARE @EmpleadosBorrar TABLE (ID INT IDENTITY(1,1),ValorDocuId INT)

DECLARE @InsertarDeducciones TABLE (ID INT IDENTITY(1,1),IdTipoDec INT, Monto MONEY, valorDocuIdent INT)

DECLARE @EliminarDeducciones TABLE (ID INT IDENTITY(1,1),IdTipoDec INT, valorDocuIdent INT)

DECLARE @asistencias TABLE (ID INT IDENTITY(1,1), ValorDocIdentidad VARCHAR(64), Entrada DATETIME, Salida DATETIME)

DECLARE @NuevosHorarios JornadasSigSemana

DECLARE @DeduccionesObrero Deduccion

DECLARE @EmpleadoSemana INT
DECLARE @MesSemana INT
DECLARE @DocSemana INT
DECLARE @lo INT
DECLARE @Deduccion INT
DECLARE @MaxDeduccion INT
DECLARE @hi INT
DECLARE @EntradaF SMALLDATETIME
DECLARE @SalidaF SMALLDATETIME
DECLARE @Entrada TIME
DECLARE @Salida TIME
DECLARE @ValorDocIdentidad INT
DECLARE @idempleado INT
DECLARE @HoraInicioJ TIME
DECLARE @HoraFinJ TIME
DECLARE @Jornada INT
DECLARE @horasOrdinarias INT
DECLARE @horasExtras INT
DECLARE @montoGanadoHO MONEY = 0
DECLARE @montoGanadoHED MONEY = 0
DECLARE @montoGanadoHE MONEY = 0
DECLARE @EntradaOP TIME
DECLARE @SalidaOP TIME
DECLARE @SalarioXHora INT
DECLARE @Extras BIT = 0
DECLARE @EsJueves BIT
DECLARE @EsFinMes BIT
DECLARE @SalarioNeto INT
DECLARE @Porcentual VARCHAR(128)
DECLARE @PrimerJID INT
DECLARE @FinalJID INT
DECLARE @JornadaSS INT
DECLARE @TJornadaSS INT
DECLARE @ObreroSS INT
DECLARE @ValorDocuSS INT
DECLARE @FirstEiId INT
DECLARE @LastEiId INT
DECLARE @FinMes DATE
DECLARE @FinNextMes DATE
DECLARE @FechaIniMes DATE
DECLARE @FechaFinMes DATE
DECLARE @errorTransaccion INT
DECLARE @inicioSigMes DATE


INSERT @Fechas (FechaOperacion)
SELECT T.Item.value('@Fecha', 'DATE')
FROM @xmlData.nodes('Datos/Operacion') as T(Item)

DECLARE @FechaItera DATE, @FechaFin DATE
SELECT @FechaItera=MIN(fechaOperacion), @FechaFin=MAX(fechaOperacion)
FROM @Fechas

INSERT dbo.Jornada (IdTipoJornada)
SELECT 1

SET @inicioSigMes = DATEADD(day, 1, @FechaItera)

EXECUTE RetornarFinPlanillaMeS @inFecha = @inicioSigMes, @outFecha = @FinMes OUTPUT

INSERT @Meses (fechaInicio, fechaFin)
SELECT @inicioSigMes, @FinMes
--

WHILE (@FechaItera<=@FechaFin)
BEGIN

	-- Si es el fin de semana, habra un nodo de "TipoDeJornadaProximaSemana", para eso se insertan las siguientes jornadas que se
	-- utilizaran como las nuevas de la siguiente semana
	IF @xmlData.exist('Datos/Operacion[@Fecha = sql:variable("@FechaItera")]/TipoDeJornadaProximaSemana') = 1
	BEGIN
		INSERT dbo.Jornada (IdTipoJornada)
		SELECT 1
		INSERT dbo.Jornada (IdTipoJornada)
		SELECT 2
		INSERT dbo.Jornada (IdTipoJornada)
		SELECT 3
	END

	-- Se obtiene el fin del mes para validaciones dentro de la transaccion
	SELECT @FinMes = MAX(M.fechaFin) FROM @Meses M

	IF @FechaItera = @FinMes
	BEGIN
		SET @inicioSigMes = DATEADD(day, 1, @FechaItera)
		EXECUTE RetornarFinPlanillaMes @inFecha = @inicioSigMes, @outFecha = @FinNextMes OUTPUT
		INSERT @Meses (fechaInicio, fechaFin)
		SELECT @inicioSigMes, @FinNextMes
	END

	-- Insercion de valores de los nodos dentro de la fecha de operacion
	INSERT @EmpleadosInsertar (FechaNacimiento, Nombre, Passwrd, UserName, valorDocuIdent, IdDepartamento, IdPuesto, IdTipoDocu)
	SELECT 
		T.Item.value('@FechaNacimiento', 'DATE'),
		T.Item.value('@Nombre', 'VARCHAR(128)'),
		T.Item.value('@Password', 'VARCHAR(128)'),
		T.Item.value('@Username', 'VARCHAR(128)'),
		T.Item.value('@ValorDocumentoIdentidad', 'INT'),
		T.Item.value('@idDepartamento', 'INT'),
		T.Item.value('@idPuesto', 'INT'),
		T.Item.value('@idTipoDocumentacionIdentidad', 'INT')
	FROM @xmlData.nodes('Datos/Operacion[@Fecha = sql:variable("@FechaItera")]/NuevoEmpleado') as T(Item)
	
	INSERT @EmpleadosBorrar (ValorDocuId)
	SELECT 
		T.Item.value('@ValorDocumentoIdentidad', 'INT')
	FROM @xmlData.nodes('Datos/Operacion[@Fecha = sql:variable("@FechaItera")]/EliminarEmpleado') as T(Item)
	
	INSERT @InsertarDeducciones (IdTipoDec, Monto, valorDocuIdent)
	SELECT 
		T.Item.value('@IdDeduccion', 'INT'),
		T.Item.value('@Monto', 'MONEY'),
		T.Item.value('@ValorDocumentoIdentidad', 'INT')
	FROM @xmlData.nodes('Datos/Operacion[@Fecha = sql:variable("@FechaItera")]/AsociaEmpleadoConDeduccion') as T(Item)
	
	INSERT @EliminarDeducciones (IdTipoDec, valorDocuIdent)
	SELECT 
		T.Item.value('@IdDeduccion', 'INT'),
		T.Item.value('@ValorDocumentoIdentidad', 'INT')
	FROM @xmlData.nodes('Datos/Operacion[@Fecha = sql:variable("@FechaItera")]/DesasociaEmpleadoConDeduccion') as T(Item)

	INSERT @asistencias (ValorDocIdentidad, Entrada, Salida)
	SELECT 
		T.Item.value('@ValorDocumentoIdentidad', 'INT'),
		T.Item.value('@FechaEntrada', 'SMALLDATETIME'),
		T.Item.value('@FechaSalida', 'SMALLDATETIME')
	FROM @xmlData.nodes('Datos/Operacion[@Fecha = sql:variable("@FechaItera")]/MarcaDeAsistencia') as T(Item)
	
	INSERT @NuevosHorarios (IdJornada, ValorDocIdent)
	SELECT
		T.Item.value('@IdJornada', 'INT'),
		T.Item.value('@ValorDocumentoIdentidad', 'INT')
	FROM @xmlData.nodes('Datos/Operacion[@Fecha = sql:variable("@FechaItera")]/TipoDeJornadaProximaSemana') as T(Item)
	
	-- Se valida que hayan empleados por insertar
	IF @xmlData.exist('Datos/Operacion[@Fecha = sql:variable("@FechaItera")]/NuevoEmpleado') = 1
	BEGIN

		
		INSERT dbo.Obrero(Nombre, IdTipoDocIdentidad, ValorDocIdentidad, IdPuesto,FechaNacimiento,IdDepartamento,IdJornada)
		SELECT E.Nombre, E.IdTipoDocu, E.valorDocuIdent, E.IdPuesto, E.FechaNacimiento,E.IdDepartamento,1
		FROM @EmpleadosInsertar E

		-- Se crea un planilla default para su primer mes
		INSERT dbo.PlanillaMesXEmpleado (FechaInicio,FechaFinal,SalarioNeto,SalarioTotal,TotalDeducciones,IdObrero)
		SELECT
			(SELECT MAX(M.fechaInicio) FROM @Meses M),
			(SELECT MAX(M.fechaFin) FROM @Meses M),
			0,
			0,
			0,
			O.Id
			FROM @EmpleadosInsertar EI
			INNER JOIN dbo.Obrero O ON EI.valorDocuIdent=O.ValorDocIdentidad
		
		-- Se insertan los usuarios de cada empleado nuevo para que puedan ingresar a la app web
		INSERT dbo.Usuarios (UserName, Password, EsAdmin, IdObrero)
		SELECT EXML.UserName, EXML.Passwrd, 0, O.Id
		FROM @EmpleadosInsertar EXML
		INNER JOIN dbo.Obrero O ON EXML.valorDocuIdent=O.ValorDocIdentidad

		
		SELECT @FirstEiId = MIN(EI.ID), @LastEiId = MAX(EI.ID)
		FROM @EmpleadosInsertar EI

		-- Se realiza un while para crear la primera semana de cada empleado nuevo
		WHILE(@FirstEiId<=@LastEiId)
		BEGIN

			SELECT @DocSemana = EI.valorDocuIdent
			FROM @EmpleadosInsertar EI
			WHERE EI.ID = @FirstEiId

			SELECT @EmpleadoSemana = O.ID
			FROM dbo.Obrero O
			WHERE O.ValorDocIdentidad = @DocSemana

			SELECT @MesSemana = M.ID
			FROM dbo.PlanillaMesXEmpleado M
			WHERE M.IdObrero = @EmpleadoSemana AND DATEADD(day, 1, @FechaItera) BETWEEN M.FechaInicio AND M.FechaFinal

			INSERT dbo.PlanillaSemanaXEmpleado (FechaInicio,FechaFinal,SalarioNeto,SalarioTotal,TotalDeducciones,IdObrero,IdMes,IdJornada)
			SELECT
				(DATEADD(day, 1, @FechaItera)),
				(DATEADD(day, 7, @FechaItera)),
				(0),
				(0),
				(0),
				(@EmpleadoSemana),
				(@MesSemana),
				(1)

			SET @FirstEiId = @FirstEiId+1
		END
	END

	IF @xmlData.exist('Datos/Operacion[@Fecha = sql:variable("@FechaItera")]/AsociaEmpleadoConDeduccion') = 1
	BEGIN
	
	-- Insertar deduccion no obligatorias
    INSERT dbo.Deducciones (IdObrero,IdTipoDeduccion,Monto)
	SELECT O.Id, D.IdTipoDec, D.Monto
	FROM @InsertarDeducciones D
	INNER JOIN dbo.Obrero O ON D.valorDocuIdent=O.ValorDocIdentidad
	END
	
	-- desasociar (eliminar deducciones) ...

	IF @xmlData.exist('Datos/Operacion[@Fecha = sql:variable("@FechaItera")]/DesasociaEmpleadoConDeduccion') = 1
	BEGIN

		UPDATE dbo.Deducciones
		SET Activa = 0
		FROM @EliminarDeducciones E
		INNER JOIN dbo.Deducciones D ON E.IdTipoDec = D.IdTipoDeduccion
		INNER JOIN dbo.Obrero O ON E.valorDocuIdent = O.ValorDocIdentidad
		WHERE (O.ValorDocIdentidad = E.valorDocuIdent) AND (D.IdObrero = O.ID)

	END
		
	-- Procesar asistencias

	IF @xmlData.exist('Datos/Operacion[@Fecha = sql:variable("@FechaItera")]/MarcaDeAsistencia') = 1
	BEGIN

		SELECT @lo=Min(A.ID), @hi=Max(A.ID)
		FROM @asistencias A
	
		-- Inicio de proceso de asistencias
		WHILE (@lo<=@hi)
		BEGIN

			-- SET de variables necesarias para varios calculos
			SET @SalarioNeto = 0

			SELECT @Entrada=A.Entrada, @Salida=A.Salida, @ValorDocIdentidad=A.ValorDocIdentidad
			FROM @asistencias A
			WHERE A.ID=@lo;

			-- @EntradaF y @SalidaF hacen referfencia a Entrada/Salida con Fecha
			-- la diferencia con @Entrada y @Salida es que las anteriores

			SELECT @EntradaF=A.Entrada, @SalidaF=A.Salida, @ValorDocIdentidad=A.ValorDocIdentidad
			FROM @asistencias A
			WHERE A.ID=@lo;
			
			-- Estas variables se utilizan para las transacciones
			-- El @valorDocIdentidad es lo que mas se usa para mapear valores al igual que @idempleado
			SELECT @idempleado=E.Id, @Jornada=E.IdJornada
			FROM dbo.Obrero E
			WHERE E.ValorDocIdentidad=@ValorDocIdentidad

			SELECT @SalarioXHora = P.SalarioXHora
			FROM dbo.Puesto P
			INNER JOIN dbo.Obrero O ON P.ID = O.IdPuesto
			WHERE @idempleado = O.ID
			
			-- Estas fechas son las que se utilizan para mapear el mes que se debe actualizar
			SELECT @FechaFinMes = M.FechaFinal
			FROM PlanillaMesXEmpleado M
			WHERE M.IdObrero = @idEmpleado AND @FechaItera BETWEEN M.FechaInicio and M.FechaFinal

			SELECT @FechaIniMes = M.FechaInicio
			FROM PlanillaMesXEmpleado M
			WHERE M.IdObrero = @idEmpleado AND @FechaItera BETWEEN M.FechaInicio and M.FechaFinal

			-- Determinar horas ordinarias
			-- determinar la jornada de esta semana de ese empleado
			SELECT @HoraInicioJ=TJ.HoraEntrada, @HoraFinJ=TJ.HoraSalida
			FROM dbo.TipoJornada TJ
			INNER JOIN dbo.Jornada J on TJ.ID=J.IdTipoJornada
			WHERE (J.ID = @Jornada)
			
			-- determinar horas ordinarias
			-- @EntradaOP y @SalidaOP hace referencia a las variables para la operacion de calculo de horas trabajadas
			IF @Entrada>@HoraInicioJ
			BEGIN
				SET @EntradaOP = @Entrada;
			END

			ELSE
			BEGIN
				SET @EntradaOP = @HoraInicioJ;
			END

			-- Se calcula si hubo tiempo extra
			IF @Salida>@HoraFinJ
			BEGIN
				SET @SalidaOP = @HoraFinJ;
				SET @Extras = 1;
			END

			ELSE
			BEGIN
				SET @SalidaOP = @Salida;
			END

			-- Definicion de horas, extras y el monto ganado por horas ordinarias
			SET @horasOrdinarias = (DATEDIFF(MI,@EntradaOP, @SalidaOP))/60;
						
			SET @montoGanadoHO = @horasOrdinarias*@SalarioXHora
			
			SET @horasExtras = (DATEDIFF(MI,@HoraFinJ, @Salida))/60;

			-- Se realiza el calculo del monto ganado por horas extra
			IF @Extras=1
			BEGIN

				-- Se revisa que las horas extra sean dentro de feriado o domingo, de no serlo se realiza el otro calculo
				IF ((EXISTS(SELECT F.FECHA FROM FERIADOS F WHERE F.Fecha=@FechaItera)) OR (DATENAME(WEEKDAY,@FechaItera)='Sunday')) AND @horasExtras>0
				BEGIN
				
					--- determinar horas extraordinarias dobles  y monto
					SET @montoGanadoHED = (@horasExtras*@SalarioXHora)*2;
								
					END 
				ELSE 
				BEGIN
					--- determinar horas extraordinarias normales y moto
					SET @montoGanadoHE = (@horasExtras*@SalarioXHora)*1.5;
							
				END
			END
			SET @EsJueves = 0

			-- Insercion de las deducciones a realizar al empleado
			IF (DATENAME(WEEKDAY,@FechaItera)='Thursday')
			BEGIN
				SET @EsJueves = 1

				-- Se utiliza una tabla variable para luego recorrerla con un while y aplicar las deducciones en orden
				-- Insercion de obligatorias
				INSERT @DeduccionesObrero (Monto,Porcentaje,Porcentual,IdDed,Obligatorio)
				SELECT
					D.Monto,
					TD.Valor,
					TD.Porcentual,
					D.ID,
					4
					FROM dbo.Deducciones D
					INNER JOIN dbo.TipoDeduccion TD ON D.IdTipoDeduccion = TD.ID
					WHERE D.IdObrero = @idempleado AND TD.Obligatorio = 'Si' AND D.Activa = 1

				-- Insercion de porcentuales
				INSERT @DeduccionesObrero (Monto,Porcentaje,Porcentual,IdDed,Obligatorio)
				SELECT
				D.Monto,
				TD.Valor,
				TD.Porcentual,
				D.ID,
				5
				FROM dbo.Deducciones D
				INNER JOIN dbo.TipoDeduccion TD ON D.IdTipoDeduccion = TD.ID
				WHERE D.IdObrero = @idempleado AND TD.Obligatorio = 'No' AND D.Activa = 1 AND TD.Porcentual = 'Si'

				-- Insercion de no porcentuales
				INSERT @DeduccionesObrero (Monto,Porcentaje,Porcentual,IdDed,Obligatorio)
				SELECT
				D.Monto,
				TD.Valor,
				TD.Porcentual,
				D.ID,
				5
				FROM dbo.Deducciones D
				INNER JOIN dbo.TipoDeduccion TD ON D.IdTipoDeduccion = TD.ID
				WHERE D.IdObrero = @idempleado AND TD.Obligatorio = 'No' AND D.Activa = 1 AND TD.Porcentual = 'No'

				SELECT @Deduccion = MIN(DO.ID) FROM @DeduccionesObrero DO
				SELECT @MAXDeduccion = MAX(DO.ID) FROM @DeduccionesObrero DO

				-- Se obtiene el salario total para aplicarle las deducciones
				SELECT @SalarioNeto = S.SalarioTotal + @montoGanadoHO+@montoGanadoHE+@montoGanadoHED
				FROM dbo.PlanillaSemanaXEmpleado S
				WHERE S.IdObrero = @idempleado

				-- Porcesado de deducciones y definicion del salario neto
				WHILE (@Deduccion<=@MAXDeduccion)
				BEGIN
					SELECT @Porcentual = DO.Porcentual
					FROM @DeduccionesObrero DO
					WHERE DO.ID = @Deduccion

					-- Se realiza el calculo necesario dependiendo de si es porcentual o no
					IF @Porcentual = 'Si'
					BEGIN
						SELECT @SalarioNeto = @SalarioNeto-(@SalarioNeto*DO.Porcentaje)
						FROM @DeduccionesObrero DO
						WHERE DO.ID = @Deduccion
					END

					ELSE
					BEGIN
						SELECT @SalarioNeto = @SalarioNeto-DO.Monto
						FROM @DeduccionesObrero DO
						WHERE DO.ID = @Deduccion
					END

					SET @Deduccion = @Deduccion+1
				END
			END
			SET @EsFinMes=0
			IF (@FechaItera = @FechaFinMes)
			BEGIN
				SET @EsFinMes=1
			END
			
			-- Ejecucion de la transaccion
			EXEC dbo.Transaccion @inValorDocIdentidad = @valorDocIdentidad, @inEntradaF = @EntradaF, @inSalidaF = @SalidaF, @inMontoGanadoHo = @montoGanadoHo, @inMontoGanadoHED = @montoGanadoHED, @inMontoGanadoHE = @montoGanadoHE,
					@inFechaItera = @FechaItera, @inHorasOrdinarias = @HorasOrdinarias, @inHorasExtras = @horasExtras, @inEsFinMes = @EsFinMes, @inEsJueves = @EsJueves, @inFinNextMes = @FinNextMes, @inIdEmpleado = @idempleado,
					@inSalarioNeto = @SalarioNeto, @inDeduccionesObrero = @DeduccionesObrero, @inFechaIniMes = @FechaIniMes, @inFechaFinMes = @FechaFinMes, @inNuevosHorarios = @NuevosHorarios, @outResultCode = @errorTransaccion OUTPUT
			
			-- SET a la siguiente asistencia para continuar el loop
			SET @lo = @lo +1 
			DELETE FROM @DeduccionesObrero
			SET @Extras = 0
			SET @montoGanadoHO = 0
			SET @montoGanadoHED = 0
			SET @montoGanadoHE = 0
		END
	END

	-- Aca se procesan unicamente los empleados nuevos para asignarles su siguiente jornada ya que a los empleados
	-- existentes se les asigna la nueva jornada dentro de la transaccion
	IF @xmlData.exist('Datos/Operacion[@Fecha = sql:variable("@FechaItera")]/TipoDeJornadaProximaSemana') = 1
	BEGIN

		SELECT @PrimerJID = MIN(NH.ID) FROM @NuevosHorarios NH
		SELECT @FinalJID = MAX(NH.ID) FROM @NuevosHorarios NH

		-- Se navegan todas las identificaciones dentro de la tabla de nuevos horarios para ver a
		-- quien se le debe asignar la nueva jornada
		WHILE(@PrimerJID<=@FinalJID)
		BEGIN
			
			-- Mapeo de valor de documento para mapear el id del empleado
			SELECT @ValorDocuSS = NH.ValorDocIdenT 
			FROM @NuevosHorarios NH
			WHERE  NH.ID = @PrimerJID

			-- Verifica que sea un empleado nuevo al que se le esta asignando la nueva jornada
			IF EXISTS(SELECT EI.valorDocuIdent FROM @EmpleadosInsertar EI WHERE EI.valorDocuIdent = @ValorDocuSS)
			BEGIN
				SELECT @ObreroSS = O.ID 
				FROM dbo.Obrero O
				WHERE O.ValorDocIdentidad = @ValorDocuSS

				SELECT @TJornadaSS = NH.IdJornada 
				FROM @NuevosHorarios NH
				WHERE  NH.ID = @PrimerJID

				SELECT @JornadaSS = MAX(J.ID)
				FROM dbo.Jornada J
				WHERE J.IdTipoJornada = @TJornadaSS

				UPDATE dbo.Obrero
				SET IdJornada = @JornadaSS
				WHERE ID = @ObreroSS

				UPDATE dbo.PlanillaSemanaXEmpleado
				SET IdJornada = @JornadaSS
				WHERE IdObrero = @ObreroSS AND DATEADD(day, 1, @FechaItera) BETWEEN FechaInicio AND FechaFinal
			END

			SET @PrimerJID = @PrimerJID+1
		END
	END

	-- Se eliminan los empleados en el caso que la operacion exista
	IF @xmlData.exist('Datos/Operacion[@Fecha = sql:variable("@FechaItera")]/EliminarEmpleado') = 1
	BEGIN
		UPDATE dbo.Obrero
		SET Borrado = 1
		FROM @EmpleadosBorrar EB
		WHERE EB.ValorDocuId = ValorDocIdentidad
	END

	-- Reseteo de tablas variable para empezar la siguiente fecha de operacion
	DELETE FROM @asistencias
	DELETE FROM @EmpleadosBorrar
	DELETE FROM @EliminarDeducciones
	DELETE FROM @NuevosHorarios
	DELETE FROM @EmpleadosInsertar
	DELETE FROM @InsertarDeducciones
	SET @FechaItera = DATEADD(day, 1, @FechaItera)
	
END
SET NOCOUNT OFF