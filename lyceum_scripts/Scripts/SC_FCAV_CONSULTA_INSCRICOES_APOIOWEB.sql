DECLARE @concurso T_CODIGO

SET @concurso = 'A-LA T 90'
			
			SELECT
			    insc.CONCURSO as concurso,
			    insc.CANDIDATO, 
				insc.NOME_COMPL, 
				insc.E_MAIL,
			    insc.DT_INSCRICAO, 
				insc.OBS,
			    CASE WHEN ly_cand.SIT_CANDIDATO_VEST = 'Cancelado' THEN ly_cand.SIT_CANDIDATO_VEST
				WHEN mat.SIT_ALUNO NOT LIKE 'Cancelado' THEN mat.SIT_MATRICULA end as SIT_MATRICULA,
			    ly_cand.FL_FIELD_02, 
				ly_cand.FL_FIELD_03,
			    ly_cand.DT_INSCRICAO as candidato_dt_inscr,
			    cand.DATA_CONV, 
				cand.DATA_SECRET, 
				cand.PESSOA, 
				cand.CONVOCADO, 
				cand.DATA_INSC,
			    conv.MATRICULADO
			FROM
			    dbo.VW_FCAV_INSCRITOS insc
			      left outer join VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA2 mat
			      on(
			              mat.CANDIDATO = insc.CANDIDATO
			          AND mat.CONCURSO  = insc.CONCURSO
			      )
			      --
			      left outer join LY_CANDIDATO ly_cand
			      on(
			              ly_cand.CANDIDATO = insc.CANDIDATO
			          AND ly_cand.CONCURSO  = insc.CONCURSO
			      )
			      --
			      left outer join dbo.FCAV_CANDIDATOS cand
			      ON(
			              cand.CANDIDATO = insc.CANDIDATO
			          AND cand.CONCURSO  = insc.CONCURSO
			      )
			      --
			      left outer join dbo.LY_CONVOCADOS_VEST conv
			      ON(
			              conv.CANDIDATO = insc.CANDIDATO
			          AND conv.CONCURSO  = insc.CONCURSO
			      )
			  
			WHERE
			    mat.TURMA = @concurso
				--and insc.CANDIDATO = '201900060'
			ORDER BY insc.CANDIDATO


select 
	* 
from 
	VW_MATRICULA_E_PRE_MATRICULA 
where 
	aluno in 
		(select aluno from ly_aluno 
		where candidato = '201900060')


select * from VW_FCAV_INSCRITOS 
		where CONCURSO  = 'A-LA T 90'

select * from LY_CANDIDATO 
		where candidato = '201900060'


select * from FCAV_CANDIDATOS
		where candidato = '201900060'


ALTER TABLE FCAV_CANDIDATOS DISABLE TRIGGER ALL
UPDATE FCAV_CANDIDATOS
SET
	CONCURSO = 'CCGB T 52'
where candidato = '201900060'
AND CONCURSO = 'CCGB T 53'
ALTER TABLE FCAV_CANDIDATOS ENABLE TRIGGER ALL

DELETE FCAV_CANDIDATOS WHERE candidato = '201900060'
AND CONCURSO = 'CCGB T 53'


SELECT * FROM LY_COMPRA_OFERTA WHERE ALUNO = 'C201900008'

UPDATE LY_CONVOCADOS_VEST 
SET
	CONCURSO = 'CCGB T 52'
		where candidato = '201900060'


DELETE LY_PARTICIPACAO_QUEST WHERE CODIGO = 'CCGB T 53201900060' (SELECT CODIGO FROM LY_AVALIADOR WHERE CANDIDATO IN (SELECT CANDIDATO FROM LY_CANDIDATO WHERE CANDIDATO = '201900060' AND CONCURSO = 'CCGB T 53'))

DELETE LY_AVALIADOR WHERE CANDIDATO = '201900060' AND CONCURSO = 'CCGB T 53'

DELETE LY_CANDIDATO WHERE CANDIDATO = '201900060' AND CONCURSO = 'CCGB T 53'