/*

	SCRIPT UTILIZADO NA PLANILHA DE RELAT�RIO DE ALUNOS COM SITUA��O FINANCEIRA

*/
SELECT
	MP.UNIDADE_RESPONSAVEL,
	MP.CURSO,
	MP.TURMA,
	MP.ANO_INGRESSO,
	MP.SEM_INGRESSO AS PER_INGRESSO,
	MP.ALUNO,
	MP.NOME_COMPL,
	MP.DT_MATRICULA,
	MP.SIT_ALUNO,
	MP.SIT_MATRICULA,
	
	CASE WHEN EXT.SITUACAO_BOLETO LIKE 'Boleto%pago' THEN 'Adimplente'
		 WHEN EXT.SITUACAO_BOLETO = 'A Vencer'	  THEN 'Aguardando Pagamento'
		 WHEN EXT.SITUACAO_BOLETO = 'Vencido'	  THEN 'Inadimplente'
		 WHEN EXT.SITUACAO_BOLETO = 'Baixa por Acordo' THEN 'Adimplente'
	END AS SITUACAO_FINANCEIRA

FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MP
	INNER JOIN VW_FCAV_BOLETOS_EMITIDOS_CONTAB EXT
		ON MP.ALUNO = EXT.ALUNO
		
WHERE
	MONTH(ext.DATA_DE_VENCIMENTO) = MONTH(getdate())
GROUP BY
	MP.UNIDADE_RESPONSAVEL,
	MP.CURSO,
	MP.TURMA,
	MP.ANO_INGRESSO,
	MP.SEM_INGRESSO,
	MP.ALUNO,
	MP.NOME_COMPL,
	MP.SIT_ALUNO,
	MP.DT_MATRICULA,
	MP.SIT_MATRICULA,
	EXT.SITUACAO_BOLETO,
	DATA_DE_VENCIMENTO

ORDER BY CURSO, TURMA, DATA_DE_VENCIMENTO DESC, ANO_INGRESSO DESC, SEM_INGRESSO DESC


	