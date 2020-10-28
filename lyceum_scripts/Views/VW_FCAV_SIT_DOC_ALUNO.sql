--* ***************************************************************  
--*  
--*  *** VIEW VW_FCAV_SIT_DOC_ALUNO ***  
--*   
--* DESCRICAO:  
--* - View utilizada a situação da entregue da documentação dos alunos.  
--*  
--* Autor: Gabriel S. Scalione  
--* Data: 12/07/2018
--*  
--* ***************************************************************  
ALTER VIEW VW_FCAV_SIT_DOC_ALUNO
AS  
SELECT
 AL.ALUNO,  
 DBO.FN_FCAV_PRIMEIRA_MAIUSCULA(AL.NOME_COMPL) AS NOME,  
 CPF,  
 LOWER(E_MAIL) AS E_MAIL,
 AL.DDD_FONE,
 AL.FONE,
 AL.DDD_FONE_CELULAR,
 AL.CELULAR,
 AL.SIT_MATRICULA,  
 AL.CURSO,  
 AL.TURMA,  
 CASE WHEN DI.NOME IS NULL THEN 'Não Informado'  
  ELSE DI.NOME  
 END AS DOCUMENTACAO,  
 CASE WHEN AD.STATUS IS NULL THEN 'Não Informado'  
  ELSE AD.STATUS  
 END AS SIT_DOCUMENTACAO
 
FROM  
 VW_FCAV_INFO_ALUNOS_LYCEUM AL
 INNER JOIN LY_ALUNO_DOC_INGRESSO AD 
	ON AD.ALUNO = AL.ALUNO
 INNER JOIN LY_DOCUMENTOS_INGRESSO DI 
	ON DI.DOC = AD.DOC  

GROUP BY  
	AL.ALUNO,  
	AL.NOME_COMPL,  
	CPF,  
	E_MAIL,
	AL.DDD_FONE,
	AL.FONE,
	AL.DDD_FONE_CELULAR,
	AL.CELULAR,
	AL.SIT_MATRICULA,  
	AL.CURSO,  
	AL.TURMA,  
	DI.NOME,  
	AD.STATUS