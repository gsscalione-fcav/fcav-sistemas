/*          
 VIEW PARA AUXILIAR A PÁGINA DO APOIO WEB          
           
 É UTILIZADA NOs ARQUIVOs \\...\inetpub\wwwroot\web\resumo\resumo.asp, inscritos_fup.asp e inscritos.asp          
           
 Motivo: o arquivo antigo não estava calculando os alunos de venda direta          
        
 Atualização:        
    23/11/2016 - Criado mais um campo 'TIPO_INGRESSO', porque a pagina inscritos.asp, não estava pegando os candidatos onde o concurso estava como TIPO_INGRESSO 'Processo Seletivo',         
                 o arquivo asp também foi alterado. Gabriel SS       
    09/12/2016 - Adicionado mais uma campo 'OBS', esse campo é o mesmo da tabela LY_CANDIDATO e é utilizado no follow-up do apoioweb. Gabriel SS       
           
Gabriel S. Scalione          
Data: 09/03/2016          
          
SELECT * FROM VW_FCAV_INSCRITOS  WHERE CONCURSO LIKE 'CCLGP T 10%' order by DT_INSCRICAO       
          
*/  
 USE LYCEUM
 GO
  
ALTER VIEW VW_FCAV_INSCRITOS  
  
AS  
  
SELECT  
    CA.CONCURSO,  
    CO.TIPO_INGRESSO,  
    CA.CANDIDATO,  
    CA.NOME_COMPL,  
    CA.E_MAIL,  
    ISNULL(CA.DT_INSCRICAO, FC.DATA_INSC) AS DT_INSCRICAO,
    CA.SIT_CANDIDATO_VEST AS SIT_MATRICULA,
    CV.MATRICULADO,  
    'S' AS INSCR_INTERNET,  
    FC.DATA_INSC,  
    FC.CONVOCADO,  
    CA.OBS  
FROM LY_CANDIDATO CA  
LEFT JOIN LY_CONVOCADOS_VEST CV  
    ON CA.CANDIDATO = CV.CANDIDATO  
    AND CA.CONCURSO = CV.CONCURSO  
INNER JOIN FCAV_CANDIDATOS FC  
    ON CA.CANDIDATO = FC.CANDIDATO  
    AND CA.CONCURSO = FC.CONCURSO  
INNER JOIN LY_CONCURSO CO  
    ON CO.CONCURSO = CA.CONCURSO  
  
GROUP BY CA.CONCURSO,  
         CO.TIPO_INGRESSO,  
         CA.CANDIDATO,  
         CA.NOME_COMPL,  
         CA.E_MAIL,  
         CA.DT_INSCRICAO, 
         CA.SIT_CANDIDATO_VEST,
         CV.MATRICULADO,  
         CA.INSCR_INTERNET,  
         FC.DATA_INSC,  
         FC.CONVOCADO,  
         CA.OBS  
  
UNION ALL  
  
SELECT  
    MP.TURMA CONCURSO,  
    'Venda Direta' AS TIPO_INGRESSO,  
    ALUNO AS CANDIDATO,  
    MP.NOME_COMPL,  
    P.E_MAIL,  
    MP.DT_MATRICULA DT_INSCRICAO,  
    MP.SIT_MATRICULA,
    'S' AS MATRICULADO,  
    'S' AS INSCR_INTERNET,  
    MP.DT_MATRICULA AS DATA_INSC,  
    '1' AS CONVOCADO,  
    '-' AS OBS  
FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MP  
INNER JOIN LY_PESSOA P  
    ON P.PESSOA = MP.PESSOA  
INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA T  
    ON T.TURMA = MP.TURMA  
WHERE T.TP_INGRESSO = 'VD'  
  
GROUP BY MP.TURMA,  
         ALUNO,  
         MP.NOME_COMPL,  
         MP.SIT_MATRICULA,
         P.E_MAIL,  
         MP.DT_MATRICULA