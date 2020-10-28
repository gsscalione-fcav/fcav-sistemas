-- LISTA INATIVO?
IF MV_PAR17 == 1
	cLista := " AND CTT_FV_PRJ = 'S'
ElseIf MV_PAR17 == 2
	cLista := " AND CTT_FV_PRJ = 'N'
Else
	cLista := ""
EndIf

If !Empty(MV_PAR11)
	cCordena := "AND CORDENA = '" + MV_PAR11 + "'
EndIf

If !Empty(MV_PAR08)
	cAtiv := " AND CTT_CATIV = '" + MV_PAR08 + "' 
EndIF

if MV_PAR13 == 2
	cInativo := " AND CTT_STATUS <> 'I'  
EndIf

--***************************************************************************************************************************************************************


SELECT 
	CQ2_CCUSTO,CQ2_DATA, CQ2_CONTA, CT1_DESC01, SUM(SALDO) AS  SALDO, TIPO =(IIF( SUM(SALDO) > 0 , 'D' , 'C')) , CORDENA , NOME, CTT_CATIV ,DESCRCC, CLIENTE
FROM ( 

  	select CQ2_FILIAL AS FILIAL , '  ' AS CQ2_DATA ,CQ2_CCUSTO ,CQ2_CONTA ,CT1_DESC01 , CQ2_DEBITO AS DEBITO , CQ2_CREDIT AS CREDITO , cast(CQ2_CREDIT-CQ2_DEBITO as money) AS SALDO , 
	'D' AS CT1_NORMAL,ISNULL(CTT_FV_CRD,'') as CORDENA, ISNULL(ZR_NOME,'') AS NOME, CTT_CATIV, CTT_DESC01 as DESCRCC,CQ2.R_E_C_N_O_,(A1_COD+'-'+A1_LOJA+' -- ' + A1_NOME) as CLIENTE 

		from " + RetSqlName("CQ2") + "  CQ2 

			INNER JOIN " + RetSqlName("CT1") + " CT1 ON CT1_CONTA = CQ2_CONTA  AND CT1.D_E_L_E_T_ = ''  
					AND CT1_CLASSE = '2'  
					AND CT1_FILIAL = '" + xFilial('CT1') + "' 

			INNER JOIN " + RetSqlName("CTT") + " CTT ON CTT_CUSTO = CQ2_CCUSTO AND CTT.D_E_L_E_T_ = ''  
					AND CTT_SIGLA BETWEEN '" + MV_PAR18 + "' AND '" + MV_PAR19 + "' 
cQuery += cInativo
cQuery += cLista
cQuery += cAtiv
					AND CTT_FILIAL = '" + xFilial('CTT') + "'

			LEFT OUTER JOIN " + RetSqlName("SZR") + " SZR ON ZR_COD = CTT_FV_CRD  
				AND SZR.D_E_L_E_T_ = '' 
				AND ZR_FILIAL = '" + xFilial('SZR') + "' 

			INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_COD = CTT_FV_CLI 
				AND A1_FILIAL = '" + xFilial('SA1') + "' 
				AND SA1.D_E_L_E_T_ = ''	

where CQ2_CCUSTO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND 
      CQ2_CONTA  BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' 
	AND SUBSTRING(CQ2_DATA,1,6) < '" + SUBSTR(DTOS(dDtIni),1,6) + "' AND CQ2_LP <> 'Z' AND CQ2_FILIAL = '"+xFilial('CQ2') + "'

UNION 

	select CQ2_FILIAL AS FILIAL,CQ2_DATA ,CQ2_CCUSTO,CQ2_CONTA ,CT1_DESC01 , CQ2_DEBITO AS DEBITO , CQ2_CREDIT AS CREDITO , cast(CQ2_CREDIT-CQ2_DEBITO as money) AS SALDO, 
	'C' AS CT1_NORMAL,ISNULL(CTT_FV_CRD,'') as CORDENA,ISNULL(ZR_NOME,'') AS NOME, CTT_CATIV , CTT_DESC01 as DESCRCC,CQ2.R_E_C_N_O_,(A1_COD+'-'+A1_LOJA+' -- ' + A1_NOME) AS CLIENTE
		from  " + RetSqlName("CQ2") + "  CQ2 

			INNER JOIN " + RetSqlName("CT1") + " CT1 ON CT1_CONTA = CQ2_CONTA  AND CT1.D_E_L_E_T_ = '' 
					AND CT1_CLASSE = '2' 
					AND CT1_FILIAL = '" + xFilial('CT1') + "' 

			INNER JOIN " + RetSqlName("CTT") + " CTT ON CTT_CUSTO = CQ2_CCUSTO AND CTT.D_E_L_E_T_ = ''  
					AND CTT_SIGLA BETWEEN '" + MV_PAR18 + "' AND '" + MV_PAR19 + "' 
cQuery += cInativo + CLFL
cQuery += cLista   + CLFL
cQuery += cAtiv    + CLFL  // "						AND CHARINDEX(CTT_CATIV,'000')=0   

			LEFT OUTER JOIN " + RetSqlName("SZR") + " SZR ON ZR_COD = CTT_FV_CRD  
					AND SZR.D_E_L_E_T_ = '' 
					AND ZR_FILIAL      = '" + xFilial('SZR') + "' 

			LEFT OUTER JOIN " + RetSqlName("SA1") + " SA1 ON A1_COD = CTT_FV_CLI 
					AND A1_FILIAL      = '" + xFilial('SA1') + "' 
					AND SA1.D_E_L_E_T_ = '' 

where CQ2_CCUSTO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND 
      CQ2_CONTA  BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' 

	AND SUBSTRING(CQ2_DATA,1,6) BETWEEN '" + SUBSTR(DTOS(dDtIni+1),1,6) + "' AND '" + SUBSTR(DTOS(dDtFin),1,6) + "' AND CQ2_LP <> 'Z' 

 ) AS TRB 

 WHERE FILIAL = '" + xFilial('CQ2') + "' " + cCordena + cAtiv

 GROUP BY FILIAL,CQ2_DATA ,CQ2_CONTA, CT1_DESC01,CT1_NORMAL,CQ2_CCUSTO,CORDENA, NOME,CTT_CATIV,DESCRCC, CLIENTE 

