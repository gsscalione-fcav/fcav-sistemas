--* ***************************************************************  
--*  
--*  ***VIEW VW_FCAV_ALUNO_TURMA_DISCIPLINA ***  
--*   
--* DESCRICAO:  
--* - View que trás as informações de matricula, curso, turma e as disciplinas  
--* que o aluno está cursando. Tanto do Lyceum como do Icoruja, através do UNION e Linked Server.  
--*  
--* PARAMETROS:  
--* - Sem parâmetro  
--*   
--* USO:  
--* - O uso será para o academico e para o Helbert na parte do Moodle  
--*  
--* ALTERAÇÕES:  
--*  03/02/2014 - Acrescentado mais um campo que informa a data de inicio da disciplina.  
--*  21/07/2015 - Alterado a forma como é separado o sobrenome.  
--*  15/02/2017 - Alterado o campo curso para trazer o código correto dos cursos de atualização e palestra. Gabriel SS. 
--*  18/12/2017 - Retirado a parte comentada da consulta do icouja, sistema antigo. Gabriel SS. 
--*  
--* Autor: Gabriel S. Scalione  
--* Data de criação: 11/12/2013  
--*  
--* ***************************************************************  
  
--USE LYCEUM  
  
IF OBJECT_ID ('VW_FCAV_ALUNO_TURMA_DISCIPLINA','V') IS NOT NULL  
 DROP VIEW VW_FCAV_ALUNO_TURMA_DISCIPLINA  
GO  
  
CREATE VIEW VW_FCAV_ALUNO_TURMA_DISCIPLINA   
AS  
SELECT  
    DT_MATRICULA AS DATA_MATRICULA,  
  
    CASE  
        WHEN CHARINDEX(' ', LTRIM(RTRIM(pes.NOME_COMPL))) > 0 THEN LEFT(dbo.FN_FCAV_PRIMEIRA_MAIUSCULA(LTRIM(RTRIM(pes.NOME_COMPL))), CHARINDEX(' ', LTRIM(RTRIM(pes.NOME_COMPL))) - 1)  
        ELSE dbo.FN_FCAV_PRIMEIRA_MAIUSCULA(LTRIM(RTRIM(pes.NOME_COMPL)))  
    END AS NOME,  
  
    CASE  
        WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(pes.NOME_COMPL)))) > 0 THEN SUBSTRING(dbo.FN_FCAV_PRIMEIRA_MAIUSCULA(LTRIM(RTRIM(pes.NOME_COMPL))), CHARINDEX(' ', LTRIM(RTRIM(pes.NOME_COMPL))), LEN(LTRIM(RTRIM(pes.NOME_COMPL))))  
        ELSE ''  
    END AS SOBRENOME,  
  
    pes.CPF AS CPF,  
    mat.SIT_MATRICULA AS STATUS_MATRICULA,  
    CASE  
        WHEN (tur.CURSO = 'ATUALIZACAO' OR  
            TUR.CURSO = 'PALESTRA') THEN TUR.DISCIPLINA  
        ELSE TUR.CURSO  
    END AS CURSO,  
    LTRIM(REPLACE(SUBSTRING(mat.TURMA, LEN(mat.TURMA) - 2, LEN(mat.TURMA)), '-', '')) AS TURMA,  
    tur.DISCIPLINA AS DISCIPLINA,  
    DIS.NOME AS NOME_DISCIPLINA,  
    tur.DT_INICIO AS DATA_INICIO_DISCIPLINA,  
    LOWER(pes.E_MAIL) AS E_MAIL,  
    'Lyceum' AS SISTEMA  
FROM LY_MATRICULA mat  
INNER JOIN LY_ALUNO alu  
    ON (alu.ALUNO = mat.ALUNO)  
INNER JOIN LY_PESSOA pes  
    ON (pes.PESSOA = alu.PESSOA)  
INNER JOIN LY_TURMA tur  
    ON (tur.TURMA = mat.TURMA  
    AND mat.DISCIPLINA = tur.DISCIPLINA)  
INNER JOIN LY_DISCIPLINA DIS  
    ON (TUR.DISCIPLINA = DIS.DISCIPLINA)  