/*
	JOB JOB_EMAIL_VENCTO_APOS_30 
	
	Finalidade: Job para disparar e-mails de aviso de vencimento de cobrança 
				quando atinge 30 dias após o vencimento.

	-- EMAIL COBRANCA DANITIELA

Autor: João Paulo

*/


USE LYCEUM
GO

DECLARE @TEXTO			VARCHAR (2000)
DECLARE @DESTINATARIO	VARCHAR (200)
DECLARE @COBRANCA		VARCHAR (10)

DECLARE COB_VENCIDA CURSOR FOR


SELECT 
	--VT.CURSO, CS.NOME, VT.TURMA, 
	--EX.ALUNO, PE.NOME_COMPL,PE.E_MAIL,
	EX.COBRANCA COBRANCA
	--SUM(IL.VALOR) VALOR_PAGAR
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
AND DATEDIFF(DAY,DATA_DE_VENCIMENTO,GETDATE()) between 30 and 90  --> 15 dias - prazo para negociação com o banco /  90 dias para envio ao SERASA;
AND IL.PARCELA != 1	 --> Não traz o primeiro boleto de matrícula;
AND EX.VALOR_PAGO = 0	 --> Boletos que estão com o pago zerados;
AND VALOR_PAGAR > 0	 --> Valor a pagar maior que zero;
AND EX.SITUACAO_BOLETO = 'Vencido'	 --> Boletos vencidos.
GROUP BY VT.CURSO,CS.NOME,VT.TURMA,EX.ALUNO,PE.NOME_COMPL,PE.E_MAIL, EX.COBRANCA



OPEN COB_VENCIDA

FETCH NEXT FROM COB_VENCIDA 
INTO @COBRANCA

WHILE @@FETCH_STATUS = 0
BEGIN 

	   SELECT  DISTINCT
				@DESTINATARIO = PES.E_MAIL,
                @TEXTO =  
				'
				<BR>
				Prezado(a) '+RTRIM(PES.NOME_COMPL)+', Bom Dia!<BR>
				<BR>
				Informamos que consta pendente de pagamento em nosso sistema parcelas de mensalidade <BR>
				<BR>
				referente ao seu Curso de Especializa&ccedil;&atilde;o.<BR>
				<BR>
				Solicitamos que entre em contato, para negocia&ccedil;&atilde;o do valor em aberto, o mais breve poss&iacute;vel.<BR>
				<BR>
				Parcelas vencidas a mais de 90 dias, ser&atilde;o inseridas no SERASA.<BR>
				<BR>
				Estamos &agrave; disposi&ccedil;&atilde;o.  <BR>
				<BR>
				Cláudia / Danitiela<BR>
				Tel. (11) 3024-2257/2271 Whatsapp: (11) 97590-5458<BR>
				e-mail: cobranca@vanzolini.org.br<BR>
				<BR>
				Hor&aacute;rio de atendimento: segunda &agrave; sexta-feira das 8h00 &agrave;s 16h30.<BR>
				Caso o pagamento tenha sido efetuado, solicitamos desconsiderar a cobrança e pedimos a gentileza de nos contatar para a devida regulariza&ccedil;&atilde;o. <BR>
				<BR>
				Cordialmente,<BR>
				<BR>
				Departamento de Cobran&ccedil;a<BR>
				<BR>

				'


            FROM LYCEUM.dbo.VW_FCAV_EXTRATO_FINANCEIRO2 VW
			INNER JOIN LYCEUM.dbo.LY_PESSOA PES ON VW.PESSOA = PES.PESSOA
			WHERE	VW.COBRANCA = @COBRANCA

            -------------------------------------------------------------      
            EXEC
					MSDB.dbo.SP_SEND_DBMAIL
						@PROFILE_NAME =
							-- Desenvolvimento/homologação
							--FCAV_HOMOLOGACAO,
							-- Produção
							VANZOLINI_BD_1,    
                         @RECIPIENTS = @DESTINATARIO, 
                         @blind_copy_recipients = 'cobranca@vanzolini.com.br; danitiela.kermessi@vanzolini.com.br; 
												  claudia.liberal@vanzolini.com.br;
												  gabriel.scalione@vanzolini.com.br',
						 @reply_to = 'cobranca@vanzolini.com.br',
                         @SUBJECT = 'Aviso de mensalidade vencida - Fundacao Vanzolini',  
                         @BODY = @TEXTO,  
                         @BODY_FORMAT = HTML;  

						   
	FETCH NEXT FROM COB_VENCIDA 
	INTO @COBRANCA

END

CLOSE COB_VENCIDA 
DEALLOCATE COB_VENCIDA 
