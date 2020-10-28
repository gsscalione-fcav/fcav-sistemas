With Alunos_Matr_Tur_Periodo as 
(
	SELECT DISTINCT
	 UNIDADE_RESPONSAVEL,
	 CURSO,    
	 TURMA,  
	 DT_INICIO_TURMA AS DT_INICIO,  
	 YEAR(DT_INI_DISCIPLINA) AS ANO,
		CASE WHEN (MONTH(DT_INI_DISCIPLINA)) IN ('1','2','3') THEN '1' 
			 WHEN (MONTH(DT_INI_DISCIPLINA)) IN ('4','5','6','7') THEN '2'
			 WHEN (MONTH(DT_INI_DISCIPLINA)) IN ('8','9','10','11','12') THEN '3'
			END AS PERIODO,
	 ALUNO

	FROM     
	 VW_FCAV_SIT_ALUNOS_ICORUJA 

	WHERE     
		STATUS_MATRICULA = 'Matriculado' 
	  AND UNIDADE_RESPONSAVEL = 'ESPEC'
	  --AND TURMA = 'CEAI T 06'
	GROUP BY  
	 UNIDADE_RESPONSAVEL,
	 CURSO,    
	 TURMA,
	 DT_INICIO_TURMA,
	 DT_INI_DISCIPLINA,
	 ALUNO
), 
Qtde_Matr_Tur_Periodo as 
(
	SELECT
	 UNIDADE_RESPONSAVEL,
	 CURSO,    
	 TURMA,  
	 DT_INICIO,  
	 ANO,
	 PERIODO,
	 cast(ANO as varchar) + '/'+ cast(PERIODO as varchar) as PERIODO_LETIVO,
	 COUNT(ALUNO) AS Qtde_Matr_Tur_Periodo

	FROM     
	 Alunos_Matr_Tur_Periodo 

	GROUP BY  
	 UNIDADE_RESPONSAVEL,
	 CURSO,    
	 TURMA,
	 ANO,
	 PERIODO,
	 DT_INICIO
)	-- SELECT * FROM Qtde_Matr_Tur_Periodo
, 

Qtde_Inscritos as
(
SELECT  
 CASE When CUR_ARCID = '33' THEN 'ESPEC'  
 END AS UNID_RESPONSAVEL,  
 tur_codtur AS TURMA,  

 COUNT(pes_id) Qtde_Inscritos 
from  
 TB_INSC_INSCRICOES_REALIZADAS
 inner join TB_INSC_INSREAL_OPC on (inr_id = iro_inrid)
 inner join tb_insc_inscricao_opcao on (ict_id = iro_ictid)
 inner join tb_pessoa on (pes_id = inr_pesid)
 inner join tb_turma on (ict_turid = tur_id)
 inner join TB_curso on (tur_curid = cur_id)  
where 
	CUR_ARCID = '33'
group by
	--convert(datetime,convert(varchar, inr_dathor,112)),
	CUR_ARCID,   
	tur_codtur
 
)
, Alu_matri_turma as 
(
	SELECT 
		TURMA,
		ALUNO
FROM VW_FCAV_SIT_ALUNOS_ICORUJA 
WHERE 
	STATUS_MATRICULA = 'Matriculado' 
	and  UNIDADE_RESPONSAVEL = 'ESPEC'

group by TURMA,ALUNO
),
 
 Qtde_bolsistas AS

 (select 
	TURMA,
	isnull(Count(ALUNO_COD),0) Qtde_bolsistas
   from 
		VW_FCAV_ICO_ALUNOS_BOLSISTAS
	where 
		tipo = 'Percentual'
		and VALOR = '100.00'
   group by 
	TURMA) 

-------------------------------------------------------------------
--script final
-------------------------------------------------------------------
SELECT 
	qm.UNIDADE_RESPONSAVEL AS MODALIDADE,
	qm.CURSO,    
	qi.TURMA,  
	DT_INICIO,    
	Qtde_Inscritos AS NUM_INSCRITOS,
	(SELECT COUNT(ALUNO) FROM Alu_matri_turma WHERE TURMA = qi.TURMA group by TURMA) AS MATRICULADOS,
	ISNULL(Qtde_bolsistas,0) AS Qtde_bolsistas,
	QM.PERIODO_LETIVO,
	qm.Qtde_Matr_Tur_Periodo

	into #alunos_especializacao
FROM
	Qtde_Inscritos QI
	inner join Qtde_Matr_Tur_Periodo QM
		on QI.TURMA = qm.TURMA
	left join Qtde_bolsistas qb
		on qb.turma = qm.turma

		
------------------------------------------------------------------------------
--transformando linhas em colunas
------------------------------------------------------------------------------
declare @colunas_pivot as nvarchar(max), @comando_sql as nvarchar(max)
set @colunas_pivot = 
		stuff((
			select 
				distinct ',' + quotename(periodo_letivo) 
			from #alunos_especializacao 
			for xml path('')
		), 1, 1,'')
print @colunas_pivot
set @comando_sql = '
select * from (
	select 
		MODALIDADE,
		CURSO,
		TURMA,
		DT_INICIO,
		NUM_INSCRITOS,
		MATRICULADOS,
		Qtde_bolsistas as BOLSISTAS_100,
		PERIODO_LETIVO,
		sum(Qtde_Matr_Tur_Periodo) Num_alunos
	from #alunos_especializacao
	 group by MODALIDADE,
		CURSO,
		TURMA,
		DT_INICIO,
		NUM_INSCRITOS,
		MATRICULADOS,
		Qtde_bolsistas,
		PERIODO_LETIVO
	) em_linha
	pivot(sum(num_alunos) for periodo_letivo in ('+ @colunas_pivot +')) em_colunas
	order by 1'
print @comando_sql

execute(@comando_sql)

--drop table #alunos_especializacao