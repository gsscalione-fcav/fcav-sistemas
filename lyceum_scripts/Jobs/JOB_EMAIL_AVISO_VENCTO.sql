USE DADOSADVP12
DECLARE @TEXTO			VARCHAR (2000)
DECLARE @DESTINATARIO	VARCHAR (200)
DECLARE @RECNO			VARCHAR (10)

---CONDICAO PARA VERIFICAR O DIA ÚTIL
Declare @diautil  datetime
set @diautil = LYCEUM.dbo.FN_FCAV_GetDiaUtil_Feriados(getdate()-1,1)


DECLARE NF_VENCTO CURSOR FOR

SELECT	R_E_C_N_O_
FROM	SE1010
WHERE	D_E_L_E_T_ = ''
	AND (E1_CATIV IN ('401','402','403') OR E1_CATIV BETWEEN '800' AND '899')
	AND E1_BAIXA = ''
--PARA NF A VENCER ENTRE 7 E 15 DIAS
	AND DATEDIFF(DAY,@diautil,convert(date,E1_VENCREA,103)) IN ('7','15')


OPEN NF_VENCTO
FETCH NEXT FROM NF_VENCTO INTO @RECNO
WHILE @@FETCH_STATUS = 0
BEGIN 
		SELECT DISTINCT @DESTINATARIO = A1_EMAIL
		FROM SA1010 SA1
			INNER JOIN SE1010 SE1 ON SA1.A1_COD = SE1.E1_CLIENTE
		WHERE	SA1.D_E_L_E_T_ = ''
			AND SE1.D_E_L_E_T_ = ''
			AND SE1.R_E_C_N_O_ = @RECNO
       
	   SELECT  
                @TEXTO =  
				'
				<BR>
				Funda&ccedil;&atilde;o Vanzolini – Aviso de vencimento.<BR>
				<BR>
				<BR>
				Prezado(a) Cliente <b>'+RTRIM(A1_NOME)+'</b>,<BR>
				<BR>
				Apenas para seu controle, informamos que a Nota Fiscal <b>'+RTRIM(E1_NFELETR)+'</b> com RPS <b>'+RTRIM(E1_NUM)+'</b> ir&aacute; vencer em <b>'+CAST(DATEDIFF(DAY,GETDATE(),convert(date,E1_VENCREA,103)) AS varchar(2))+'</b> dias.<BR>
				<BR>
				Caso n&atilde;o tenha recebido a NF e Boleto Banc&aacute;rio, entrar em contato com Caio no e-mail: caio@vanzolinicert.org.br e ou telefone (11) 3913-7118.<BR>
				<BR>
				Atenciosamente<BR>
				Funda&ccedil;&atilde;o Vanzolini<BR>'   


            FROM SE1010 SE1 
			INNER JOIN SA1010 SA1 ON SA1.A1_COD = SE1.E1_CLIENTE
            WHERE SA1.D_E_L_E_T_ = ''
				AND SE1.D_E_L_E_T_ = ''
				AND SE1.R_E_C_N_O_ = @RECNO
            -------------------------------------------------------------      
            EXEC
					MSDB.dbo.SP_SEND_DBMAIL
						@PROFILE_NAME =
							-- Desenvolvimento/homologação
							--FCAV_HOMOLOGACAO,
							-- Produção
							VANZOLINI_BD_1,    
                         @RECIPIENTS = @DESTINATARIO,  --'rafael@vanzolinicert.org.br',
                         @blind_copy_recipients = 'gabriel.scalione@vanzolini.com.br;william.moraes@vanzolini.com.br;caio@vanzolinicert.org.br',  
						 @reply_to = 'caio@vanzolinicert.org.br',
                         @SUBJECT = 'Aviso de vencimento de NF - Fundacao Vanzolini',  
                         @BODY = @TEXTO,  
                         @BODY_FORMAT = HTML;  

						   
FETCH NEXT FROM NF_VENCTO INTO @RECNO
END

CLOSE NF_VENCTO 
DEALLOCATE NF_VENCTO 

SET @RECNO = ''

DECLARE NF_VENCIDA CURSOR FOR

SELECT	R_E_C_N_O_
FROM	SE1010
WHERE	D_E_L_E_T_ = ''
	AND (E1_CATIV IN ('401','402','403') OR E1_CATIV BETWEEN '800' AND '899')
	AND E1_BAIXA = ''
--PARA NF JÁ VENCIDAS EM 03, 05, 10, 15 ,20, 25, 30, 45, 60 E 90 DIAS
	AND DATEDIFF(DAY, @diautil,convert(date,E1_VENCREA,103)) IN ('-3' , '-5' , '-10' , '-15', '-20' ,'-25', '-30', '-45', '-60', '-90')


