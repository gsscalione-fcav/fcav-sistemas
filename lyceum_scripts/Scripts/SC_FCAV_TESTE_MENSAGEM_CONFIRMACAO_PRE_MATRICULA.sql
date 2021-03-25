
DECLARE @aluno varchar(20), @concurso varchar(20), @candidato varchar(20), @curso varchar(20),    
@turno varchar(20), @curriculo varchar(20), @serie numeric(3), @nome_compl varchar(100),    
@nome_abrev varchar(50), @anoconcl_2g numeric(4), @tipo_ingresso varchar(20), @ano_ingresso numeric(4),    
@sem_ingresso numeric(2), @sit_aluno varchar(15), @cred_educativo varchar(1), @turma_pref varchar(20),    
@grupo varchar(20), @areacnpq varchar(20), @discipoutraserie varchar(1), @ref_aluno_ant varchar(20),    
@sit_aprov varchar(1), @cod_cartao varchar(20), @dt_ingresso datetime, @e_mail_interno varchar(100),    
@num_chamada numeric(10), @curso_ant varchar(100), @unidade_fisica varchar(20), @pessoa numeric(10),    
@outra_faculdade varchar(100), @cidade_2g varchar(50), @pais_2g varchar(50), @creditos numeric(3),    
@obs_aluno_finan varchar(3000), @representante_turma varchar(1), @tipo_aluno varchar(50),    
@faculdade_conveniada varchar(20), @stamp_atualizacao datetime, @unidade_ensino varchar(20),    
@instituicao varchar(20), @classif_aluno varchar(40), @dist_aluno_unidade numeric(15), @nome_social varchar(100)   

 DECLARE @max_alunos numeric    
    DECLARE @alu_inscritos numeric    
    
    DECLARE @nome_curso varchar(300)    
    
    --DECLARE @grupoDoAluno varchar(20)    
    
    DECLARE @endereco varchar(100)    
    DECLARE @destinatario varchar(100)    
    DECLARE @encaminha_email varchar(200)    
    DECLARE @assunto varchar(100)    
    DECLARE @mensagem varchar(8000)    
	DECLARE @manual_aluno varchar(4000)
	DECLARE @perfilaluno varchar(2000)
	DECLARE @email_unidfisica varchar(200)

	DECLARE	@link_manual_aluno varchar(500)
	DECLARE @inicio_turma VARCHAR(10)

	--A-EASFON
	--A-EASF
	--A-EASMON
	--A-EASM
	--A-EASPON
	--A-EASP
SET @aluno = 'A202002792'

SELECT @curso = CS.CURSO, 
	   @nome_compl = AL.NOME_COMPL, 
	   @nome_curso = CS.NOME, 
	   @turma_pref = TURMA_PREF 
	   
FROM 
	LY_ALUNO AL
	INNER JOIN LY_CURSO CS
		ON CS.CURSO = AL.CURSO
