/*    
 VW_FCAV_COORDENADOR_TURMA    
    
View que retorna o coordenador de cada turma.    
    
Irá auxiliar no envio de e-mail da convocação manual, principalmente para os cursos da Certificação    
    
Autor: Gabriel S.    
Data: 23/09/2015    
    
*/  
  
  
ALTER VIEW VW_FCAV_COORDENADOR_TURMA  
AS  
  
SELECT  
    CS.TIPO,  
    TU.TURMA,  
    TU.TP_INGRESSO,  
    TU.OFERTA_DE_CURSO,  
    TU.CONCURSO,  
    DO.NOME_COMPL,  
    CO.NUM_FUNC,  
    TU.COD_CURSO AS CURSO,  
    CO.CHAVE,  
    TU.UNIDADE_FISICA AS UNID_FISICA,  
    ISNULL(CO.TIPO_COORD, 'COORD') TIPO_COORD,  
    CO.CURRICULO,  
    CO.TURNO,  
    CO.CLASSIFICACAO,  
    CO.PARTICIPACAO_PORCENT,  
    CO.DT_INI,  
    CO.DT_FIM,  
    CASE WHEN DO.NOME_COMPL = 'José Joaquim do Amaral Ferreira' THEN '-CERT'
    ELSE
		NULL
	END AS GRUPO  
FROM VW_FCAV_INI_FIM_CURSO_TURMA TU  
LEFT JOIN LY_COORDENACAO CO  
    ON CO.CURSO = TU.COD_CURSO  
LEFT JOIN LY_OFERTA_CURSO oc  
    ON OC.OFERTA_DE_CURSO = TU.OFERTA_DE_CURSO  
LEFT JOIN LY_DOCENTE DO  
    ON DO.NUM_FUNC = CO.NUM_FUNC  
LEFT JOIN LY_CURSO CS  
    ON CS.CURSO = TU.CURSO