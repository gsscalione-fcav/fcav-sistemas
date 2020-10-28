 
DECLARE  
@CC VARCHAR (20),  
@NOME VARCHAR (200),  
@CURSO VARCHAR (200),  
@COMPLEMENTO VARCHAR (2000), 
--@p_boleto_cobranca varchar (20),  
@p_descricao varchar (2000)  
  
  
  
SET @CC = '.'  
SET @NOME = '.'  
SET @CURSO = '.'  
SET @COMPLEMENTO = '.'  
--SET @p_boleto_cobranca = '26522'--'26531'  
set @p_descricao = '.'  
--------------------------------------------------------  
  
SELECT   
 --@NOME			= ISNULL(NOME_COMPL,'.'),  
 --@CURSO			= ISNULL(CS.NOME,'.'),  
 --@CC			= ISNULL(TU.CENTRO_DE_CUSTO,'.'),  
 --@COMPLEMENTO	= ISNULL(IL.DESCRICAO,'.')  --SÓ PRA TESTE
  *
FROM   
 LY_ALUNO AL
 INNER JOIN LY_ITEM_LANC IL 
	ON IL.ALUNO = AL.ALUNO
 INNER JOIN LY_TURMA TU
	ON TU.CURSO = AL.CURSO
	AND TU.TURNO = AL.TURNO
	AND TU.CURRICULO = AL.CURRICULO
 INNER JOIN LY_CURSO CS
	ON CS.CURSO = TU.CURSO

WHERE   
 IL.BOLETO in (78485)  
  
--------------------------------------------------------  
  
   
  
 SELECT DISTINCT   
  
 'Aluno: '+@NOME+  
 char(124)+'Curso: '+@CURSO+  
-- *********** char(13) + char(10)+'Vencimento: '+CONVERT(CHAR(10),DATA_DE_VENCIMENTO,103)+  
 char(124)+'CC: '+@CC +  
 char(124)+char(124)+@COMPLEMENTO +  
 char(124)+char(124)+'Valor aproximado dos Impostos:'+  
 char(124)+'Municipais  - R$ 0,00 (0%)'+  
 char(124)+'Federais    - R$ 0,00 (0%)'+  
 char(124)+char(124)+'IMUNE A IMPOSTOS DE ACORDO COM O ART. 150, INC. VI, ALÍNEA C DA CONSTITUIÇÃO FEDERAL, ART. 9, INC. VI, ALÍNEA C DO CÓDIGO TRIBUTÁRIO NACIONAL E ARTS. 170 E 171 DO REGULAMENTO DO IMPOSTO DE RENDA.'  
FROM  
 LY_BOLETO AS BOL   
   
WHERE  
 BOL.BOLETO = 78485  
  