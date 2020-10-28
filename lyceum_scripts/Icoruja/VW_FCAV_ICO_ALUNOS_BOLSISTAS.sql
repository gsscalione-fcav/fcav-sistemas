
alter VIEW VW_FCAV_ICO_ALUNOS_BOLSISTAS
AS
select 

	PE.PES_CODTEL AS ALUNO_COD,
	PE.pes_nome AS ALUNO_NOME,
	TUR_CODTUR AS TURMA,
	des_descri TIPO_BOLSA,
	CASE WHEN pda_percen IS NOT NULL THEN 'Percentual' 
		 WHEN pda_valor IS NOT NULL THEN 'Valor'
	END AS TIPO,
	CASE WHEN pda_valor IS NOT NULL  THEN REPLACE(CAST(CONVERT(MONEY,pda_valor) AS VARCHAR),'.',',')
				--ELSE REVERSE(SUBSTRING((REVERSE(B.VALOR * 100)),8,10))+'%' END AS VALOR,
				ELSE CAST(CONVERT(DECIMAL(10,2),pda_percen)AS VARCHAR)  
	END AS VALOR,
	CAST(YEAR(pda_valde) AS VARCHAR) AS ANO_INICIAL,
	CAST(MONTH(pda_valde)AS VARCHAR) AS MES_INICIAL,
	CAST(YEAR(pda_valate)AS VARCHAR) AS ANO_FINAL,
	CAST(MONTH(pda_valate)AS VARCHAR) AS MES_FINAL
 
from
 tb_responsavel_desacr
 inner join tb_responsavel_fin on (pda_rfiid = rfi_id)
 inner join tb_contrato_fin on (rfi_cfiid = cfi_id)
 inner join tb_pessoa PE on (cfi_pesid = PE.pes_id)
 inner join tb_turma on (cfi_turid = tur_id)
 inner join tb_desconto on (pda_desid = des_id)
 INNER JOIN TB_PESSOA RESP ON (RFI_PESID = RESP.PES_ID)
