--* ***************************************************************
--*
--*    	*** TRIGGER TR_FCAV_CONVOC_MANUAL  ***
--*	
--*	DESCRICAO:
--*	- Aviso por email para candidatos aprovados no Processo Seletivo
--*	
--*	USO:
--*	- Após a Secretaria fazer a Convocação Manual de algum candidato, ele
--* receberá um email com os próximos passos para terminar sua matrícula
--*
--*	ALTERAÇÕES:
--*      19/01/2017: > Retirado as informações sobre o CCMI, pois não terá mais esse curso. Gabriel
--*					 > Alterado o filtro para os cursos de Atualização e Palestra. Agora o filtro é 
--*					 por unidade responsável e não mais por curso. Gabriel
--*
--*	Autor: João Paulo
--*	Data de criação:	2014-08-07
--*	
--* ***************************************************************        
ALTER TRIGGER [dbo].[TR_FCAV_CONVOC_MANUAL]
ON [dbo].[LY_CONVOCADOS_VEST]
AFTER INSERT

AS

    DECLARE @CANDIDATO varchar(20)
    DECLARE @PESSOA varchar(20)
    DECLARE @NOME varchar(100)
    DECLARE @CONCURSO varchar(20)
    DECLARE @CURSO varchar(100)
    DECLARE @ASSUNTO varchar(100)
    DECLARE @TEXTO varchar(8000)
    DECLARE @ENDERECO varchar(100)
    DECLARE @data1 varchar(30)
    DECLARE @data2 varchar(30)
    DECLARE @data3 varchar(30)
    DECLARE @DESTINATARIO varchar(100)
    DECLARE @INICIO_CURSO varchar(30)
    DECLARE @ENCAMINHA_EMAIL varchar(100)
    DECLARE @RESPONDER_PARA varchar(100)
    DECLARE @HORARIO varchar(80)
    DECLARE @TELEFONE varchar(200)
    DECLARE @LINK varchar(200)

    SET @CANDIDATO = NULL
    SET @PESSOA = NULL
    SET @NOME = NULL
    SET @CONCURSO = NULL
    SET @CURSO = NULL
    SET @ASSUNTO = NULL
    SET @TEXTO = NULL
    SET @ENDERECO = NULL
    SET @data1 = CONVERT(varchar, (dbo.FN_FCAV_GetDiaUtil(DBO.FN_DATADIASEMHORA(GETDATE()), 1)), 103)
    SET @data2 = CONVERT(varchar, (dbo.FN_FCAV_GetDiaUtil(DBO.FN_DATADIASEMHORA(GETDATE()), 1)), 103)
    SET @data3 = NULL
    SET @DESTINATARIO = NULL
    SET @RESPONDER_PARA = NULL
    SET @INICIO_CURSO = NULL
    SET @ENCAMINHA_EMAIL = NULL
    SET @HORARIO = NULL
    SET @TELEFONE = NULL
    SET @LINK = NULL

    BEGIN

        SELECT
            @CANDIDATO = CANDIDATO, --'201400274',    
            @CONCURSO = CONCURSO --'CCBB T 28'    

        FROM INSERTED

        -------------------------------------------------------------    
        SET @PESSOA = (SELECT
            PESSOA
        FROM LYCEUM.dbo.LY_CANDIDATO C
        WHERE C.CANDIDATO = @CANDIDATO
        AND C.CONCURSO = @CONCURSO)
        -------------------------------------------------------------    
        SET @NOME = (SELECT
            NOME_COMPL
        FROM LYCEUM.dbo.LY_CANDIDATO c
        WHERE C.CANDIDATO = @CANDIDATO
        AND C.CONCURSO = @CONCURSO)
        -------------------------------------------------------------    
        SET @CURSO = (SELECT
            CASE
                WHEN CUR.FACULDADE = 'ATUAL' OR
                    CUR.FACULDADE = 'PALES' THEN OFC.DESCRICAO_ABREV
                ELSE NOME
            END
        FROM LYCEUM.dbo.LY_OFERTA_CURSO AS OFC
        INNER JOIN LY_CURSO AS CUR
            ON (OFC.CURSO = CUR.CURSO)
        WHERE OFC.CONCURSO = @CONCURSO)
        -------------------------------------------------------------    
        SET @ASSUNTO = (SELECT
            CASE
                WHEN CUR.FACULDADE = 'ATUAL' OR
                    CUR.FACULDADE = 'PALES' THEN 'CONVOCADO: '
                ELSE 'SELECIONADO: '
            END
        FROM LYCEUM.dbo.LY_OFERTA_CURSO AS OFC
        INNER JOIN LY_CURSO AS CUR
            ON (OFC.CURSO = CUR.CURSO)
        WHERE OFC.CONCURSO = @CONCURSO)
        + @NOME + ' - ' + @CONCURSO
        -------------------------------------------------------------    
        SELECT
          @DESTINATARIO =  LOWER(ltrim(Rtrim(c.E_MAIL)))
        FROM LYCEUM.dbo.LY_CANDIDATO c
        WHERE C.CANDIDATO = @CANDIDATO
        AND C.CONCURSO = @CONCURSO
        -------------------------------------------------------------    
        SELECT
            @ENDERECO =
            (CASE
                WHEN UNIDADE_FISICA = 'Paulista' THEN 'Av. Paulista, 967 - 3º andar - Bela Vista'
                WHEN UNIDADE_FISICA = 'USP' THEN 'Av. Prof Almeida Prado, 531 - Cidade Universitária'
            END)
        FROM LY_OFERTA_CURSO
        WHERE CONCURSO = @CONCURSO

        -------------------------------------------------------------    
        SELECT
            @HORARIO =
            (CASE
                WHEN UNIDADE_FISICA = 'Paulista' THEN '2ªf à 6ªf das 14h00 às 21h00'
                WHEN UNIDADE_FISICA = 'USP' THEN '2ªf à 5ªf das 9h00 às 21h30h, 6ªf das 9h00 às 20h30'
            END)
        FROM LY_OFERTA_CURSO
        WHERE CONCURSO = @CONCURSO

        -------------------------------------------------------------    
        SELECT
            @TELEFONE =
            (CASE
                WHEN UNIDADE_FISICA = 'Paulista' THEN 'Secretaria Acadêmica Paulista: Via e-mail secretariapta@vanzolini.org.br ou pelo telefone:(11) 3145-3700'
                WHEN UNIDADE_FISICA = 'USP' THEN 'Secretaria Acadêmica USP: Via e-mail secretariausp@vanzolini.org.br ou pelo telefone: (11) 5525-5830'
            END)
        FROM LY_OFERTA_CURSO
        WHERE CONCURSO = @CONCURSO
        -------------------------------------------------------------    
        SELECT
            @INICIO_CURSO = CONVERT(varchar(30), DT_INICIO, 103)
        FROM VW_FCAV_INI_FIM_CURSO_TURMA
        WHERE CONCURSO = @CONCURSO
        ORDER BY DT_INICIO
        -------------------------------------------------------------    
        SELECT
            @data3 = CONVERT(varchar, (dbo.FN_FCAV_GetDiaUtil(DBO.FN_DATADIASEMHORA(DT_INICIO - 3), 1)), 103)
        FROM VW_FCAV_INI_FIM_CURSO_TURMA
        WHERE CONCURSO = @CONCURSO
        -------------------------------------------------------------    
        SELECT
            @ENCAMINHA_EMAIL =
            (CASE
                WHEN (UNID_FISICA = 'Paulista' AND
                    TIPO NOT LIKE 'ATUALIZAÇÃO') THEN 'suporte_techne@vanzolini.org.br; '			-- *** ATUALIZADO EM 11/09/15 *** FOI EXCLUÍDO O EMAIL ATENDIMENTO@ PARA FICAR SOMENTE O SECRETARIAPTA@  
                WHEN (UNID_FISICA = 'Paulista' AND
                    TIPO LIKE 'ATUALIZAÇÃO' AND
                    GRUPO NOT LIKE '-CERT') THEN 'suporte_techne@vanzolini.org.br; '				--SE FOR CURSO DE ATUALIZAÇÃO O E-MAIL SERÁ ENCAMINHADO PARA O SECRETARIAPTA  
                WHEN (UNID_FISICA = 'Paulista' AND
                    GRUPO LIKE '-CERT') THEN 'suporte_techne@vanzolini.org.br;'						--SE FOR CURSO DA CERTIFICAÇÃO SERÁ ENCAMINHADO PARA MARCIA.  
                WHEN UNID_FISICA = 'USP' THEN 'suporte_techne@vanzolini.org.br;'
            END)
        FROM VW_FCAV_COORDENADOR_TURMA
        WHERE CONCURSO = @CONCURSO
        -------------------------------------------------------------    
        SELECT
            @RESPONDER_PARA = (CASE
                WHEN UNIDADE_FISICA = 'Paulista' THEN 'suporte_techne@vanzolini.org.br'				--jessica.lima@vanzolini.org.br; erica.cesaroni@vanzolini.org.br    
                WHEN UNIDADE_FISICA = 'USP' THEN 'suporte_techne@vanzolini.org.br'
            END)
        FROM LY_OFERTA_CURSO
        WHERE CONCURSO = @CONCURSO
        -------------------------------------------------------------    
        SELECT
            @TEXTO =
                    CASE
                        WHEN CR.FACULDADE = 'ATUAL' THEN 'Prezado (a) Candidato (a),   
							 <br>  
							 Confirmamos a realização do Curso de ' + @CURSO + '.<br>    
							 <br>    
							 Inicio previsto do curso: ' + @INICIO_CURSO + ' <br>    
							 <br>    
							 Para participar é necessário que acesse o Portal de Inscrições,   
							 Link xxxx  com o seu Login e senha definidos no momento da inscrição.<br>    
							 <ul>    
							 <li>Completar informações cadastrais;    
							 <li>Definir responsável financeiro (se for empresa, deve clicar em ""OUTRO"" para inserir o CNPJ);   
							 <li>Dar o aceite no Contrato de Prestação de Serviços;   
							 <li>Gerar boleto e realizar o pagamento.    
							 </ul>    
							 <br>    
							 <br>  
							 <br>Mais informações: ' + @TELEFONE + '      
							 <br>    
							 Permanecemos à disposição.<br>    
							 Fundação Vanzolini<br>'

                        ELSE 'Parabéns!<BR>    
							 <BR>    
							 Informamos que você foi <b>SELECIONADO</b> para o Curso de ' + @CURSO + '.<br>    
							 <br>    
							 Sua Pré Matrícula está condicionada a conclusão das etapas abaixo, que deverão ser concluídas até o dia ' + @data2 + '.<br>    
							 <br>    
							 A - Acessar o Portal de Inscrições, no Link: xxxxx <br>    
							 <ul>    
							 <li>Fazer o login com o usuário e senha definidos na inscrição e completar as informações de sua pré matrícula;    
							 <li>Inserir o Responsável Financeiro;    
							 <li>Definir a forma de pagamento;    
							 <li>Aceitar e emitir o contrato;    
							 <li>Emitir e pagar do boleto.    
							 </ul>    
							 <br>    
							 B - <b>Comparecer</b> até a data acima para entrega da documentação:<br>    
							 (cópia autenticada ou original com cópia simples):    
							 <ul>    
							 <li>Contrato de Prestação de Serviços Educacionais (02 vias assinadas);    
							 <li>Cópia do Diploma do curso superior, mas original para conferência;
							 <li>Cópia do CPF, RG e Comprovante de Residência;   
							 <li>01 foto 3x4;    
							 <li>Local de entrega: ' + @ENDERECO + '    
							 <li>Horário: ' + @HORARIO + '    
							 </ul>    
							 <BR>    
							 <br>    
							 Condição obrigatória para efetivação da matrícula:    
							 <ul>    
							 <li>A matrícula está condicionada ao aceite e emissão do contrato de prestação de serviços, entrega da documentação e pagamento do boleto.    
							 </ul>    
							 <BR>    
							 <BR>    
							 Inicio previsto do curso: ' + @INICIO_CURSO + '<BR>    
							 <br>    
							 Mais informações: ' + @TELEFONE + '    
							 <br>    
							 Permanecemos à disposição.<br>    
							 Fundação Vanzolini<br>'
                    END
        FROM LY_OFERTA_CURSO OC
		INNER JOIN LY_CURSO CR 
			ON CR.CURSO = OC.CURSO
        WHERE CONCURSO = @CONCURSO
        -------------------------------------------------------------    

        EXEC MSDB.dbo.SP_SEND_DBMAIL @PROFILE_NAME = FCAV_HOMOLOGACAO, -- PROFILE DA BASE TESTE: VANZOLINI_BD_TESTE    
                                     @RECIPIENTS = @DESTINATARIO,
                                     @blind_copy_recipients = @ENCAMINHA_EMAIL,
                                     @reply_to = @RESPONDER_PARA,
                                     @SUBJECT = @ASSUNTO,
                                     --@BODY = 'SEU CÓDIGO: ' + @TESTE + ' E SEU NOME É: '+ @TESTE2,    
                                     @BODY = @TEXTO,
                                     @BODY_FORMAT = HTML;




    END