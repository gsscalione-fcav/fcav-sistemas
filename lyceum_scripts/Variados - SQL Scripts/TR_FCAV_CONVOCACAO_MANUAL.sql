--* ***************************************************************    
--*    
--*     *** TRIGGER TR_FCAV_CONVOC_MANUAL  ***    
--*    
--* DESCRICAO:    
--* - Aviso por email para candidatos aprovados no Processo Seletivo    
--*    
--* USO:    
--* - Ap�s a Secretaria fazer a Convoca��o Manual de algum candidato, ele    
--* receber� um email com os pr�ximos passos para terminar sua matr�cula    

/*********************************************************************************
ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO 

Para o ambiente de PRODU��O, n�o esquecer de alterar as vari�veis: 
	@encaminha_email comentar a parte de homologa��o,
	@PROFILE_NAME alterar para VANZOLINI_BD

ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO 
**********************************************************************************/

--*    
--* ALTERA��ES:    
--*      19/01/2017: > Retirado as informa��es sobre o CCMI, pois n�o ter� mais esse curso. Gabriel    
--*      > Alterado o filtro para os cursos de Atualiza��o e Palestra. Agora o filtro �    
--*      por unidade respons�vel e n�o mais por curso. Gabriel    
--*
--*		 11/05/2017: Mensagem atualizada conforme solicita��o da Secretaria. Gabriel
--*    
--* Autor: Jo�o Paulo    
--* Data de cria��o: 2014-08-07    
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
            SET @ENDERECO = 'Av. Paulista, 967 - 3� andar'
            SET @HORARIO  = '2�f � 6�f das 9h00 as 20h00h - s�bados das 8h15 �s 12hs'
            SET @CONTATO  = 'Secretaria Acad�mica Paulista via e-mail cursos@vanzolini.org.br ou pelo telefone:(11) 3145-3700'
        END
        ELSE
        BEGIN
            IF (@UNIDADE_FISICA = 'USP')
            BEGIN
                SET @ENDERECO = 'Av. Prof Almeida Prado, 531 - Cidade Universit�ria'
                SET @HORARIO  = '2�f � 5�f das 9h00 �s 21h30h, 6�f das 9h00 �s 20h30 - s�bado das 8h15 �s 12hs'
                SET @CONTATO  = 'Secretaria Acad�mica USP via e-mail secretariausp@vanzolini.org.br ou pelo telefone: (11) 5525-5830'
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
            'Parab�ns!
			<br><br>
				Voc� foi <b>SELECIONADO</b> para o Curso de ' + @CURSO + '.<br>    
			<br>    
				Para confirmar sua Pr�-Matr�cula voc� deve:
			<br><br>    
				<b>A - Acessar o Portal de Inscri��es, no Link: http://sga.vanzolini.org.br/ProcessoSeletivo at� (um dia �til):</b>
			<br>    
			<ul>    
				<li>Fazer o login com o usu�rio e senha definidos no momento da inscri��o;
				<li>Selecionar a op��o HIST�RICO, no topo da p�gina, e completar as informa��es;     
				<li>Inserir o Respons�vel Financeiro;    
				<li>Definir a forma de pagamento;    
				<li>Dar o aceite no contrato de presta��o de servi�os educacionais; e
				<li>Efetuar o pagamento.    
			</ul>
			<br>
				<b>B - Comparecer em at� 3 dias ap�s a data de convoca��o para entrega da documenta��o:   </b>
			<ul>    
				<li>Diploma da Gradua��o (c�pia autenticada ou original com c�pia simples para confer�ncia);
				<li>CPF, RG e comprovante de resid�ncia (c�pia simples); 
				<li>01 foto 3x4; 
				<li>Contrato de Presta��o de Servi�os Educacionais - imprimir 02 vias. <br>
				O contrato deve ser assinado e rubricado pelo Respons�vel Financeiro/Benefici�rio e testemunhas).
			</ul>    
			<br><br>
				<b>Obs.: Est�o impedidos de assinar como testemunhas, menores de 18 anos, o c�njuge, o companheiro, 
				o ascendente e o descendente em qualquer grau e o colateral, at� o terceiro grau.</b>
			<br><br> 
				Local de entrega: ' + @ENDERECO + '    
				Hor�rio: ' + @HORARIO + '    
			<br><br>
				A confirma��o da matr�cula est� condicionada ao cumprimento dos itens A e B. 
			<br><br>    
				Inicio previsto do curso: ' + @INICIO_CURSO + '<BR>    
			<br><br>
				Mais informa��es: ' + @CONTATO + '    
			<br><br>
			Permanecemos � disposi��o.
			<br><br>
			Funda��o Vanzolini'

        -------------------------------------------------------------    

        EXEC MSDB.dbo.SP_SEND_DBMAIL @PROFILE_NAME =
                                     -- Desenvolvimento/homologa��o  
                                     FCAV_HOMOLOGACAO,  
                                     -- Produ��o  
                                     --VANZOLINI_BD,
                                     @RECIPIENTS = @DESTINATARIO,
                                     @BLIND_COPY_RECIPIENTS = @ENCAMINHA_EMAIL,
                                     @SUBJECT = @ASSUNTO,
                                     @BODY = @TEXTO,
                                     @BODY_FORMAT = HTML;




    END