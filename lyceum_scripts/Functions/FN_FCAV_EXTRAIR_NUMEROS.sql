/*
	FUNCTION FN_FCAV_EXTRAIR_NUMEROS
	
	Finalidade: Extrair os números do campo descrição da agenda para trazer os e-mails dos monitores.

	Autor: Gabriel Serrano Scalione
	Data: 18/12/2017
*/

use LYCEUM
go

CREATE FUNCTION FN_FCAV_EXTRAIR_NUMEROS(@string varchar(100)) 
returns varchar(100) 
AS 
  BEGIN 
      DECLARE @max   int, 
              @carac char(1), 
              @num   varchar(100) 

      SET @max = (SELECT Len(@string)) 
      SET @num = '' 

      WHILE @max > 0 
        BEGIN 
            SET @carac = (SELECT RIGHT(LEFT(@string, Len(@string) - @max + 1), 1 
                                 )) 

            IF @carac <> '' or @carac <> '.' or @carac <> '-'
              BEGIN 
                  IF isnumeric(@carac) = 1 
                    BEGIN 
                        SET @num = @num + @carac 
                    END 
              END 

            SET @max = @max - 1 
        END 

      RETURN @num 
  END 