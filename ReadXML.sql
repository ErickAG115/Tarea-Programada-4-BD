USE [ProyectoBD]
GO 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET NOCOUNT ON

DECLARE @xmlData XML

SET @xmlData = (
		SELECT *
		FROM OPENROWSET(BULK 'C:\Users\eastorga\Documents\GitHub\-Tarea-Programada-BD-2-3\Datos_Tarea3.xml', SINGLE_BLOB) 
		AS xmlData
		);


INSERT INTO dbo.Departamentos(ID, NombreDep)
SELECT  
	T.Item.value('@Id', 'INT'),
	T.Item.value('@Nombre', 'VARCHAR(128)')
FROM @xmlData.nodes('Datos/Catalogos//Departamentos/Departamento') as T(Item)

INSERT INTO dbo.Puesto(ID,NombreP, SalarioXHora, Borrado)
SELECT 
	T.Item.value('@Id', 'INT'),
	T.Item.value('@Nombre', 'VARCHAR(128)'),
	T.Item.value('@SalarioXHora', 'MONEY'),
	1
FROM @xmlData.nodes('Datos/Catalogos/Puestos/Puesto') as T(Item)

INSERT INTO dbo.TipoDocIdentidad(ID, NombreTip)
SELECT  
	T.Item.value('@Id', 'INT'),
	T.Item.value('@Nombre', 'VARCHAR(128)')
FROM @xmlData.nodes('Datos/Catalogos/Tipos_de_Documento_de_Identificacion/TipoIdDoc') as T(Item)

INSERT INTO dbo.TipoJornada(ID,HoraEntrada,HoraSalida, NombreJ)
SELECT  
	T.Item.value('@Id', 'INT'),
	T.Item.value('@HoraEntrada', 'TIME'),
	T.Item.value('@HoraSalida', 'TIME'),
	T.Item.value('@Nombre', 'VARCHAR(128)')
FROM @xmlData.nodes('Datos/Catalogos/TiposDeJornada/TipoDeJornada') as T(Item)

INSERT INTO dbo.TipoDeduccion(ID,Nombre,Obligatorio, Porcentual, Valor)
SELECT  
	T.Item.value('@Id', 'INT'),
	T.Item.value('@Nombre', 'VARCHAR(128)'),
	T.Item.value('@Obligatorio', 'VARCHAR(128)'),
	T.Item.value('@Porcentual', 'VARCHAR(128)'),
	T.Item.value('@Valor', 'FLOAT')
FROM @xmlData.nodes('Datos/Catalogos/Deducciones/TipoDeDeduccion') as T(Item)

INSERT INTO dbo.Feriados(Fecha,Nombre)
SELECT  
	T.Item.value('@Fecha', 'DATE'),
	T.Item.value('@Nombre', 'VARCHAR(128)')
FROM @xmlData.nodes('Datos/Catalogos/Feriados/Feriado') as T(Item)

INSERT INTO dbo.TipoMovimiento(ID,Nombre)
SELECT  
	T.Item.value('@Id', 'INT'),
	T.Item.value('@Nombre', 'VARCHAR(128)')
FROM @xmlData.nodes('Datos/Catalogos/TiposDeMovimiento/TipoDeMovimiento') as T(Item)

SET NOCOUNT OFF