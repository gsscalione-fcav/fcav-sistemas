--* ******************************************************************************
--*            
--*     *** TRIGGER TR_FCAV_CONVOC_MANUAL  ***            
--*            
--* FINALIDADE:
--* - E-mail para candidatos aprovados no Processo Seletivo
--*            
/*********************************************************************************        
ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO         
       
	Para o ambiente de PRODUÇÃO, não esquecer de alterar as variáveis:         
	 @encaminha_email comentar a parte de homologação,        
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
		/* MENSAGEM PADRÃO PARA OS ALUNOS INGRESSOS DE PROCESSO SELETIVO*/        
		---------------------------------------------------------------------------------------          
		SET @assunto = 'SELECIONADO: ' + @nome + ' - ' + @concurso      
		-------------------------------------------------------------   
		SET @texto = 
				'Olá, ' + @nome + '!
					<br><br>
					Tudo bem?
					<br><br>
					O seu perfil foi APROVADO para o Curso de '+ @curso +', com início previsto para '+ @inicio_curso +' e será um prazer ter você conosco.
					<br><br>
					Agora só falta confirmar a sua Pré-Matrícula seguindo as instruções abaixo:
					<br><br>
    
					<b><u>1ª Etapa – Aceite do contrato e pagamento </u></b> 
					<br><br>
					Acesse o Portal de Inscrições no Link: <a href="https://sga.vanzolini.org.br/ProcessoSeletivo" target="_blank" > https://sga.vanzolini.org.br/ProcessoSeletivo </a>
					<ul>
						<li>Faça o login com o usuário e senha definidos no momento da inscrição;</li> 
						<li>Selecione a opção HISTÓRICO, no topo da página, e complete as informações;</li> 
						<li>Insira o Responsável Financeiro;</li> 
						<li>Defina a forma de pagamento;</li> 
						<li>Dê o aceite no contrato de prestação de serviços educacionais;</li> 
						<li>Efetue o pagamento.</li> 
					</ul>

					<b><u>2ª Etapa – Documentação</u></b> 
					<br><br>

					<b>Cursos presenciais e EaD</b> 
					<br>
					Envie por e-mail todos os documentos listados abaixo:  
					<ul>
						<li>Diploma (frente e verso) ou Declaração de Conclusão (com data da colação de grau). Digitalizar o documento original. (*)</li>
						Obs.: Nos cursos presenciais, é necessário apresentar a via original no primeiro dia de aula para validação.
						<li>CPF, RG e Comprovante de Residência (cópia simples);</li>
						<li>01 foto 3x4 (pode ser selfie);</li> 
						<li>Contrato de Prestação de Serviços Educacionais (o Contrato deve ser entregue em 2 vias assinadas e rubricadas pelo Responsável Financeiro, Beneficiário e Testemunhas em arquivo único, contendo todas as páginas. (*)</li>
						Obs.: Estão impedidos de assinar como testemunhas menores de 18 anos.
					</ul>
        
        
					(*)  Cursos de Difusão estão isentos da entrega.
					<br><br>
					<b>Para onde enviar os documentos?</b>
					<br><br>
					<b>Unidade Paulista</b> - secretariapta@vanzolini.com.br   
					<br>
					<b>Unidade USP</b> - secretariausp@vanzolini.com.br  
					<br><br>

					<b><u>3ª Etapa – Aguardar confirmação de oferecimento da turma</u></b> 
					<ul>
							<li>A confirmação será formalizada por e-mail.</li> 
					</ul>
					<b>Informações Adicionais:</b> 
					<br>
					A efetivação da matrícula está condicionada ao cumprimento da 1ª e 2ª etapa.
					<br>
					Recomendamos concluir o processo em até 48 horas para garantir a sua vaga no curso.
					<br><br>
					<b>Ainda está com dúvida?</b> 
					<br><br>
					Entre em contato conosco: 
					<br><br>
					<b>Secretaria Acadêmica PTA</b>: Via e-mail secretariapta@vanzolini.com.br ou pelo telefone: (11) 3145-3700.  
        
					<b>Secretaria Acadêmica USP</b>: Via e-mail secretariausp@vanzolini.com.br ou pelo telefone: (11) 5525-5837.
					<br><br>
					Conte com a gente para o que precisar!' 

		-------------------------------------------------------------      
		--ENCAMINHAMENTO DE CÓPIA PARA AS SECRETARIAS        
		--Produção        
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
      
		-- Homologação        
			--SET @encaminha_email = 'suporte_techne@vanzolini.com.br'        
			--SET @assunto = 'Homologação - ' + @assunto 
			--SET @destinatario = 'suporte_techne@vanzolini.com.br'        

		-------------------------------------------------------------            
		EXEC MSDB.dbo.SP_SEND_DBMAIL @profile_name =      
										-- Desenvolvimento/homologação         
										--FCAV_HOMOLOGACAO,          
										-- Produção          
										VANZOLINI_BD,      
										@recipients = @destinatario,
										@reply_to = @encaminha_email,
										@copy_recipients = @encaminha_email,      
										@blind_copy_recipients = 'suporte_techne@vanzolini.com.br',      
										@subject = @assunto,      
										@body = @texto,      
										@body_format = HTML;      
      
    END