WHERE 
	ALUNO = @aluno

  -------------------------------------------------------------      
    --BLOCO DE MENSAGENS      
    IF (@concurso IS NULL)    
    BEGIN    
    
        --MENSAGEM PARA OS ALUNOS DA PALESTRA, CONFIRMAÇÃO OU LISTA DE ESPERA                          
        IF (@unidade_ensino = 'PALES')    
        BEGIN    
            --BUSCA O NÚMERO MÁXIMO DE ALUNOS DA TURMA PARA AS PALESTRAS          
            SELECT TOP 1    
                @max_alunos = ISNULL(MAX(C.VAGAS), T.NUM_ALUNOS)    
            FROM LY_TURMA T    
            INNER JOIN LY_CURSO C    
                ON C.CURSO = T.CURSO    
            INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA VT    
			   ON VT.TURMA = T.TURMA    
						WHERE (T.UNIDADE_RESPONSAVEL = 'PALES')
						AND T.CLASSIFICACAO = 'EmInscricao'    
						AND T.CURRICULO = @curriculo    
						AND VT.TURMA = T.TURMA    
						GROUP BY c.VAGAS,    
								 t.NUM_ALUNOS    
    
            --CONTA O NÚMERO DE ALUNOS PRE_MATRICULADOS EM PALESTRAS           
                
            SELECT    
                @alu_inscritos = ISNULL(COUNT(P.ALUNO), 0)    
            FROM LY_PRE_MATRICULA P    
            INNER JOIN LY_TURMA T    
               ON P.TURMA = T.TURMA    
            INNER JOIN LY_OPCOES_OFERTA OO    
			   ON OO.TURMA = T.TURMA    
				  INNER JOIN LY_OFERTA_CURSO OC    
			   ON OC.OFERTA_DE_CURSO = OO.OFERTA_DE_CURSO    
            WHERE (T.UNIDADE_RESPONSAVEL = 'PALES')  
            AND T.CLASSIFICACAO = 'EmInscricao'    
            AND T.CURRICULO = @curriculo    
            AND P.TURMA = T.TURMA    
    
            ---------------------------------------------------------------------------------------                          
            /* MENSAGEM PARA ALUNOS CONFIRMADOS */    
            ---------------------------------------------------------------------------------------        
            IF (@alu_inscritos <= @max_alunos)    
            BEGIN    
                SET @assunto = 'Inscrição realizada com sucesso'    
    
                SET @mensagem =    
					'Prezado(a) '+ @nome_compl +',       
					 <br><br>      
					 Agradecemos sua inscrição no curso ' + @nome_curso + '.       
					 <br><br>      
					 Aguarde o contato da Secretaria Acadêmica para confirmar a sua vaga.      
					 <br><br>                          
					 Seu código de ALUNO é: ' + @aluno + '      
					 <br><br>                          
					 Qualquer dúvida entre em contato conosco:       
					 <br>       
					 <ul>                         
					  <li> pelo e-mail: atendimento@vanzolini.com.br ; ou                         
					  <li> pelo telefone: (11)3145-3700      
					 </ul>   
					   '    
            END    
            ELSE    
            BEGIN    
                ---------------------------------------------------------------------------------------                          
				/* MENSAGEM PARA ALUNOS EM LISTA DE ESPERA */    
                ---------------------------------------------------------------------------------------        
                IF (@alu_inscritos > @max_alunos)    
                BEGIN    
                    SET @assunto = 'LISTA DE ESPERA'    
    
                    SET @mensagem =    
                    'Prezado(a) '+ @nome_compl +',       
					   <br><br>      
					   Agradecemos sua inscrição para ' + @nome_curso + '.      
					   <br><br>      
					   Sua inscrição está em LISTA DE ESPERA.      
					   <br><br>                           
					   Aguarde o contato da Secretaria Acadêmica para confirmação, pois todas as nossas vagas foram preenchidas.       
					   <br><br>                          
					   Seu código de ALUNO é: ' + @aluno + '      
					   <br><br>                          
					   Qualquer dúvida entre em contato conosco:       
					   <br>       
					   <ul>                         
						<li> pelo e-mail: atendimento@vanzolini.com.br ou                         
						<li> pelo telefone: (11)3145-3700      
					   </ul>      
					  '    
                END    
            END    
		END --FIM DO IF 'PALES'      
        ELSE    
        BEGIN  
             	---------------------------------------------------------------------------------------                          
            /* MENSAGEM PARA ALUNOS DE CURSOS ONLINE */    
            ---------------------------------------------------------------------------------------       
            IF (@unidade_fisica = 'Online')    
            BEGIN    
                SET @assunto = 'Confirmação de Pré-Matrícula'    
    
                SET @mensagem =    
                'Prezado(a) '+ @nome_compl +',
				  <br><br>      
                  
				   Agradecemos sua inscrição no curso ' + @nome_curso + '
				   <br><br>      
                
				   Acesse o link https://sga.vanzolini.org.br/AOnline/.
				   <br><br>      
                
				   Neste ambiente você poderá visualizar seu histórico de cursos,
				   imprimir boletos, notas fiscais, solicitar serviços como declarações e afins.
				   <br><br>
                
				   Seu código de ALUNO é: ' + @aluno + '
				   <br>      
				   Seu login e senha são os mesmos que usou para fazer sua inscrição.
				   <br><br>
                
				   Em breve enviaremos em seu e-mail as instruções para dar início ao seu curso.
				   <br><br>
                
				   E-mail de contato: cursos@vanzolini.com.br.'    
            END --FIM IF CURSOS ONLINE      
            ELSE    
            BEGIN
				---------------------------------------------------------------------------------------                          
				/* MENSAGEM PARA OS CURSOS DE EXAMES AGILE SCRUM*/    
				---------------------------------------------------------------------------------------  
				IF @curso LIKE 'A-EAS%'
				BEGIN
					  
					SET @assunto = 'Confirmação de Pré-Matrícula'    
    
					SET @mensagem =    
					'Olá '+ @nome_compl +', tudo bem?
					  <br><br>
							Ficamos muito felizes com a sua inscrição no ' + @nome_curso + ' Turma ' + @turma_pref + '.
						<br>Seu código de ALUNO é: <b>' + @aluno + '</b>.
						<br>
						<br> 
							<u><b>Próximos passos:</b></u>
						<br>
							1) Efetue o pagamento, conforme opção escolhida. Caso já tenha realizado através de cartão de crédito, desconsidere este passo;
						<br>
							2) Aguarde por e-mail as orientações para realizar/agendar o exame.
					   <br>
					   <br>
						Caso tenha qualquer dúvida, entre em contato conosco através do e-mail secretariapta@vanzolini.com.br, WhatsApp (11) 97197-7187 ou telefone (11) 3145-3700 (opção 2).
					   <br>'    
				END
				ELSE
				BEGIN
					---------------------------------------------------------------------------------------                          
					/* MENSAGEM PARA OS CURSOS DE VENDA DIRETA */    
					---------------------------------------------------------------------------------------    
					SET @assunto = 'Confirmação de Pré-Matrícula'    
    
					SET @mensagem =    
					'Olá '+ @nome_compl +', tudo bem?
					  <br><br>
							Ficamos muito felizes com a sua inscrição no curso ' + @nome_curso + ' Turma ' + @turma_pref + ', com início previsto para ' + @inicio_turma + '.
						<br>Seu código de ALUNO é: <b>' + @aluno + '</b>.
						<br>
						<br> 
							<u><b>Próximos passos:</b></u>
						<br>
							1) Efetue o pagamento, conforme opção escolhida. Caso já tenha realizado através de cartão de crédito, desconsidere este passo;
						<br>
							2) Aguarde o contato da Secretaria para confirmação de oferecimento do curso.
					   <br>
					   <br>
							<u><b>Vantagens:</b></u>
					   <br>
							Agora você faz parte da Comunidade de Alunos Vanzolini e já pode aproveitar o desconto exclusivo de <b> 20% nos cursos rápidos </b> 
							indicados no <a href="https://vanzolini.org.br/tipo/atualizacao/?palavra=&filtro-area=cursos-institucionais&filtro-mes=">site</a> com a etiqueta <b>CAMPANHA - ALUNO VANZOLINI</b>.
					   <br>
					   <br>
							Use o voucher <b>ALUNOVANZOLINI20</b> na etapa de pagamento para obter o desconto.
					   <br><br>
						Desconto não cumulativo.
					   <br><br>
						Caso tenha qualquer dúvida, entre em contato conosco através do e-mail secretariapta@vanzolini.com.br, WhatsApp (11) 97197-7187 ou telefone (11) 3145-3700 (opção 2).
					   <br>' 
				   END
            END    
        END    
    END --FIM DA COMPRA DE CURSO 
	ELSE 
	BEGIN
		---------------------------------------------------------------------------------------                          
        /* MENSAGEM PARA OS CURSOS PROCESSOS SELETIVOS */    
        ---------------------------------------------------------------------------------------    
        SET @assunto = 'Confirmação de Pré-Matrícula'    
    
        SET @mensagem =    
			'Olá, '+ @nome_compl + '!
			<br>
			<br>
			Tudo bem?
			<br>
			<br>
			Informamos que a sua Pré-Matrícula na turma '+ @turma_pref +' no curso de '+ @nome_curso +' foi concluída com sucesso.
			<br>
			<br>
			Seu código de ALUNO é: '+ @aluno +'.
			<br>
			<br>
			<u><b>Próximas etapas:</b></u>
			<br>
			<br>
			<b>1)</b> Efetue o pagamento, conforme opção escolhida;
			<br>
			<br>
			<b>2)</b> Envie por e-mail todos os documentos listados abaixo:
			<ul>
				<li>Diploma (frente e verso) ou Declaração de Conclusão (com data da colação de grau). Digitalizar o documento original. (*)</li>
					Obs.: Nos cursos presenciais, é necessário apresentar a via original no primeiro dia de aula para validação.
				<li>CPF, RG e Comprovante de Residência;</li>
				<li>01 foto 3x4 (pode ser selfie);</li>
				<li>Contrato de Prestação de Serviços Educacionais (o Contrato deve ser entregue no primeiro dia de aula em 2 vias assinadas e rubricadas pelo Responsável Financeiro, Beneficiário e Testemunhas em arquivo único, contendo todas as páginas. (*)
				<br>Obs.: a) Estão impedidos de assinar como testemunhas menores de 18 anos; b) Nos cursos EaD fazer o envio de todas as páginas assinadas e rubricadas somente por e-mail em arquivo digitalizado.</li>
			</ul>
			(*) Cursos de Difusão estão isentos da entrega.
			<br>
			<br>
			<b>3)</b> Aguarde a confirmação da turma via e-mail pela Secretaria Acadêmica.
			<br>
			<br>
			'+ @manual_aluno +'
			<br>
			<br>
			<b>Secretaria Acadêmica PTA:</b> Via e-mail secretariapta@vanzolini.com.br ou pelo telefone: (11) 3145-3700.
			<br>
			<br>
			<b>Secretaria Acadêmica USP:</b> Via e-mail secretariausp@vanzolini.com.br ou pelo telefone: (11) 5525-5837.
			<br>
			<br>
			<b>Horário de Atendimento:</b> Segundas a Sextas-feiras, das 08h00 às 20h30 e aos Sábados, das 08h00 às 12h00
			<br>
			<br>
			<b>Local de realização do curso:</b>  '+ @endereco +'
			<br>
			<br>
			<b>Secretaria Acadêmica</b>'
	END

SELECT @assunto as ASSUNTO, @mensagem as MENSAGEM