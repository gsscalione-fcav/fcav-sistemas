--FUNÇÃO PARA VALIDAR COM MASCARA
CREATE FUNCTION [dbo].[UDF_ValidaCpfCnpj] (@TEXTO VARCHAR(20))
RETURNS BIT
AS
BEGIN
    DECLARE @CPF_CNPJ VARCHAR(20) = ''
  
    ;WITH SPLIT AS
    (
        SELECT 1 AS ID, SUBSTRING(@TEXTO, 1, 1) AS LETRA
        UNION ALL
        SELECT ID + 1, SUBSTRING(@TEXTO, ID + 1, 1)
        FROM SPLIT
        WHERE ID < LEN(@TEXTO)
    )
  
    SELECT @CPF_CNPJ += LETRA
    FROM SPLIT
    WHERE LETRA LIKE '[0-9]'
    OPTION(MAXRECURSION 0)
  
    IF LEN(@CPF_CNPJ) NOT IN (11, 14)
    BEGIN
        RETURN 0
    END
 
    DECLARE
        @I INT,
        @J INT = 1,
        @N INT = LEN(@CPF_CNPJ),
        @DIGITO1 INT = SUBSTRING(@CPF_CNPJ, LEN(@CPF_CNPJ) - 1, 1),
        @DIGITO2 INT = SUBSTRING(@CPF_CNPJ, LEN(@CPF_CNPJ), 1),
        @TOTAL_TMP INT,
        @COEFICIENTE_TMP INT,
        @DIGITO_TMP INT,
        @VALOR_TMP INT,
        @VALOR1 INT,
        @VALOR2 INT
  
    WHILE @J <= 2
    BEGIN
        SELECT
            @TOTAL_TMP = 0,
            @COEFICIENTE_TMP = 2,
            @I = @N + @J - 3
     
        WHILE @I >= 0
        BEGIN
            SELECT
                @DIGITO_TMP = SUBSTRING(@CPF_CNPJ, @I, 1),
                @TOTAL_TMP += @DIGITO_TMP * @COEFICIENTE_TMP,
                @COEFICIENTE_TMP = @COEFICIENTE_TMP + 1,
                @I -= 1
  
            IF @COEFICIENTE_TMP > 9 AND @N = 14
                SET @COEFICIENTE_TMP = 2
        END
  
        SET @VALOR_TMP = 11 - (@TOTAL_TMP % 11)
  
        IF (@VALOR_TMP >= 10)
            SET @VALOR_TMP = 0
  
        IF @J = 1
            SET @VALOR1 = @VALOR_TMP
        ELSE
            SET @VALOR2 = @VALOR_TMP
 
        SET @J += 1
    END
  
    RETURN
        CASE WHEN @VALOR1 = @DIGITO1 AND @VALOR2 = @DIGITO2
            THEN 1
            ELSE 0
        END
END   
GO
 
	
--FUNÇÃO PARA VALIDAR SEM MASCARA
CREATE FUNCTION [dbo].[UDF_ValidaCpfCnpj2] (@CPF_CNPJ VARCHAR(20))
RETURNS BIT
AS
BEGIN
    DECLARE
        @I INT,
        @J INT = 1,
        @N INT = LEN(@CPF_CNPJ),
        @DIGITO1 INT = SUBSTRING(@CPF_CNPJ, LEN(@CPF_CNPJ) - 1, 1),
        @DIGITO2 INT = SUBSTRING(@CPF_CNPJ, LEN(@CPF_CNPJ), 1),
        @TOTAL_TMP INT,
        @COEFICIENTE_TMP INT,
        @DIGITO_TMP INT,
        @VALOR_TMP INT,
        @VALOR1 INT,
        @VALOR2 INT
  
    WHILE @J <= 2
    BEGIN
        SELECT
            @TOTAL_TMP = 0,
            @COEFICIENTE_TMP = 2,
            @I = @N + @J - 3
     
        WHILE @I >= 0
        BEGIN
            SELECT
                @DIGITO_TMP = SUBSTRING(@CPF_CNPJ, @I, 1),
                @TOTAL_TMP += @DIGITO_TMP * @COEFICIENTE_TMP,
                @COEFICIENTE_TMP = @COEFICIENTE_TMP + 1,
                @I -= 1
  
            IF @COEFICIENTE_TMP > 9 AND @N = 14
                SET @COEFICIENTE_TMP = 2
        END
  
        SET @VALOR_TMP = 11 - (@TOTAL_TMP % 11)
  
        IF (@VALOR_TMP >= 10)
            SET @VALOR_TMP = 0
  
        IF @J = 1
            SET @VALOR1 = @VALOR_TMP
        ELSE
            SET @VALOR2 = @VALOR_TMP
 
        SET @J += 1
    END
  
    RETURN
        CASE WHEN @VALOR1 = @DIGITO1 AND @VALOR2 = @DIGITO2
            THEN 1
            ELSE 0
        END
END   
GO
 
	

--SELECT EXEMPLO PARA VALIDAR CPF/CNPJ
SELECT  
	CPF,
	CASE
		WHEN [dbo].[UDF_ValidaCpfCnpj] (cpf) = 1
			THEN  'Válido'
			ELSE 'Inválido'
		END AS VALIDA,*
FROM [2216_Motorista]
ORDER BY VALIDA DESC


-- SELECT MODELO SEM MASCARA
SELECT
    CASE WHEN [dbo].[UDF_ValidaCpfCnpj2] ('02841834000155') = 1 
    THEN 'Válido'
    ELSE 'Inválido'
    END

-- SELECT MODELO COM MASCARA
SELECT CASE
    WHEN [dbo].[UDF_ValidaCpfCnpj] ('02.841.834/0001-55') = 1 
    THEN 'Válido'
    ELSE 'Inválido'
    END
