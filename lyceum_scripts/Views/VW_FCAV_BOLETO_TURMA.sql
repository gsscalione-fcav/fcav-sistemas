CREATE VIEW VW_FCAV_BOLETO_TURMA AS   
  
SELECT  
 BOL.BOLETO,  
 ALU.ALUNO,  
 ALU.NOME_COMPL,  
 CASE WHEN CUR.NOME = 'ATUALIZAÇÃO'  
   THEN DIS.NOME_COMPL  
  ELSE ISNULL(CUR.NOME,'.') END AS CURSO,  
 TUR.TURMA,   
 FCAV.CENTRO_CUSTO,  
 COB.FL_FIELD_01 AS COMPLEMENTO  
FROM  
 LY_ALUNO AS ALU  
 INNER JOIN LY_COBRANCA AS COB ON (ALU.ALUNO = COB.ALUNO)  
 INNER JOIN LY_ITEM_LANC AS ILAN ON (COB.COBRANCA = ILAN.COBRANCA)  
 INNER JOIN LY_BOLETO AS BOL ON (ILAN.BOLETO = BOL.BOLETO AND BOL.BOLETO IS NOT NULL)  
  
 INNER JOIN LY_LANC_DEBITO LD ON LD.ALUNO = ALU.ALUNO      
    INNER JOIN LY_MATRICULA AS M ON (LD.ALUNO = M.ALUNO AND LD.ANO_REF = M.ANO AND LD.PERIODO_REF = M.SEMESTRE)-- AND LD.LANC_DEB = M.LANC_DEB)  
  
 INNER JOIN LY_CURSO AS CUR ON (ALU.CURSO = CUR.CURSO)  
 INNER JOIN LY_TURMA AS TUR ON (M.TURMA = TUR.TURMA AND M.DISCIPLINA = TUR.DISCIPLINA AND M.ANO = TUR.ANO AND M.SEMESTRE = TUR.SEMESTRE)  
 INNER JOIN LY_DISCIPLINA AS DIS ON (TUR.DISCIPLINA = DIS.DISCIPLINA)  
 INNER JOIN FCAV_IMPCONT_CAD AS FCAV ON (TUR.TURMA = FCAV.TURMA)  
  
--WHERE   
 --BOL.NUMERO_RPS = '10000105'  
 --BOL.BOLETO = --'26531'  
   
UNION ALL
  
SELECT DISTINCT  
 BOL.BOLETO,  
 ALU.ALUNO,  
 ALU.NOME_COMPL,  
 CASE WHEN CUR.NOME = 'ATUALIZAÇÃO'  
   THEN DIS.NOME_COMPL  
  ELSE ISNULL(CUR.NOME,'.') END AS CURSO,  
 TUR.TURMA,   
 FCAV.CENTRO_CUSTO,  
 COB.FL_FIELD_01 AS COMPLEMENTO  
FROM  
 LY_ALUNO AS ALU  
 INNER JOIN LY_COBRANCA AS COB ON (ALU.ALUNO = COB.ALUNO)  
 INNER JOIN LY_ITEM_LANC AS ILAN ON (COB.COBRANCA = ILAN.COBRANCA)  
 INNER JOIN LY_BOLETO AS BOL ON (ILAN.BOLETO = BOL.BOLETO AND BOL.BOLETO IS NOT NULL)  
  
 INNER JOIN LY_LANC_DEBITO LD ON LD.ALUNO = ALU.ALUNO      
    INNER JOIN LY_HISTMATRICULA AS M ON (LD.ALUNO = M.ALUNO AND LD.ANO_REF = M.ANO AND LD.PERIODO_REF = M.SEMESTRE)-- AND LD.LANC_DEB = M.LANC_DEB)  
  
 INNER JOIN LY_CURSO AS CUR ON (ALU.CURSO = CUR.CURSO)  
   
 INNER JOIN LY_TURMA AS TUR ON (M.TURMA = TUR.TURMA AND M.DISCIPLINA = TUR.DISCIPLINA AND M.ANO = TUR.ANO AND M.SEMESTRE = TUR.SEMESTRE)  
 INNER JOIN LY_DISCIPLINA AS DIS ON (TUR.DISCIPLINA = DIS.DISCIPLINA)  
 INNER JOIN FCAV_IMPCONT_CAD AS FCAV ON (TUR.TURMA = FCAV.TURMA)  
  
--WHERE   
 --BOL.NUMERO_RPS = '10000105'  
 --BOL.BOLETO =   
UNION ALL
  
SELECT DISTINCT  
 BOL.BOLETO,  
 ALU.ALUNO,  
 ALU.NOME_COMPL,  
 CASE WHEN CUR.NOME = 'ATUALIZAÇÃO'  
   THEN DIS.NOME_COMPL  
  ELSE ISNULL(CUR.NOME,'.') END AS CURSO,  
 TUR.TURMA,   
 FCAV.CENTRO_CUSTO,  
 COB.FL_FIELD_01 AS COMPLEMENTO  
FROM  
 LY_ALUNO AS ALU  
 INNER JOIN LY_COBRANCA AS COB ON (ALU.ALUNO = COB.ALUNO)  
 INNER JOIN LY_ITEM_LANC AS ILAN ON (COB.COBRANCA = ILAN.COBRANCA)  
 INNER JOIN LY_BOLETO AS BOL ON (ILAN.BOLETO = BOL.BOLETO AND BOL.BOLETO IS NOT NULL)  
  
 INNER JOIN LY_LANC_DEBITO LD ON LD.ALUNO = ALU.ALUNO      
    INNER JOIN LY_PRE_MATRICULA AS M ON (LD.ALUNO = M.ALUNO AND LD.ANO_REF = M.ANO AND LD.PERIODO_REF = M.SEMESTRE)-- AND LD.LANC_DEB = M.LANC_DEB)  
  
 INNER JOIN LY_CURSO AS CUR ON (ALU.CURSO = CUR.CURSO)  
   
 INNER JOIN LY_TURMA AS TUR ON (M.TURMA = TUR.TURMA AND M.DISCIPLINA = TUR.DISCIPLINA AND M.ANO = TUR.ANO AND M.SEMESTRE = TUR.SEMESTRE)  
 INNER JOIN LY_DISCIPLINA AS DIS ON (TUR.DISCIPLINA = DIS.DISCIPLINA)  
 INNER JOIN FCAV_IMPCONT_CAD AS FCAV ON (TUR.TURMA = FCAV.TURMA)  
  
--WHERE   
 --BOL.NUMERO_RPS = '10000105'  
 --BOL.BOLETO =   
  