OPEN NF_VENCIDA
FETCH NEXT FROM NF_VENCIDA INTO @RECNO
WHILE @@FETCH_STATUS = 0
BEGIN 
		SELECT DISTINCT @DESTINATARIO = A1_EMAIL
		FROM SA1010 SA1
			INNER JOIN SE1010 SE1 ON SA1.A1_COD = SE1.E1_CLIENTE
		WHERE	SA1.D_E_L_E_T_ = ''
			AND SE1.D_E_L_E_T_ = ''
			AND SE1.R_E_C_N_O_ = @RECNO
       
	   SELECT  
                @TEXTO =  
				'
				<BR>
				Funda&ccedil;&atilde;o Vanzolini – Nota Fiscal em aberto.<BR>
				<BR>
				<BR>
				Prezado(a) Cliente <b>'+RTRIM(A1_NOME)+'</b>,<BR> 
				<BR>
				At&eacute; a presente data, n&atilde;o identificamos em nosso sistema o pagamento da Nota Fiscal abaixo relacionada.<BR>
				<BR>
				<BR>
				<B>BOLETO:</B> '+RTRIM(E1_NUMBCO)+'  <B>RPS:</B> '+RTRIM(E1_NUM)+'  <B>VALOR:</B> R$'+RTRIM(E1_VALOR)+'  <B>VENCIMENTO:</B> '+SUBSTRING(E1_VENCREA,7,2)+'/'+SUBSTRING(E1_VENCREA,5,2)+'/'+SUBSTRING(E1_VENCREA,1,4)+'<BR>
				<BR>
				<BR>
				Solicitamos a regulariza&ccedil;&atilde;o do d&eacute;bito atrav&eacute;s do link abaixo e caso haja necessidade de esclarecimentos entrar em contato atrav&eacute;s do e-mail karla.franco@vanzolinicert.org.br e/ou Tel.: (11) 3913-7153 – WhatsApp: (11) 99145-0958.<BR>
				<BR>
				Caso o pagamento j&aacute; tenha sido efetuado, por favor encaminhar o respectivo comprovante e desconsidere este e-mail.<BR>
				<BR>
				<a href="https://www.santander.com.br/portal/wps/script/boleto_online_conv/ReemissaoBoleto.do">https://www.santander.com.br/portal/wps/script/boleto_online_conv/ReemissaoBoleto.do</a><BR>
				<BR>
				<BR>
				Atenciosamente.<BR>
				Funda&ccedil;&atilde;o Vanzolini<BR>
				'


            FROM SE1010 SE1 
			INNER JOIN SA1010 SA1 ON SA1.A1_COD = SE1.E1_CLIENTE
            WHERE SA1.D_E_L_E_T_ = ''
				AND SE1.D_E_L_E_T_ = ''
				AND SE1.R_E_C_N_O_ = @RECNO
            -------------------------------------------------------------      
            EXEC
					MSDB.dbo.SP_SEND_DBMAIL
						@PROFILE_NAME =
							-- Desenvolvimento/homologação
							--FCAV_HOMOLOGACAO,
							-- Produção
							VANZOLINI_BD_1,    
                         @RECIPIENTS = @DESTINATARIO, 
                         @blind_copy_recipients = 'gabriel.scalione@vanzolini.com.br;william.moraes@vanzolini.com.br;karla.franco@vanzolinicert.org.br',  
						 @reply_to = 'karla.franco@vanzolinicert.org.br',
                         @SUBJECT = 'Aviso de NF vencida - Fundacao Vanzolini',  
                         @BODY = @TEXTO,  
                         @BODY_FORMAT = HTML;  


INSERT INTO FCAV_EMAIL_CERTIF
SELECT  
	E1_CLIENTE  AS CLIENTE, 
	E1_NUMBCO	AS BOLETO, 
	E1_NUM AS TITULO_RPS, 
	E1_VALOR AS VALOR, 
	E1_VENCREA AS VENCTO, 
	CONVERT(VARCHAR(8), GETDATE(), 112) AS DT_ENVIO,
	'Cobranca' AS TIPO
FROM	SE1010 SE1 
WHERE	SE1.R_E_C_N_O_ = @RECNO


						   
FETCH NEXT FROM NF_VENCIDA INTO @RECNO
END

CLOSE NF_VENCIDA 
DEALLOCATE NF_VENCIDA





----------------------------------------------------

-- Etapa 2 da JOB

-- INSERT NA TABELA PARA SER USADA NO RELATORIO

BEGIN
	BEGIN TRANSACTION

		TRUNCATE TABLE FCAV_CONSULTA_DBMAIL

		INSERT INTO FCAV_CONSULTA_DBMAIL
			SELECT 
				TITULO_RPS ,
				NOME ,
				DESTINATARIO ,
				ASSUNTO ,
				MENSAGEM ,
				DT_SOLICIT ,
				DT_ENVIO ,
				STATUS 
			FROM 
				VW_FCAV_CONSULTA_DBMAIL

	COMMIT
END


