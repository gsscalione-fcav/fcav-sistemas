/*    
 VIEW VW_FCAV_MEDIA_FINAL_ALUNOS    
     
 Finalidade: View que traz o histórico do aluno somente por disciplina.    
     
 Utilizado: É utilizada para auxiliar a planilha de alunos concluintes.    
     
 Autor: Gabriel S Scalione    
 Data: 16/10/2017    
*/    
    
ALTER VIEW VW_FCAV_MEDIA_FINAL_ALUNOS    
    
AS    
    
SELECT    
	CS.FACULDADE AS UNID_RESP,    
	VT.CURSO,      
    VT.TURMA,    
    AL.TURMA_PREF,        
    (SELECT  
        MIN(CT.DT_INICIO)     
    FROM VW_FCAV_INI_FIM_CURSO_TURMA CT      
    WHERE CT.TURMA = HI.TURMA) AS DT_INICIO,      
    (SELECT  
        MAX(CT.DT_FIM)     
    FROM VW_FCAV_INI_FIM_CURSO_TURMA CT      
    WHERE CT.TURMA = HI.TURMA) AS DT_FIM,       
    (SELECT TOP 1  
        CASE  
            WHEN TU.CLASSIFICACAO NOT LIKE 'Cancel%' AND  
                VT.DT_INICIO > GETDATE() THEN 'Em Inscrição'  
            WHEN CLASSIFICACAO NOT LIKE 'Cancel%' AND  
                (GETDATE() BETWEEN VT.DT_INICIO AND VT.DT_FIM) THEN 'Em Andamento'  
            WHEN CLASSIFICACAO NOT LIKE 'Cancel%' AND  
                VT.DT_FIM < GETDATE() THEN 'Concluida'  
            WHEN CLASSIFICACAO LIKE 'Cancel%' THEN 'Cancelada' 
			ELSE
				'NÃO CLASSIFICADA'
        END  
    FROM LY_TURMA TU
    WHERE TU.TURMA = VT.TURMA  
    AND TU.SERIE = 1  
    GROUP BY CLASSIFICACAO) AS SITUACAO_TURMA, 
    AL.ALUNO,      
    AL.NOME_COMPL,      
    HI.ANO,      
    HI.SEMESTRE,      
	HI.DISCIPLINA,
    DI.NOME_COMPL AS NOME_DISCIPLINA,      
    HI.SITUACAO_HIST,      
    HI.SIT_DETALHE,      
    CASE      
  WHEN DI.TEM_NOTA = 'N' THEN 10.00      
        WHEN HI.NOTA_FINAL = 'A' THEN 10.00      
        WHEN HI.NOTA_FINAL = 'R' THEN 0.00      
        ELSE CONVERT(decimal(10, 2), STR(HI.NOTA_FINAL, 15, 2))      
    END AS NOTA_FINAL,      
 CASE WHEN DI.TEM_FREQ = 'N' THEN 100.00       
    ELSE CONVERT(decimal(10, 2), HI.PERC_PRESENCA * 100)       
    END AS FREQUENCIA      
FROM LY_ALUNO AL      
	INNER JOIN LY_HISTMATRICULA HI      
		ON HI.ALUNO = AL.ALUNO      
	INNER JOIN LY_CURSO CS      
		ON CS.CURSO = AL.CURSO      
	INNER JOIN LY_DISCIPLINA DI      
		ON DI.DISCIPLINA = HI.DISCIPLINA
	INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA VT
		ON VT.TURMA = HI.TURMA
WHERE    
 CS.FACULDADE IN ('CAPAC', 'ESPEC','ATUAL')
 AND DI.DISCIPLINA NOT IN ('CCGB-P2','CCGB-P1','CCGB-LSSProjeto')
GROUP BY AL.ALUNO,      
         AL.NOME_COMPL,      
         VT.CURSO,      
		 VT.TURMA,
		 VT.DT_INICIO,
		 VT.DT_FIM ,   
         CS.FACULDADE ,    
         HI.TURMA,
         AL.TURMA_PREF,        
         HI.ANO,      
         HI.SEMESTRE, 
		 HI.DISCIPLINA,    
         DI.NOME_COMPL,      
         DI.TEM_NOTA,      
         DI.TEM_FREQ,      
         HI.SITUACAO_HIST,      
         HI.SIT_DETALHE,      
         HI.NOTA_FINAL,      
         HI.PERC_PRESENCA    
    