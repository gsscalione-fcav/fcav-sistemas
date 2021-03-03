/*  
 VIEW VW_FCAV_ATESTADO_MATR_CEAI   
  
Finalidade: Trazer a relação de alunos para o relatório de Atestado de Matrícula emitido pelo Lyceum.  
  
Alterações:   
  
Autor: GAbriel S.S.  
Data: 2019-08-30  
 
/*cpf			-*/ EXEC PR_FCAV_CONSULTA_PESSOA NULL, NULL, '13006885805', NULL, NULL, NULL  
  
SELECT * FROM VW_FCAV_ATESTADO_MATR_CEAI WHERE aluno in ('E201920103')
SELECT * FROM VW_FCAV_MATR_PRE_E_HIST_SERIE WHERE aluno = 'E201720014'  
  
SELECT CASE WHEN (select count(v2.semestre) from VW_FCAV_MATR_PRE_E_HIST_SERIE v2   
  GROUP BY ANO, ALUNO, SEMESTRE HAVING count(v2.semestre) > 2) > 2 THEN 1  
  ELSE 0 END   
     
  
*/  
   
  
ALTER VIEW VW_FCAV_ATESTADO_MATR_CEAI AS  
  
WITH PERIODO_CURSO
AS (SELECT
    TU.TURMA,
    TU.SERIE,
    TU.ANO,
    TU.SEMESTRE,
    MIN(TU.DT_INICIO) AS INICIO,
    MAX(TU.DT_FIM) AS FIM
FROM LY_TURMA TU
WHERE TU.UNIDADE_RESPONSAVEL = 'ESPEC'
AND SERIE IN (1, 2, 3)
and tu.DISCIPLINA not like 'CEAI-RESERV'
GROUP BY TU.TURMA,
         TU.ANO,
         TU.SEMESTRE,
         TU.SERIE),

RELACAO_ALUNO_ATESTADO
AS (SELECT DISTINCT--top 1  
    DENSE_RANK() OVER (PARTITION BY VW.ALUNO ORDER BY VW.ANO, VW.SEMESTRE,vw.turma)
    AS PERIODO1,
    VW.ALUNO,
    AL.NOME_COMPL AS ALU_NOME,
    VW.ANO,
    VW.SEMESTRE,
    PES.RG_NUM,
    CPF,
    CURSO.NOME,
    TUR.CURSO,
    CASE
        WHEN CURSO.FACULDADE = 'ATUAL' THEN 'Atualização'
        WHEN CURSO.FACULDADE = 'CAPAC' THEN 'Capacitação'
        WHEN CURSO.FACULDADE = 'ESPEC' THEN 'Especialização'
    END AS UNID_RESP,
    TUR.TURMA,
	dbo.FN_FCAV_CAR_HORARIA_EXT(TUR.CURRICULO) as CARGA_HORARIA_CURSO,
    CAST(CURR.AULAS_PREVISTAS AS numeric) AS CARGA_HOR,
    dbo.FN_FCAV_NUM_EXTENSO(CURR.AULAS_PREVISTAS) AS CARGA_HOR_EXT,
    (SELECT
        DESCR
    FROM HADES.dbo.HD_TABELAITEM
    WHERE TABELA = 'Gerentes'
    AND ITEM = 'Educação')
    AS GERENTE
FROM VW_FCAV_MATR_PRE_E_HIST_SERIE VW
INNER JOIN LY_ALUNO AL
    ON VW.ALUNO = AL.ALUNO
    AND AL.CURSO = 'CEAI'
	AND VW.DISCIPLINA != 'CEAI-RESERV'
INNER JOIN LY_PESSOA PES
    ON AL.PESSOA = PES.PESSOA
INNER JOIN LY_CURSO CURSO
    ON AL.CURSO = CURSO.CURSO
    AND CURSO.FACULDADE IN ('ESPEC')
    AND CURSO.CURSO IN ('CEAI')
INNER JOIN LY_TURMA TUR
    ON VW.TURMA = TUR.TURMA
    AND VW.ANO = TUR.ANO
    AND VW.SEMESTRE = TUR.SEMESTRE
INNER JOIN LY_CURRICULO CURR
    ON CURR.CURSO = TUR.CURSO
    AND CURR.TURNO = TUR.TURNO
    AND CURR.CURRICULO = TUR.CURRICULO
INNER JOIN PERIODO_CURSO PER
    ON TUR.TURMA = PER.TURMA
    AND TUR.ANO = PER.ANO
    AND TUR.SEMESTRE = PER.SEMESTRE
    AND TUR.SERIE = PER.SERIE

GROUP BY VW.ALUNO,
         AL.NOME_COMPL,
         VW.ANO,
         VW.SEMESTRE,
         VW.TURMA,
         PES.RG_NUM,
         CPF,
         TUR.CURSO,
         CURSO.NOME,
         tur.UNIDADE_RESPONSAVEL,
         CURSO.FACULDADE,
         TUR.TURMA,
		 tur.CURRICULO,
         TUR.DT_INICIO,
         TUR.DT_FIM,
         CURR.AULAS_PREVISTAS,
         PER.INICIO,
         PER.FIM)

SELECT 
    MAX(PERIODO1) AS PERIODO1,
    ALUNO,
    ALU_NOME,
    RG_NUM,
    CPF,
    NOME,
    CURSO,
    UNID_RESP,
    TURMA,
	CARGA_HORARIA_CURSO,
    CARGA_HOR,
    CARGA_HOR_EXT,
    GERENTE
FROM RELACAO_ALUNO_ATESTADO  --WHERE ALUNO = 'E201910034'
GROUP BY TURMA,
		 ALUNO,
         ALU_NOME,
         RG_NUM,
         CPF,
         NOME,
         CURSO,
         UNID_RESP,
		 CARGA_HORARIA_CURSO,
         CARGA_HOR,
         CARGA_HOR_EXT,
         GERENTE

