/*
	JOB JOB_EMAIL_VENCTO_EM_7_15_21 
	
	Finalidade: Job para disparar e-mails de aviso de vencimento de cobrança quando atinge
	7, 15 e 21 dias.

	-- EMAIL COBRANCA DANITIELA

	Atualização: 24/01/2020 - A job foi corrigida pelo Bene GTE, pois a mesma nunca funcionou.

Autor: João Paulo

*/
USE LYCEUM
GO

DECLARE @TEXTO			VARCHAR (2000)
DECLARE @DESTINATARIO	VARCHAR (200)
--DECLARE @COBRANCA		VARCHAR (10)
-----
DECLARE	@VTCURSO Varchar(20) 
Declare	@CS_NOME Varchar(300)
Declare @VT_TURMA Varchar(20)
Declare	@EX_ALUNO Varchar(20)
Declare	@PE_NOME_COMPL Varchar(100)
Declare @PE_E_MAIL Varchar(100)
Declare @EX_COBRANCA Numeric(10)
Declare @IL_VALOR Decimal(10,2)
---
DECLARE COB_VENCIDA CURSOR FOR
SELECT 
	VT.CURSO, 
	CS.NOME, 
	VT.TURMA, 
	EX.ALUNO, 
	PE.NOME_COMPL,
	PE.E_MAIL,
	EX.COBRANCA as COBRANCA,
	10.0 as VALOR
	--SUM(IL.VALOR) as VALOR_PAGAR
FROM 
	LYCEUM.dbo.VW_FCAV_EXTRATO_FINANCEIRO2 EX
	INNER JOIN LYCEUM.dbo.VW_FCAV_INI_FIM_CURSO_TURMA VT
		ON VT.TURMA = EX.TURMA
	INNER JOIN LYCEUM.dbo.LY_ITEM_LANC IL
		ON IL.COBRANCA = EX.COBRANCA
	INNER JOIN LYCEUM.dbo.LY_CURSO CS
		ON CS.CURSO = VT.CURSO
	INNER JOIN LYCEUM.dbo.LY_ALUNO AL
		ON AL.ALUNO = EX.ALUNO
	INNER JOIN LYCEUM.dbo.LY_PESSOA PE
		ON PE.PESSOA = AL.PESSOA
WHERE 
	VT.UNIDADE_RESPONSAVEL IN ('CAPAC','ESPEC', 'DIFUS')  --> Somente para os cursos de Capacitação, Especialização e Difusão;
	AND DAY(DATA_DE_VENCIMENTO) between 15 and 18	 --> Boletos com o dia de vencimento entre 15 e 18. Se refere aos boletos de mensalidades;
	AND DATEDIFF(DAY,DATA_DE_VENCIMENTO,GETDATE()) IN ('7','15','21')--> 15 dias - prazo para negociação com o banco /  90 dias para envio ao SERASA;
	AND IL.PARCELA != 1	 --> Não traz o primeiro boleto de matrícula;
	AND EX.VALOR_PAGO = 0	 --> Boletos que estão com o pago zerados;
	AND VALOR_PAGAR > 0	 --> Valor a pagar maior que zero;
	AND EX.SITUACAO_BOLETO = 'Vencido'	 --> Boletos vencidos.
GROUP BY VT.CURSO,CS.NOME,VT.TURMA,EX.ALUNO,PE.NOME_COMPL,PE.E_MAIL, EX.COBRANCA

OPEN COB_VENCIDA			
FETCH NEXT FROM COB_VENCIDA 
INTO @VTCURSO, @CS_NOME, @VT_TURMA, @EX_ALUNO , @PE_NOME_COMPL , @PE_E_MAIL , @EX_COBRANCA, @IL_VALOR 
----------------------------
WHILE @@FETCH_STATUS = 0
BEGIN 		
		
	            --SELECT DISTINCT
			    -- @DESTINATARIO = PES.E_MAIL,
			    -- @TEXTO =  
				-- '<BR>
				-- Prezado(a) '+RTRIM(PES.NOME_COMPL)+', Bom Dia!<BR>
				Set  @TEXTO =  
				'<BR>
				Prezado(a) '+RTRIM(@PE_NOME_COMPL)+', Bom Dia!<BR>

				<BR>
				Informamos que consta pendente de pagamento em nosso sistema parcelas de mensalidade <BR>
				<BR>
				referente ao seu Curso de Especializa&ccedil;&atilde;o.<BR>
				<BR>
				O Boleto deve ser atualizado, at&eacute; 30 dias ap&oacute;s o vencimento, no site do banco Santander, atrav&eacute;s do link: <a href="https://www.santander.com.br/br/resolva-on-line/reemissao-de-boleto-vencido">https://www.santander.com.br/br/resolva-on-line/reemissao-de-boleto-vencido</a>  <BR>
				Ou entrar em contato para atualiza&ccedil;&atilde;o do boleto.<BR>
				<BR>
				O vencimento de cada mensalidade ocorre no dia 15 de cada m&ecirc;s, evite pagar juros.<BR>
				<BR>
				Estamos &agrave; disposi&ccedil;&atilde;o.  <BR>
				<BR>
				Cláudia / Danitiela<BR>
				Tel. (11) 3024-2257/2272 Whatsapp: (11) 97590-5458<BR>
				e-mail: cobranca@vanzolini.com.br<BR>
				<BR>
				Hor&aacute;rio de atendimento: segunda &agrave; sexta-feira das 8h00 &agrave;s 16h30.<BR>
				Caso o pagamento tenha sido efetuado, solicitamos desconsiderar a cobrança e pedimos a gentileza de nos contatar para a devida regulariza&ccedil;&atilde;o. <BR>
				<BR>
				Cordialmente,<BR>
				<BR>
				Departamento de Cobran&ccedil;a<BR>
				<BR>

				'

   --         FROM LYCEUM.dbo.VW_FCAV_EXTRATO_FINANCEIRO2 VW
			--INNER JOIN LYCEUM.dbo.LY_PESSOA PES ON VW.PESSOA = PES.PESSOA
			--WHERE VW.COBRANCA = @EX_COBRANCA
			----WHERE VW.COBRANCA = @COBRANCA

			 -------------------------------------------------------------      

				Exec MSDB.dbo.SP_SEND_DBMAIL
					@PROFILE_NAME =
						-- Desenvolvimento/homologação
						-- FCAV_HOMOLOGACAO,
						-- Produção
						VANZOLINI_BD_1,    
                        @RECIPIENTS =  @PE_E_MAIL, 
                        @blind_copy_recipients = 'cobranca@vanzolini.com.br; danitiela.kermessi@vanzolini.com.br; claudia.liberal@vanzolini.com.br;
				        gabriel.scalione@vanzolini.com.br',  
	                    @reply_to = 'cobranca@vanzolini.com.br',
                        @SUBJECT = 'Aviso de mensalidade vencida - Fundacao Vanzolini',  
                        @BODY = @TEXTO,  
                        @BODY_FORMAT = HTML;  

					   
	FETCH NEXT FROM COB_VENCIDA 
	INTO @VTCURSO,@CS_NOME, @VT_TURMA,@EX_ALUNO ,@PE_NOME_COMPL ,@PE_E_MAIL ,@EX_COBRANCA,@IL_VALOR 

END

CLOSE COB_VENCIDA 
DEALLOCATE COB_VENCIDA 