IF EMPTY(MV_PAR08) .and. EMPTY(MV_PAR11)
	 ORDER BY  CQ2_CCUSTO,CQ2_CONTA ,CQ2_DATA "
ELSE
	IF MV_PAR16 == 1
		 ORDER BY CTT_CATIV,CORDENA, CQ2_CCUSTO,CQ2_CONTA ,CQ2_DATA "
	ELSE
		 ORDER BY CORDENA,CTT_CATIV, CQ2_CCUSTO,CQ2_CONTA ,CQ2_DATA "
	ENDIF
ENDIF
***************************************************************************************************************************************************************



Static Function ValidPerg(cPerg)
Local i,j
ssAlias  := Alias()
aRegs    := {}

dbSelectArea("SX1")
dbSetOrder(1)

cPerg := Padr(cPerg,Len(SX1->X1_GRUPO)," ")

"01","Da Conta				mv_par01",""              ,""              ,""              ,"3"                   ,"",""               ,""               ,""               ,"","","","","","","","","","","","","","","","","CT1",""})
"02","Ate Conta				mv_par02",""              ,""              ,""              ,"99999999999999999999","",""               ,""               ,""               ,"","","","","","","","","","","","","","","","","CT1",""})
"03","Do Centro Custo		mv_par03",""              ,""              ,""              ,""                    ,"",""               ,""               ,""               ,"","","","","","","","","","","","","","","","","CTT",""})
"04","Ate Centro Custo		mv_par04",""              ,""              ,""              ,"ZZZZZZZZZ"           ,"",""               ,""               ,""               ,"","","","","","","","","","","","","","","","","CTT",""})
"05","Periodo"				mv_par05","1º Semestre"   ,"1º Semestre"   ,"1º Semestre"   ,""                    ,"","2º Semestre"    ,"2º Semestre"    ,"2º Semestre"    ,"","","","","","","","","","","","","","","","",""   ,""})
"06","Qual Moeda			mv_par06",""              ,""              ,""              ,"1"                   ,"",""               ,""               ,""               ,"","","","","","","","","","","","","","","","",""   ,""})
"07","Ate o Nivel			mv_par07",""              ,""              ,""              ,"9"                   ,"",""               ,""               ,""               ,"","","","","","","","","","","","","","","","",""   ,""})
"08","Centro de Atividade	mv_par08",""              ,""              ,""              ,"105"                 ,"",""               ,""               ,""               ,"","","","","","","","","","","","","","","","","CTD",""})
"09","Tipo de Relatorio		mv_par09","Analitico"     ,"Analitico"     ,"Analitico"     ,""                    ,"","Sintetico"      ,"Sintetico"      ,"Sintetico"      ,"","","","","","","","","","","","","","","","",""   ,""})
"10","Imprime				mv_par10","Mes Referencia","Mes Referencia","Mes Referencia",""                    ,"","Ultimos 6 meses","Ultimos 6 meses","Ultimos 6 meses","","","","","","","","","","","","","","","","",""   ,""})
"11","Coordenador			mv_par11",""              ,""              ,""              ,""                    ,"",""               ,""               ,""               ,"","","","","","","","","","","","","","","","","SZR",""})
"12","Imprime Cod.Conta		mv_par12","Sim"           ,"Sim"           ,"Sim"           ,""                    ,"","Nao"            ,"Nao"            ,"Nao"            ,"","","","","","","","","","","","","","","","",""   ,""})
"13","Listar Proj.Inativo?	mv_par13","Sim"           ,"Sim"           ,"Sim"           ,""                    ,"","Nao"            ,"Nao"            ,"Nao"            ,"","","","","","","","","","","","","","","","",""   ,""})
"14","Inclui Fornecedores?	mv_par14",""              ,""              ,""              ,"0"                   ,"",""               ,""               ,""               ,"","","","","","","","","","","","","","","","",""   ,""})
"15","Conta Receitas Fut.?	mv_par15",""              ,""              ,""              ,"21301002"            ,"",""               ,""               ,""               ,"","","","","","","","","","","","","","","","","CT1",""})
"16","Ordem da Impressao ?	mv_par16","C.Ativ+Projeto","C.Ativ+Projeto","C.Ativ+Projeto",""                    ,"","Coord.+Projeto" ,"Coord.+Projeto" ,"Coord.+Projeto" ,"","","","","","","","","","","","","","","","",""   ,""})
"17","Listar Proj.Institucional ?mv_par17","Sim","Sim","Sim",""                    ,"","Nao" ,"Nao" ,"Nao" ,"","","Ambos","Ambos","Ambos","","","","","","","","","","","",""   ,""})
"18","Da Sigla ?"			mv_par18",""              ,""              ,""               ,""                    ,"",""              ,""                ,""              ,"","","","","","","","","","","","","","","","","ZZ0",""})
"19","Ate Sigla ?"			mv_par19",""              ,""              ,""               ,""                    ,"",""              ,""                ,""              ,"","","","","","","","","","","","","","","","","ZZ0",""})
"20","Imprime Lyceum"		mv_par20","Sim"            ,"Sim"           ,"Sim"          ,""                    ,"","Não"            ,"Não"            ,"Não"              ,"","","","","","","","","","","","","","","","","",""})


