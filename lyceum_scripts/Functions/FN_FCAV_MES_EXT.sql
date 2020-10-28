/*  
FN_FCAV_MES_EXT  
  
Função que retorna o MêS por extenso  
  
Autor: Gabriel S. Scalione  
Data: 18/02/2016  
*/  
  
ALTER FUNCTION FN_FCAV_MES_EXT  (@MES INT) RETURNS VARCHAR (20)  AS  
BEGIN  
  DECLARE @MES_EXT VARCHAR(20)  
    
  IF @MES=1   
    SET @MES_EXT ='Janeiro'  
  IF @MES=2   
    SET @MES_EXT ='Fevereiro'  
  IF @MES=3   
    SET @MES_EXT ='Março'  
  IF @MES=4   
    SET @MES_EXT ='Abril'  
  IF @MES=5   
    SET @MES_EXT ='Maio'  
  IF @MES=6   
    SET @MES_EXT ='Junho'  
  IF @MES=7   
    SET @MES_EXT ='Julho'  
  IF @MES=8   
    SET @MES_EXT ='Agosto'  
  IF @MES=9   
    SET @MES_EXT ='Setembro'  
  IF @MES=10   
    SET @MES_EXT ='Outubro'  
  IF @MES=11   
    SET @MES_EXT ='Novembro'  
  IF @MES=12   
    SET @MES_EXT ='Dezembro'  
  
  RETURN @MES_EXT  
END