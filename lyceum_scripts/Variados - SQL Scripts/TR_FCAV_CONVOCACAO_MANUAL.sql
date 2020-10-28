--* ***************************************************************    
--*    
--*     *** TRIGGER TR_FCAV_CONVOC_MANUAL  ***    
--*    
--* DESCRICAO:    
--* - Aviso por email para candidatos aprovados no Processo Seletivo    
--*    
--* USO:    
--* - Após a Secretaria fazer a Convocação Manual de algum candidato, ele    
--* receberá um email com os próximos passos para terminar sua matrícula    

/*********************************************************************************
ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO 

Para o ambiente de PRODUÇÃO, não esquecer de alterar as variáveis: 
	@encaminha_email comentar a parte de homologação,
	@PROFILE_NAME alterar para VANZOLINI_BD

ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO 
**********************************************************************************/

--*    
--* ALTERAÇÕES:    
--*      19/01/2017: > Retirado as informações sobre o CCMI, pois não terá mais esse curso. Gabriel    
--*      > Alterado o filtro para os cursos de Atualização e Palestra. Agora o filtro é    
--*      por unidade responsável e não mais por curso. Gabriel    
--*
--*		 11/05/2017: Mensagem atualizada conforme solicitação da Secretaria. Gabriel
--*    
--* Autor: João Paulo    
--* Data de criação: 2014-08-07    
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
    DECLARE @DESTINATARIO varchar(100)
    DECLARE @INICIO_CURSO varchar(30)
    DECLARE @ENCAMINHA_EMAIL varchar(100)
    DECLARE @RESPONDER_PARA varchar(100)
    DECLARE @HORARIO varchar(80)
    DECLARE @CONTATO varchar(200)
    DECLARE @LINK varchar(200)
    DECLARE @UNIDADE_FISICA varchar(20)

    SET @CANDIDATO = NULL
    SET @PESSOA = NULL
    SET @NOME = NULL
    SET @CONCURSO = NULL
    SET @CURSO = NULL
    SET @ASSUNTO = NULL
    SET @TEXTO = NULL
    SET @ENDERECO = NULL
    SET @DESTINATARIO = NULL
    SET @RESPONDER_PARA = NULL
    SET @INICIO_CURSO = NULL
    SET @ENCAMINHA_EMAIL = NULL
    SET @HORARIO = NULL
    SET @CONTATO = NULL
    SET @LINK = NULL

    BEGIN

        SELECT
            @CANDIDATO = CANDIDATO, --'201400274',    
            @CONCURSO = CONCURSO --'CCBB T 28'    

        FROM INSERTED

        -------------------------------------------------------------    
        SELECT
            @PESSOA = PESSOA,
            @NOME = NOME_COMPL,
            @DESTINATARIO = LOWER(LTRIM(RTRIM(c.E_MAIL)))
        FROM LY_CANDIDATO C
        WHERE C.CANDIDATO = @CANDIDATO
        AND C.CONCURSO = @CONCURSO
        
        -------------------------------------------------------------    
        SELECT
            @CURSO = CS.NOME,
            @UNIDADE_FISICA = OC.UNIDADE_FISICA
        FROM LY_OFERTA_CURSO OC
        INNER JOIN LY_CURSO CS
            ON (OC.CURSO = CS.CURSO)
        WHERE OC.CONCURSO = @CONCURSO
        
        -------------------------------------------------------------
        IF (@UNIDADE_FISICA = 'Paulista')
        BEGIN
            SET @ENDERECO = 'Av. Paulista, 967 - 3º andar'
            SET @HORARIO  = '2ªf à 6ªf das 9h00 as 20h00h - sábados das 8h15 às 12hs'
            SET @CONTATO  = 'Secretaria Acadêmica Paulista via e-mail cursos@vanzolini.org.br ou pelo telefone:(11) 3145-3700'
        END
        ELSE
        BEGIN
            IF (@UNIDADE_FISICA = 'USP')
            BEGIN
                SET @ENDERECO = 'Av. Prof Almeida Prado, 531 - Cidade Universitária'
                SET @HORARIO  = '2ªf à 5ªf das 9h00 às 21h30h, 6ªf das 9h00 às 20h30 - sábado das 8h15 às 12hs'
                SET @CONTATO  = 'Secretaria Acadêmica USP via e-mail secretariausp@vanzolini.org.br ou pelo telefone: (11) 5525-5830'
            END
        END

        -------------------------------------------------------------    
        SELECT
            @INICIO_CURSO = CONVERT(varchar(30), DT_INICIO, 103)
        FROM VW_FCAV_INI_FIM_CURSO_TURMA
        WHERE CONCURSO = @CONCURSO
        ORDER BY DT_INICIO
        
        -------------------------------------------------------------    
        SELECT
            @ENCAMINHA_EMAIL =
            --Producao
				--(CASE
				--	WHEN FACULDADE = 'USP' THEN 'secretariausp@vanzolini.org.br'
				--	WHEN (UNIDADE_RESPONSAVEL = 'ATUAL' OR
				--		UNIDADE_RESPONSAVEL = 'PALES') AND
				--		(FACULDADE = 'Online' OR
				--		FACULDADE = 'Paulista') THEN 'mayla.alencar@vanzolini.org.br; elivana.moura@vanzolini.org.br'
				--	WHEN (UNIDADE_RESPONSAVEL = 'CAPAC' OR
				--		UNIDADE_RESPONSAVEL = 'ESPEC') AND
				--		FACULDADE = 'Paulista' THEN 'adriana.pereira@vanzolini.org.br; elivana.moura@vanzolini.org.br'
				--END)
			--Homologacao
			'suporte_techne@vanzolini.org.br;'    
			
        FROM LY_CONCURSO
        WHERE CONCURSO = @CONCURSO

        -------------------------------------------------------------    
        SET @ASSUNTO = 'SELECIONADO: ' + @NOME + ' - ' + @CONCURSO
        -------------------------------------------------------------    
        SET @TEXTO =
            'Parabéns!
			<br><br>
				Você foi <b>SELECIONADO</b> para o Curso de ' + @CURSO + '.<br>    
			<br>    
				Para confirmar sua Pré-Matrícula você deve:
			<br><br>    
				<b>A - Acessar o Portal de Inscrições, no Link: http://sga.vanzolini.org.br/ProcessoSeletivo até (um dia útil):</b>
			<br>    
			<ul>    
				<li>Fazer o login com o usuário e senha definidos no momento da inscrição;
				<li>Selecionar a opção HISTÓRICO, no topo da página, e completar as informações;     
				<li>Inserir o Responsável Financeiro;    
				<li>Definir a forma de pagamento;    
				<li>Dar o aceite no contrato de prestação de serviços educacionais; e
				<li>Efetuar o pagamento.    
			</ul>
			<br>
				<b>B - Comparecer em até 3 dias após a data de convocação para entrega da documentação:   </b>
			<ul>    
				<li>Diploma da Graduação (cópia autenticada ou original com cópia simples para conferência);
				<li>CPF, RG e comprovante de residência (cópia simples); 
				<li>01 foto 3x4; 
				<li>Contrato de Prestação de Serviços Educacionais - imprimir 02 vias. <br>
				O contrato deve ser assinado e rubricado pelo Responsável Financeiro/Beneficiário e testemunhas).
			</ul>    
			<br><br>
				<b>Obs.: Estão impedidos de assinar como testemunhas, menores de 18 anos, o cônjuge, o companheiro, 
				o ascendente e o descendente em qualquer grau e o colateral, até o terceiro grau.</b>
			<br><br> 
				Local de entrega: ' + @ENDERECO + '    
				Horário: ' + @HORARIO + '    
			<br><br>
				A confirmação da matrícula está condicionada ao cumprimento dos itens A e B. 
			<br><br>    
				Inicio previsto do curso: ' + @INICIO_CURSO + '<BR>    
			<br><br>
				Mais informações: ' + @CONTATO + '    
			<br><br>
			Permanecemos à disposição.
			<br><br>
			Fundação Vanzolini'

        -------------------------------------------------------------    

        EXEC MSDB.dbo.SP_SEND_DBMAIL @PROFILE_NAME =
                                     -- Desenvolvimento/homologação  
                                     FCAV_HOMOLOGACAO,  
                                     -- Produção  
                                     --VANZOLINI_BD,
                                     @RECIPIENTS = @DESTINATARIO,
                                     @BLIND_COPY_RECIPIENTS = @ENCAMINHA_EMAIL,
                                     @SUBJECT = @ASSUNTO,
                                     @BODY = @TEXTO,
                                     @BODY_FORMAT = HTML;




    END