-- IMPRIME LYCEUM
--if mv_par20 == 1
	select sum(VALOR_PAGAR) as PAGAR, SUM(ISNULL(VALOR_PAGO,0)) AS PAGO,UPPER(SITUACAO_BOLETO) as SITBOL
	from VW_FCAV_EXTFIN_LY
	WHERE CENTRO_DE_CUSTO = '" + cCusto + "' AND SIT_ALUNO = 'Ativo' and VALOR_PAGAR > 0 AND DT_ENVIO_CONTAB IS NOT NULL
	group by SITUACAO_BOLETO
	

	SELECT CENTRO_CUSTO,TAXA_FCAV AS FCAV, "
		ISNULL(REPASSE_USP  ,0 ) AS USP, "
		ISNULL(REPASSE_POLI ,0 ) AS POLI, "
		ISNULL(REPASSE_PRO  ,0 ) AS PRO, "
		ISNULL(GARANTIA_PRO ,0 ) AS GARANTIA "
	 FROM VW_FCAV_CC_TAXAS "
	WHERE CENTRO_CUSTO = '" + cCusto + "'"
	
	


SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_CC, E1_EMISSAO, 
				E1_VENCREA,E1_BAIXA ,E1_CATIV, E1_NATUREZ, A.R_E_C_N_O_ E1_RECNO,E1_VALOR,E1_SALDO 
  FROM " + RetSqlName("SE1") + " A  

	  inner join " + RetSqlName("CTT") + " B on CTT_FILIAL = '" + xFilial("CTT") + "' 
							AND B.D_E_L_E_T_ = ' ' 
							AND CTT_CUSTO = E1_CC 
							AND CTT_SIGLA BETWEEN '" + MV_PAR18+ "' AND '" + MV_PAR19 + "' 

