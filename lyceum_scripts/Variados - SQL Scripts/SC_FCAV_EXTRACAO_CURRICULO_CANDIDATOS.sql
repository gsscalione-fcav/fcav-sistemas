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
--
DECLARE @PESSOA     T_NUMERO
DECLARE @CPF        T_CPF
DECLARE @PASSAPORTE T_ALFAMEDIUM
--
DECLARE @NOME                T_ALFALARGE
DECLARE @EXTENSAO            T_ALFASMALL_10
DECLARE @DOCUMENTO_CURRICULO VARBINARY(MAX) -- T_IMAGEM não é válido para variável local
--

SET @PESSOA = 99406


SELECT
    
    @CPF = pes.CPF, 
    @PASSAPORTE = pes.PASSAPORTE,
    @NOME =  cv.NOME, 
    @EXTENSAO = cv.EXTENSAO, 
    @DOCUMENTO_CURRICULO = cv.DOCUMENTO_CURRICULO
    
FROM
    dbo.FCAV_TRG_MINI_CURRICULO ins
        INNER JOIN LY_PESSOA AS PES
        on PES.PESSOA = ins.PESSOA
        --
        INNER JOIN dbo.LY_MINI_CURRICULO cv
        ON cv.PESSOA = ins.PESSOA
WHERE
	PES.PESSOA = @PESSOA


SELECT
    @CPF AS CPF, 
    @PASSAPORTE AS PASSAPORTE,
    @NOME AS NOME, 
    @EXTENSAO AS EXTENSAO, 
    @DOCUMENTO_CURRICULO AS DOCUMENTO_CURRICULO,
    len(@DOCUMENTO_CURRICULO)


    DECLARE @filePath VARCHAR(max)

	SET @filePath =
        'X:' +
        ISNULL(@CPF, @PASSAPORTE) + '_'+ CONVERT(VARCHAR, @PESSOA, 20) +
        '.' +                       -- A partir da versão 7.0 EXTENSAO passa a vir sem '.'
        REPLACE(@EXTENSAO, '.', '') -- Então, deve ser suprimido o '.' que vem na versão 6.0

	SELECT @filePath FILEPATH

    DECLARE @pctStr INT

    PRINT 'Before sp_OACreate'; EXECUTE sp_OACreate 'ADODB.Stream', @pctStr OUTPUT
   
    --
    PRINT 'Before sp_OASetProperty'; EXECUTE sp_OASetProperty @pctStr, 'Type', 1

    --
    PRINT 'Before Open';       EXECUTE sp_OAMethod @pctStr, 'Open';                              
	PRINT 'Before Write';      EXECUTE sp_OAMethod @pctStr, 'Write', NULL, @DOCUMENTO_CURRICULO; 
	PRINT 'Before SaveToFile'; EXECUTE sp_OAMethod @pctStr, 'SaveToFile', NULL, @filePath, 2;    
	PRINT 'Before Close';      EXECUTE sp_OAMethod @pctStr, 'Close';                             