
WITH ITENS_LANC AS
(
	Select CURSO, NATUREZA as TURMA, COBRANCA, ITEMCOBRANCA, LANC_DEB, ALUNO, BOLETO, PARCELA, DATA, VALOR, DESCRICAO, DT_ENVIO_CONTAB
	from LY_ITEM_LANC 
	where COBRANCA IN (	Select COBRANCA from LY_ITEM_LANC IL
						where DESCRICAO = 'Acrescimo de IGPM'
						and COBRANCA NOT IN (SELECT COBRANCA FROM LY_ITEM_CRED WHERE IL.COBRANCA = COBRANCA GROUP BY COBRANCA)
						AND COBRANCA in (select COBRANCA
						from LY_COBRANCA 
						where DATA_DE_GERACAO = '2020-07-01 00:00:00.000' 
							--and DATA_DE_GERACAO <= '2020-07-05 00:00:00.000' 
							and ALUNO like 'E%'
							AND ESTORNO = 'N'))
	),
	tu  AS (SELECT
		tu.UNIDADE_RESPONSAVEL,
        tu.CURSO,
        tu.TURNO,
        tu.TURMA,
        --  
        MIN(
        CONVERT(varchar, tu.ANO) + '/' + CONVERT(varchar, tu.SEMESTRE)
        ) AS ANO_SEMESTRE_INICIO,
        --  
        MIN(tu.DT_INICIO) AS DT_INICIO
    FROM dbo.LY_TURMA tu
    GROUP BY tu.CURSO,
                tu.TURNO,
                tu.TURMA,
				tu.UNIDADE_RESPONSAVEL
	),
	IGPM_TURMAS AS ( SELECT  distinct
		tu.TURMA,
		tu.ANO_SEMESTRE_INICIO,
		DT_INICIO,
		YEAR(TU.DT_INICIO) + 1 ANO_IGPM,
		MONTH(TU.DT_INICIO) MES_IGPM,
        COR.VALOR as IGPM
		--,  COR_ANT.VALOR as IGPM_MESANTERIOR
    FROM dbo.LY_LANC_DEBITO ld,
            tu
			--
            LEFT OUTER JOIN LY_CORRECAO COR
                ON (
                COR.ANO = YEAR(TU.DT_INICIO) + 1
                AND COR.MES = MONTH(TU.DT_INICIO)
                )
            --  
            LEFT OUTER JOIN LY_CORRECAO COR_ANT
                ON (
                COR_ANT.ANO = YEAR(TU.DT_INICIO) + 1
                AND COR_ANT.MES = MONTH(TU.DT_INICIO)-1
                )
    WHERE tu.UNIDADE_RESPONSAVEL = 'ESPEC'
    AND tu.ANO_SEMESTRE_INICIO = CONVERT(varchar, ld.ANO_REF) + '/' + CONVERT(varchar, ld.PERIODO_REF)
	and year(DT_INICIO) >= 2018
--	and COR.VALOR is not null
	
	),

ALUNOS_TURMAS AS 
(
	SELECT DISTINCT
		ALUNO, 
		IT.*
	FROM 
		VW_FCAV_EXTFIN_LY EX
		INNER JOIN IGPM_TURMAS IT
			ON IT.TURMA = EX.TURMA
)

SELECT AL.*, cast(il.VALOR * al.IGPM as decimal(10,2)) VALOR_CORRECAO,  IL.COBRANCA,ITEMCOBRANCA, LANC_DEB, BOLETO,PARCELA,DATA,VALOR, DESCRICAO FROM 
	ALUNOS_TURMAS AL
	INNER JOIN LY_COBRANCA CO
		ON AL.ALUNO = CO.ALUNO
	INNER JOIN ITENS_LANC IL
		ON IL.COBRANCA = CO.COBRANCA
order by il.COBRANCA, ITEMCOBRANCA