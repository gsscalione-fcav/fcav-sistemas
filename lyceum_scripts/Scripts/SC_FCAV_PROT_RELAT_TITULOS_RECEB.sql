SELECT
	CASE WHEN CT2_HIST LIKE 'Cobran%a: %' THEN 'Importado Lyceum'
	ELSE 'Lançamento Protheus' END ORIGEM,
	CT2_FILIAL,
	CONVERT(DATE,CT2_DATA,103) CT2_DATA,
	CT2_LOTE,
	CT2_SBLOTE,
	CT2_DOC,
	CT2_LINHA,
	CT2_DC,
	CT2_DEBITO,
	CT2_CREDIT,
	CT2_MOEDLC,
	CT2_HIST,
	CT2_ORIGEM,
	CT2_VALOR,
	CT2_CCD,
	CT2_CCC,
	CT2_ITEMD,
	CT2_ITEMC,
	CT2_CLVLDB,
	CT2_CLVLCR,
	CT2_ROTINA,
	CT2_USERGI,
	CT2_USERGA,
	D_E_L_E_T_,
	R_E_C_N_O_,
	R_E_C_D_E_L_,
	CT2_CODCLI

FROM 
	CT2010 
WHERE D_E_L_E_T_ = '' 
	AND (CT2_CCD = '406555225' 
	OR CT2_CCC = '406555225')
--	and CT2_HIST = 'RECLASSIF.COBRANÇA:164916-MENSALIDADE DO'
	
ORDER BY
	CONVERT(DATE,CT2_DATA,103)

SELECT CQ2_CCUSTO, 
       CONVERT(DATETIME, CQ2_DATA) AS CQ2_DATA, 
       CQ2_CONTA, 
       CT1_DESC01, 
       Sum(SALDO)                  AS SALDO, 
       TIPO =( IIF(Sum(SALDO) > 0, 'D', 'C') ), 
       CORDENA, 
       NOME, 
       CTT_CATIV, 
       DESCRCC, 
       CLIENTE 
FROM   (SELECT CQ2_FILIAL                                    AS FILIAL, 
               '  '                                          AS CQ2_DATA, 
               CQ2_CCUSTO, 
               CQ2_CONTA, 
               CT1_DESC01, 
               CQ2_DEBITO                                    AS DEBITO, 
               CQ2_CREDIT                                    AS CREDITO, 
               Cast(CQ2_CREDIT - CQ2_DEBITO AS MONEY)        AS SALDO, 
               'D'                                           AS CT1_NORMAL, 
               ISNULL(CTT_FV_CRD, '')                        AS CORDENA, 
               ISNULL(ZR_NOME, '')                           AS NOME, 
               CTT_CATIV, 
               CTT_DESC01                                    AS DESCRCC, 
               CQ2.R_E_C_N_O_, 
               ( A1_COD + '-' + A1_LOJA + ' -- ' + A1_NOME ) AS CLIENTE 
        FROM   CQ2010 CQ2 
               INNER JOIN CT1010 CT1 
                       ON CT1_CONTA = CQ2_CONTA 
                          AND CT1.D_E_L_E_T_ = '' 
                          AND CT1_CLASSE = '2' 
                          AND CT1_FILIAL = '  ' 
               INNER JOIN CTT010 CTT 
                       ON CTT_CUSTO = CQ2_CCUSTO 
                          AND CTT.D_E_L_E_T_ = '' 
                          AND CTT_XSIGLA BETWEEN '          ' AND 'ZZZZZZZZZZ' 
                          AND CTT_CATIV = '406' 
                          AND CTT_FILIAL = '  ' 
               LEFT OUTER JOIN SZR010 SZR 
                            ON ZR_COD = CTT_FV_CRD 
                               AND SZR.D_E_L_E_T_ = '' 
                               AND ZR_FILIAL = '01' 
               INNER JOIN SA1010 SA1 
                       ON A1_COD = CTT_FV_CLI 
                          AND A1_FILIAL = '  ' 
                          AND SA1.D_E_L_E_T_ = '' 
        WHERE  CQ2_CCUSTO BETWEEN '406555225' AND '406555225' 
               AND CQ2_CONTA BETWEEN '3                   ' AND 
                                     '99999999999999999999' 
               AND Substring(CQ2_DATA, 1, 6) BETWEEN '201812' AND '201907' 
               AND CQ2_LP <> 'Z' 
               AND CQ2_FILIAL = '01' 
        UNION 
        SELECT CQ2_FILIAL                                    AS FILIAL, 
               CONVERT(DATETIME, CQ2_DATA)                   AS CQ2_DATA, 
               CQ2_CCUSTO, 
               CQ2_CONTA, 
               CT1_DESC01, 
               CQ2_DEBITO                                    AS DEBITO, 
               CQ2_CREDIT                                    AS CREDITO, 
               Cast(CQ2_CREDIT - CQ2_DEBITO AS MONEY)        AS SALDO, 
               'C'                                           AS CT1_NORMAL, 
               ISNULL(CTT_FV_CRD, '')                        AS CORDENA, 
               ISNULL(ZR_NOME, '')                           AS NOME, 
               CTT_CATIV, 
               CTT_DESC01                                    AS DESCRCC, 
               CQ2.R_E_C_N_O_, 
               ( A1_COD + '-' + A1_LOJA + ' -- ' + A1_NOME ) AS CLIENTE 
        FROM   CQ2010 CQ2 
               INNER JOIN CT1010 CT1 
                       ON CT1_CONTA = CQ2_CONTA 
                          AND CT1.D_E_L_E_T_ = '' 
                          AND CT1_CLASSE = '2' 
                          AND CT1_FILIAL = '  ' 
               INNER JOIN CTT010 CTT 
                       ON CTT_CUSTO = CQ2_CCUSTO 
                          AND CTT.D_E_L_E_T_ = '' 
                          AND CTT_XSIGLA BETWEEN '          ' AND 'ZZZZZZZZZZ' 
                          AND CTT_CATIV = '406' 
               LEFT OUTER JOIN SZR010 SZR 
                            ON ZR_COD = CTT_FV_CRD 
                               AND SZR.D_E_L_E_T_ = '' 
                               AND ZR_FILIAL = '01' 
               LEFT OUTER JOIN SA1010 SA1 
                            ON A1_COD = CTT_FV_CLI 
                               AND A1_FILIAL = '  ' 
                               AND SA1.D_E_L_E_T_ = '' 
        WHERE  CQ2_CCUSTO BETWEEN '406555225' AND '406555225' 
               AND CQ2_CONTA BETWEEN '3                   ' AND '99999999999999999999' 
               AND Substring(CQ2_DATA, 1, 6) BETWEEN '201812' AND '201907' 
               AND CQ2_LP <> 'Z'
		
		) AS TRB 

WHERE  FILIAL = '01' 
       AND CORDENA = '000077' 
       AND CTT_CATIV = '408' 
GROUP  BY FILIAL, 
          CQ2_DATA, 
          CQ2_CONTA, 
          CT1_DESC01, 
          CT1_NORMAL, 
          CQ2_CCUSTO, 
          CORDENA, 
          NOME, 
          CTT_CATIV, 
          DESCRCC, 
          CLIENTE 
ORDER  BY CQ2_DATA ,
		  CORDENA, 
          CTT_CATIV, 
          CQ2_CCUSTO, 
          CQ2_CONTA
 
 
 
 SELECT * FROM VW_FCAV_EXTFIN_LY WHERE CENTRO_DE_CUSTO = 408536453 order by COBRANCA
  