IF !EMPTY(MV_PAR11)
								AND CTT_FV_CRD = '" + MV_PAR11 + "' 
EndIF

IF MV_PAR17 == 1
								AND CTT_FV_PRJ = 'S' 
ElseIf MV_PAR17 == 2
								AND CTT_FV_PRJ = 'N' 
EndIf

IF MV_PAR13 == 2
								AND CTT_STATUS <> 'I'	   
ENDIF

	  inner join " + RetSqlName("SZR") + " C on ZR_FILIAL = '" + xFilial("SZR") + "' 
						AND C.D_E_L_E_T_ = ' ' 
						AND CTT_FV_CRD = ZR_COD 


	  inner join " + RetSqlName("SA1") + " D on A1_FILIAL = '" + xFilial("SA1") + "' 
						AND D.D_E_L_E_T_ = ' ' 
						AND A1_COD = E1_CLIENTE 
						AND A1_LOJA = A1_LOJA 

  WHERE E1_FILIAL = '" + xFilial("SE1") + "' 
	AND A.D_E_L_E_T_ = ' ' 
	AND E1_CATIV <>'' 
	AND E1_CC = '" + cCCusto + "' 
	AND E1_EMISSAO <= '" + Dtos(dDtFin) + "' 

	AND ( E1_SALDO > 0 OR E1_BAIXA = '        ' OR  E1_BAIXA > '" + Dtos(dDtFin) + "') 
//AND CHARINDEX(E1_CATIV,'"+GetMV("MV_FV_CATV")+"')>0  
Memowrite("FVCOR11_SE1.sql",cQuery)

IF SELECT('TRBSE1') > 0
	DBSELECTAREA('TRBSE1')
	DBCloseArea()
ENDIF

TCQUERY cQuery NEW ALIAS 'TRBSE1'

dbselectarea('TRBSE1')
dbgotop()

while TRBSE1->(!eof())
	
	IF ALLTRIM(TRBSE1->E1_TIPO) == "NF" .AND.( EMPTY(TRBSE1->E1_BAIXA) .OR. TRBSE1->E1_SALDO > 0)
		
		aCampos[3,2] +=  TRBSE1->E1_SALDO
		
	ElseIf ALLTRIM(TRBSE1->E1_TIPO) == "PA" /*.AND. STOD(TRBSE1->E1_VENCREA) >= (dDatabase-365)*/ .AND.( EMPTY(TRBSE1->E1_BAIXA) .OR. TRBSE1->E1_SALDO > 0)
		
		aCampos[4,2] +=  TRBSE1->E1_SALDO
		
	//ElseIf ALLTRIM(TRBSE1->E1_TIPO) == "PA" .AND. STOD(TRBSE1->E1_VENCREA) < (dDataBase-365) .AND.( EMPTY(TRBSE1->E1_BAIXA) .OR. TRBSE1->E1_SALDO > 0)
		
	//	aCampos[5,2] +=  TRBSE1->E1_SALDO
		
	ElseIf ALLTRIM(TRBSE1->E1_TIPO) == "NDC" .AND. STOD(TRBSE1->E1_VENCREA) >= (dDatabase) .AND.( EMPTY(TRBSE1->E1_BAIXA) .OR. TRBSE1->E1_SALDO > 0)
		
		aCampos[3,2] +=  TRBSE1->E1_SALDO
		
	ElseIf ALLTRIM(TRBSE1->E1_TIPO) == "NDC" .AND. STOD(TRBSE1->E1_VENCREA) < (dDataBase) .AND.( EMPTY(TRBSE1->E1_BAIXA) .OR. TRBSE1->E1_SALDO > 0)
		
		aCampos[2,2] +=  TRBSE1->E1_SALDO
		
	EndIf
	
	TRBSE1->(DBSKIP())

