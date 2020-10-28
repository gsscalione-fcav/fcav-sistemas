
/*
	SELECT * FROM VW_FCAV_MATRICULA_E_PRE_MATRICULA WHERE DISCIPLINA = 'CEAI-SPE'  AND ANO = 2018 AND SEMESTRE = 2

	if OBJECT_ID('TempDB.dbo.##alunos_especializacao') IS NOT NULL
	begin
		DROP TABLE #alunos_especializacao
		print ('Tabela temporária ##alunos_especializacao removida.')
	end

*/

WITH Alu_Matr_Tur_Periodo AS

 (select 
	MP.CURSO,
	MP.TURMA,
	MP.CONCURSO,
	MP.ANO ,
	MP.SEMESTRE AS PERIODO,
	MP.ALUNO
   from 
		VW_FCAV_MATRICULA_E_PRE_MATRICULA mp
		inner join VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA2 RM
			on RM.aluno = mp.ALUNO
			and RM.TURMA = mp.TURMA
	where mp.FACULDADE = 'ESPEC'
		AND MP.SIT_MATRICULA = 'Matriculado'
		AND RM.TIPO_INGRESSO != 'Dependência'
		AND MP.DISCIPLINA != 'CEAI-RESERV'
		AND MP.SIT_DETALHE like 'Curricular%'
		
   group by
	MP.CURSO,
	mp.TURMA,
	MP.CONCURSO,
	mp.ANO,
	mp.SEMESTRE,
	MP.ALUNO) 
,
 Qtde_Matr_Tur_Periodo AS

 (select 
	CURSO,
	TURMA,
	CONCURSO,
	ANO ,
	PERIODO,
	Count(ALUNO) Qtde_Matr_Tur_Periodo
   from 
		Alu_Matr_Tur_Periodo  
	
   group by
	CURSO,
	TURMA,
	CONCURSO,
	ANO,
	PERIODO) 
,
 Qtde_bolsistas AS

 (select 
	UNIDADE_RESPONSAVEL UNIDADE_RESP,
	CURSO,
	TURMA,
	isnull(Count(ALUNO),0) Qtde_bolsistas
   from 
		VW_FCAV_ALUNOS_BOLSISTAS
	where 
		PERC_VALOR = 'Percentual'
		and VALOR = 1.000000
   group by UNIDADE_RESPONSAVEL,
	CURSO,
	TURMA) 

SELECT	
		CT.UNIDADE_RESPONSAVEL AS MODALIDADE,
		CT.CURSO,
		CT.TURMA,
		MIN(DT_INICIO)DT_INICIO,
		dbo.FN_FCAV_TOTAL_INSCRITO(CT.CONCURSO) AS NUM_INSCRITOS,
		dbo.FN_FCAV_MATRICULADO_TURMA(CT.TURMA) AS MATRICULADOS,
		isnull(QB.Qtde_bolsistas,0) AS Qtde_bolsistas,
		cast(QM.ANO as varchar) + '/' + cast(QM.PERIODO as varchar) as PERIODO_LETIVO,
		SUM(Qtde_Matr_Tur_Periodo) as Qtde_Matr_Tur_Periodo

	into #alunos_especializacao
FROM 
	VW_FCAV_INI_FIM_CURSO_TURMA CT
	INNER JOIN Qtde_Matr_Tur_Periodo QM
		ON QM.TURMA = CT.TURMA
	left join Qtde_bolsistas QB
		ON QB.TURMA = CT.TURMA
group by
		CT.UNIDADE_RESPONSAVEL,
		CT.CURSO,
		CT.TURMA,
		CT.CONCURSO,
		QB.Qtde_bolsistas,
		QM.ANO,
		QM.PERIODO
		


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