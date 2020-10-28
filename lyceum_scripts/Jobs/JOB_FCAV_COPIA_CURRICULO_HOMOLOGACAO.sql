DECLARE @hr INT
    
----------------------------------------------------------------------------
-- Cria o share para gravação do arquivo -----------------------------------
   
EXECUTE @hr = master.dbo.xp_cmdshell 'net use X: \\lyceumvb\Curriculos /USER:lyhomol #secu915@'

IF @hr <> 0
BEGIN
    RAISERROR ('[TR_FCAV_COPIA_CURRICULO] Erro ao mapear X:', 16, 1)
    RETURN
END

----------------------------------------------------------------------------
-- Loop principal ----------------------------------------------------------

UPDATE FCAV_TRG_MINI_CURRICULO
SET IN_PROCESS = 1

DECLARE cCursor CURSOR LOCAL FAST_FORWARD FOR
SELECT
    pes.PESSOA, pes.CPF, pes.PASSAPORTE,
    cv.NOME, cv.EXTENSAO, cv.DOCUMENTO_CURRICULO
FROM
    dbo.FCAV_TRG_MINI_CURRICULO ins
        INNER JOIN LY_PESSOA AS PES
        on PES.PESSOA = ins.PESSOA
        --
        INNER JOIN dbo.LY_MINI_CURRICULO cv
        ON cv.PESSOA = ins.PESSOA
WHERE ins.IN_PROCESS = 1
	and cv.EXTENSAO is not null
	and cv.DOCUMENTO_CURRICULO is not null
--
DECLARE @PESSOA     T_NUMERO
DECLARE @CPF        T_CPF
DECLARE @PASSAPORTE T_ALFAMEDIUM
--
DECLARE @NOME                T_ALFALARGE
DECLARE @EXTENSAO            T_ALFASMALL_10
DECLARE @DOCUMENTO_CURRICULO VARBINARY(MAX) -- T_IMAGEM não é válido para variável local
--
OPEN cCursor

FETCH cCursor INTO @PESSOA, @CPF, @PASSAPORTE, @NOME, @EXTENSAO, @DOCUMENTO_CURRICULO

WHILE @@FETCH_STATUS = 0
BEGIN	
    DECLARE @filePath VARCHAR(max)

	SET @filePath =
        'X:' +
        ISNULL(@CPF, @PASSAPORTE) + '_'+ CONVERT(VARCHAR, @PESSOA, 20) +
        '.' +                       -- A partir da versão 7.0 EXTENSAO passa a vir sem '.'
        REPLACE(@EXTENSAO, '.', '') -- Então, deve ser suprimido o '.' que vem na versão 6.0

    DECLARE @pctStr INT

    PRINT 'Before sp_OACreate'; EXECUTE @hr = sp_OACreate 'ADODB.Stream', @pctStr OUTPUT
    IF @hr <> 0 GOTO CLEANUP
    --
    PRINT 'Before sp_OASetProperty'; EXECUTE @hr = sp_OASetProperty @pctStr, 'Type', 1
    IF @hr <> 0 GOTO CLEANUP;
    --
    PRINT 'Before Open';       EXECUTE @hr = sp_OAMethod @pctStr, 'Open';                              IF @hr <> 0 GOTO CLEANUP;
	PRINT 'Before Write';      EXECUTE @hr = sp_OAMethod @pctStr, 'Write', NULL, @DOCUMENTO_CURRICULO; IF @hr <> 0 GOTO CLEANUP;
	PRINT 'Before SaveToFile'; EXECUTE @hr = sp_OAMethod @pctStr, 'SaveToFile', NULL, @filePath, 2;    IF @hr <> 0 GOTO CLEANUP;
	PRINT 'Before Close';      EXECUTE @hr = sp_OAMethod @pctStr, 'Close';                             IF @hr <> 0 GOTO CLEANUP;
    --
	EXECUTE @hr = sp_OADestroy @pctStr
    IF @hr <> 0 GOTO CLEANUP;

    CLEANUP:

    IF @hr <> 0  
    BEGIN
        DECLARE @source      VARCHAR(255)
        DECLARE @description VARCHAR(255)

        EXECUTE @hr =
            sp_OAGetErrorInfo
                @pctStr,
                @source OUTPUT, @description OUTPUT

        SET @description =
            '[JOB_FCAV_COPIA_CURRICULO] ' +
            @filePath + ' - ' +
            ISNULL(@description, '') + ' - ' +
            ISNULL(@source, '')

        RAISERROR(@description, 16, 1)

        RETURN
    END

    FETCH cCursor INTO @PESSOA, @CPF, @NOME, @PASSAPORTE, @EXTENSAO, @DOCUMENTO_CURRICULO
END

CLOSE cCursor
DEALLOCATE cCursor

----------------------------------------------------------------------------
-- Clean-up ----------------------------------------------------------------

DELETE dbo.FCAV_TRG_MINI_CURRICULO
WHERE IN_PROCESS = 1

EXECUTE xp_cmdshell 'net use X: /DELETE'
