DECLARE @schemaName VARCHAR(30)
    , @procName VARCHAR(30)
    , @fullName VARCHAR(60)

-- Cursor para percorrer os nomes dos objetos
DECLARE cursor_objects CURSOR FOR
    SELECT
          ROUTINE_SCHEMA
        , ROUTINE_NAME
    FROM
        INFORMATION_SCHEMA.ROUTINES
    WHERE
        ROUTINE_TYPE = 'PROCEDURE'

-- Abrindo Cursor para leitura
OPEN cursor_objects

-- Lendo a próxima linha
FETCH NEXT FROM cursor_objects INTO @schemaName, @procName

-- Percorrendo linhas do cursor (enquanto houverem)
WHILE @@FETCH_STATUS = 0
BEGIN

    SELECT @fullName = @schemaName + '.' + @procName

    EXEC sp_helptext @fullName

    -- Lendo a próxima linha
    FETCH NEXT FROM cursor_objects INTO @schemaName, @procName
END

-- Fechando Cursor para leitura
CLOSE cursor_objects

-- Desalocando o cursor
DEALLOCATE cursor_objects 