--* ******************************************************************************
--*            
--*     *** TRIGGER TR_FCAV_CONVOC_MANUAL  ***            
--*            
--* FINALIDADE:
--* - E-mail para candidatos aprovados no Processo Seletivo
--*            
/*********************************************************************************        
ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO         
       
	Para o ambiente de PRODU��O, n�o esquecer de alterar as vari�veis:         
	 @encaminha_email comentar a parte de homologa��o,        
	 @PROFILE_NAME alterar para VANZOLINI_BD        
        
ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO         
**********************************************************************************/      
    
ALTER TRIGGER TR_FCAV_CONVOC_MANUAL      
ON LY_CONVOCADOS_VEST      
AFTER INSERT      
      
AS      
      
    DECLARE @candidato varchar(20)      
    DECLARE @nome varchar(100)      
    DECLARE @concurso varchar(20)      
    DECLARE @curso varchar(100)      
    DECLARE @assunto varchar(100)      
    DECLARE @texto varchar(8000)      
    DECLARE @destinatario varchar(100)      
    DECLARE @inicio_curso varchar(30)      
    DECLARE @encaminha_email varchar(200)      
    DECLARE @unidade_fisica varchar(20)      
    DECLARE @unidade_ensino varchar(20)
  
      
    SET @candidato = NULL      
    SET @nome = NULL      
    SET @concurso = NULL      
    SET @curso = NULL      
    SET @assunto = NULL      
    SET @texto = NULL      
    SET @destinatario = NULL      
    SET @inicio_curso = NULL      
    SET @encaminha_email = NULL      
    SET @unidade_ensino = NULL
      
    BEGIN      
      
        SELECT      
            @candidato = CANDIDATO,
            @concurso = CONCURSO
        FROM INSERTED      
      
      -------------------------------------------------------------
      -- DADOS DO CANDIDATO
	    SELECT      
            @nome = NOME_COMPL,
            @destinatario = LOWER(LTRIM(RTRIM(c.E_MAIL)))      
        FROM LY_CANDIDATO C      
        WHERE C.CANDIDATO = @candidato      
        AND C.CONCURSO = @concurso      
      
        -------------------------------------------------------------   
		-- DADOS DO CURSO
        SELECT      
            @curso = CS.NOME,      
            @unidade_fisica = OC.UNIDADE_FISICA,      
            @unidade_ensino = CS.FACULDADE              
		FROM LY_OFERTA_CURSO OC      
        INNER JOIN LY_CURSO CS      
            ON (OC.CURSO = CS.CURSO)      
        WHERE OC.CONCURSO = @concurso      
          
		-------------------------------------------------------------            
		SELECT      
			@inicio_curso = CONVERT(varchar(30), DT_INICIO, 103)      
		FROM VW_FCAV_INI_FIM_CURSO_TURMA      
		WHERE CONCURSO = @concurso      
		ORDER BY DT_INICIO      
      
		---------------------------------------------------------------------------------------                              
		/* MENSAGEM PADR�O PARA OS ALUNOS INGRESSOS DE PROCESSO SELETIVO*/        
		---------------------------------------------------------------------------------------          
		SET @assunto = 'SELECIONADO: ' + @nome + ' - ' + @concurso      
		-------------------------------------------------------------   
		SET @texto = 
				'Ol�, ' + @nome + '!
					<br><br>
					Tudo bem?
					<br><br>
					O seu perfil foi APROVADO para o Curso de '+ @curso +', com in�cio previsto para '+ @inicio_curso +' e ser� um prazer ter voc� conosco.
					<br><br>
					Agora s� falta confirmar a sua Pr�-Matr�cula seguindo as instru��es abaixo:
					<br><br>
    
					<b><u>1� Etapa � Aceite do contrato e pagamento </u></b> 
					<br><br>
					Acesse o Portal de Inscri��es no Link: <a href="https://sga.vanzolini.org.br/ProcessoSeletivo" target="_blank" > https://sga.vanzolini.org.br/ProcessoSeletivo </a>
					<ul>
						<li>Fa�a o login com o usu�rio e senha definidos no momento da inscri��o;</li> 
						<li>Selecione a op��o HIST�RICO, no topo da p�gina, e complete as informa��es;</li> 
						<li>Insira o Respons�vel Financeiro;</li> 
						<li>Defina a forma de pagamento;</li> 
						<li>D� o aceite no contrato de presta��o de servi�os educacionais;</li> 
						<li>Efetue o pagamento.</li> 
					</ul>

					<b><u>2� Etapa � Documenta��o</u></b> 
					<br><br>

					<b>Cursos presenciais e EaD</b> 
					<br>
					Envie por e-mail todos os documentos listados abaixo:  
					<ul>
						<li>Diploma (frente e verso) ou Declara��o de Conclus�o (com data da cola��o de grau). Digitalizar o documento original. (*)</li>
						Obs.: Nos cursos presenciais, � necess�rio apresentar a via original no primeiro dia de aula para valida��o.
						<li>CPF, RG e Comprovante de Resid�ncia (c�pia simples);</li>
						<li>01 foto 3x4 (pode ser selfie);</li> 
						<li>Contrato de Presta��o de Servi�os Educacionais (o Contrato deve ser entregue em 2 vias assinadas e rubricadas pelo Respons�vel Financeiro, Benefici�rio e Testemunhas em arquivo �nico, contendo todas as p�ginas. (*)</li>
						Obs.: Est�o impedidos de assinar como testemunhas menores de 18 anos.
					</ul>
        
        
					(*)  Cursos de Difus�o est�o isentos da entrega.
					<br><br>
					<b>Para onde enviar os documentos?</b>
					<br><br>
					<b>Unidade Paulista</b> - secretariapta@vanzolini.com.br   
					<br>
					<b>Unidade USP</b> - secretariausp@vanzolini.com.br  
					<br><br>

					<b><u>3� Etapa � Aguardar confirma��o de oferecimento da turma</u></b> 
					<ul>
							<li>A confirma��o ser� formalizada por e-mail.</li> 
					</ul>
					<b>Informa��es Adicionais:</b> 
					<br>
					A efetiva��o da matr�cula est� condicionada ao cumprimento da 1� e 2� etapa.
					<br>
					Recomendamos concluir o processo em at� 48 horas para garantir a sua vaga no curso.
					<br><br>
					<b>Ainda est� com d�vida?</b> 
					<br><br>
					Entre em contato conosco: 
					<br><br>
					<b>Secretaria Acad�mica PTA</b>: Via e-mail secretariapta@vanzolini.com.br ou pelo telefone: (11) 3145-3700.  
        
					<b>Secretaria Acad�mica USP</b>: Via e-mail secretariausp@vanzolini.com.br ou pelo telefone: (11) 5525-5837.
					<br><br>
					Conte com a gente para o que precisar!' 

		-------------------------------------------------------------      
		--ENCAMINHAMENTO DE C�PIA PARA AS SECRETARIAS        
		--Produ��o        
		IF (@unidade_fisica = 'USP' or @unidade_fisica = 'Online USP'or @unidade_fisica = 'Online') BEGIN      
				
				SET @encaminha_email = 'secretariausp@vanzolini.com.br; '      
		END      
		ELSE BEGIN  
			IF (@unidade_fisica = 'Paulista') BEGIN
				SET @encaminha_email = 'secretariapta@vanzolini.com.br'  
			END  
			ELSE BEGIN
				SET @encaminha_email = 'secretariapta@vanzolini.com.br; secretariausp@vanzolini.com.br'  
			END
		END     
      
		-- Homologa��o        
			--SET @encaminha_email = 'suporte_techne@vanzolini.com.br'        
			--SET @assunto = 'Homologa��o - ' + @assunto 
			--SET @destinatario = 'suporte_techne@vanzolini.com.br'        

		-------------------------------------------------------------            
		EXEC MSDB.dbo.SP_SEND_DBMAIL @profile_name =      
										-- Desenvolvimento/homologa��o         
										--FCAV_HOMOLOGACAO,          
										-- Produ��o          
										VANZOLINI_BD,      
										@recipients = @destinatario,
										@reply_to = @encaminha_email,
										@copy_recipients = @encaminha_email,      
										@blind_copy_recipients = 'suporte_techne@vanzolini.com.br',      
										@subject = @assunto,      
										@body = @texto,      
										@body_format = HTML;      
      
    END