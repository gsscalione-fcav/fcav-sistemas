    
CREATE VIEW VW_FCAV_QUESTIONARIO_CANDIDATO    
AS    
    
SELECT distinct    
 ca.CANDIDATO,    
 ca.NOME_COMPL,    
 ca.CONCURSO,    
 ca.SIT_CANDIDATO_VEST,    
 fc.DATA_INSC as DT_INSCRICAO,    
 qe.QUESTAO,    
 re.RESPOSTA_SUBJETIVA,    
 co.TIPO,  
 co.CONCEITO,    
 qe.QUESTAO_OBJETIVA,    
 qe.QUESTAO_SUBJETIVA,    
 qu.DESCRICAO as RESPOSTA    
from     
 LY_CANDIDATO ca    
 inner join FCAV_CANDIDATOS fc on (fc.CANDIDATO = ca.CANDIDATO and fc.CONCURSO = ca.CONCURSO)    
 LEFT join LY_AVALIADOR av on (ca.CANDIDATO = av.CANDIDATO)    
 LEFT join LY_RESPOSTA re on (av.CODIGO = re.AVA_CODIGO)    
 left join LY_CONCEITO_RESPOSTA  co on(re.CHAVE_RESP = co.CHAVE_RESP)    
 left join LY_CONCEITOS_QUEST qu on (qu.CONCEITO = co.CONCEITO)    
 left join LY_QUESTAO qe on (qe.QUESTAO = re.QUESTAO AND qe.TIPO_QUESTIONARIO = re.TIPO_QUESTIONARIO)    
 left join LY_TIPO_QUESTAO tq on (tq.TIPO = qe.TIPO)   
GROUP BY    
 re.AVA_CODIGO,    
 qe.QUESTAO,    
 re.QUESTIONARIO,    
 re.RESPOSTA_SUBJETIVA,    
 co.TIPO,    
 co.CONCEITO,    
 ca.CANDIDATO,    
 ca.NOME_COMPL,    
 ca.CONCURSO,    
 ca.SIT_CANDIDATO_VEST,    
 fc.DATA_INSC,    
 qe.QUESTAO_OBJETIVA,    
 qe.QUESTAO_SUBJETIVA,    
 --tq.DESCRICAO,    
 qu.DESCRICAO    