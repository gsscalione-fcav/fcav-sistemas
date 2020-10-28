ALTER PROCEDURE a_APoI_Ly_pre_matricula      
  @erro VARCHAR(1024) OUTPUT,      
  @aluno VARCHAR(20), @disciplina VARCHAR(20), @ano NUMERIC(4), @semestre NUMERIC(2),       
  @turma VARCHAR(20), @subturma1 VARCHAR(20), @subturma2 VARCHAR(20), @serie_ideal NUMERIC(3),       
  @mens_erro VARCHAR(2000), @lanc_deb NUMERIC(10), @confirmada VARCHAR(1), @dispensada VARCHAR(1),       
  @manual VARCHAR(1), @dt_ultalt DATETIME, @cobranca_sep VARCHAR(1), @serie_calculo NUMERIC(3),       
  @dt_insercao DATETIME, @dt_confirmacao DATETIME, @sit_detalhe VARCHAR(50), @grupo_eletiva VARCHAR(20),       
  @num_chamada NUMERIC(10), @confirmacao_lider VARCHAR(1),     
  @Opcao NUMERIC(3), @DISCIPLINA_SUBST VARCHAR(20), @TURMA_SUBST VARCHAR(20), @ALOCADO VARCHAR(1),    
  @cumpriu_grupo VARCHAR(1)      
AS      
   -- [IN�CIO] Customiza��o - N�o escreva c�digo antes desta linha     
       
 DECLARE   
  @v_TURMA T_CODIGO,    
  @v_CURSO T_CODIGO,    
  @V_UNID_RESP T_CODIGO,  
  @max_alunos NUMERIC,   
  @alu_inscritos NUMERIC,
   
  @oferta T_CODIGO,
  @destinatario varchar(100)    ,
  @encaminha_email varchar(200) ,   
  @assunto varchar(100)    ,
  @mensagem varchar(8000)    

 SET @encaminha_email = NULL

 SET @alu_inscritos = 0    
    
 SET @max_alunos = 0    
  
  
 -- BUSCA CURSO    
 SELECT    
  @v_CURSO = CURSO    
 FROM   
  LY_ALUNO    
 WHERE   
  ALUNO = @aluno    
  
 --BUSCA A UNIDADE RESPONS�VEL    
 SELECT   
  @V_UNID_RESP = FACULDADE   
 FROM   
  LY_CURSO   
    WHERE   
  CURSO = @v_CURSO  
   
  
 --BUSCA O N�MERO M�XIMO DE ALUNOS DA TURMA PARA AS PALESTRAS                  
 SELECT              
  @max_alunos = MAX(C.VAGAS)        
 FROM   
  LY_TURMA T        
 INNER JOIN LY_CURSO C ON C.CURSO = T.CURSO                 
 WHERE                  
   (T.UNIDADE_RESPONSAVEL = 'PALES')
 AND T.TURMA = @turma  
               
 --CONTA O N�MERO DE ALUNOS PRE_MATRICULADOS EM PALESTRAS                  
 SELECT               
  @alu_inscritos = ISNULL(COUNT(P.ALUNO),0)  
 FROM                  
  LY_PRE_MATRICULA P        
 INNER JOIN LY_TURMA T ON P.TURMA = T.TURMA                  
 WHERE                  
   (T.UNIDADE_RESPONSAVEL = 'PALES') 
 AND P.TURMA = @turma  
  
-------------------------------------------------------------
	-- CONTROLE DE INSCRICAO PARA OS CURSOS A-GPMP / A-LGPD / A-TB
	      IF (@v_CURSO = 'A-GPMP'or @v_CURSO = 'A-LGPD' or @v_CURSO = 'A-TB')    
			BEGIN    
				--BUSCA A OFERTA
				SELECT
					@oferta = oc.OFERTA_DE_CURSO
				FROM LY_TURMA TU
					INNER JOIN LY_OPCOES_OFERTA OO
						ON OO.TURMA = TU.TURMA
					INNER JOIN LY_OFERTA_CURSO OC
						ON OC.CURSO  = TU.CURSO
						AND OC.OFERTA_DE_CURSO = OO.OFERTA_DE_CURSO
				WHERE 
					TU.CURSO = @v_CURSO
					and tu.TURMA = @turma

				--BUSCA O N�MERO M�XIMO DE ALUNOS DA TURMA EM INSCRICAO         
				SELECT
					@max_alunos = ISNULL(MAX(TU.NUM_ALUNOS), 25)
				FROM LY_TURMA TU
				WHERE 
					TU.CURSO = @v_CURSO
					and tu.TURMA = @turma
				GROUP BY TU.NUM_ALUNOS

			    --CONTA O N�MERO DE ALUNOS ATIVOS DO CURSO
    			SELECT @alu_inscritos = ISNULL(COUNT(MP.ALUNO), 0)
				FROM VW_MATRICULA_E_PRE_MATRICULA MP   
				WHERE mp.TURMA = @turma
					AND MP.SIT_MATRICULA NOT LIKE 'Cancelado'
				GROUP BY MP.TURMA


				IF (@alu_inscritos >= @max_alunos)
				BEGIN
				
					--Encerra as inscri��es ao atingir o limite m�ximo de alunos
					update LY_OFERTA_CURSO
					set 
						DTFIM = GETDATE() - 1
					 FROM LY_OFERTA_CURSO OC
						INNER JOIN LY_OPCOES_OFERTA OO
							ON OO.OFERTA_DE_CURSO = OC.OFERTA_DE_CURSO
					WHERE OC.OFERTA_DE_CURSO = @oferta
					AND  OO.TURMA = @turma
					
						
					--Monta a mensagem
					SET @assunto = 'N�mero de inscritos para a turma - '+ @turma +' atingiu o limite!'    
    
					SET @mensagem =    
						 'Informativo:       
							<br><br>      
							O n�mero de m�ximo de inscritos da turma - ' + @turma + ' foi atingido.
							<br><br>
							Qtde de Inscritos: '+ CAST(@alu_inscritos AS VARCHAR) +'

							<br><br>      
							O per�odo de inscri��es dessa turma, com o n�mero de oferta: <b>'+ CAST( @oferta AS VARCHAR) +'</b>, foi encerrada automaticamente no Lyceum.
							<br><br>
							Por favor abrir um chamado para suporteti@vanzolini.com.br para encerrar as inscri��es tamb�m no site da Vanzolini.
							<br>
							Qualquer d�vida estamos a disposi��o.
							<br>          
						'
				END   
				
				---------------------------------------------------------------------------------------       
				--ENCAMINHAMENTO DE C�PIA PARA AS SECRETARIAS      
				-- Produ��o 
				SET @encaminha_email = 'secretariapta@vanzolini.com.br'
				 
				
				-- Homologa��o      
				-- SET @encaminha_email = 'gabriel.scalione@vanzolini.com.br'      
				-- SET @assunto = 'Homologa��o - ' + @assunto     
				
				EXEC MSDB.dbo.SP_SEND_DBMAIL @PROFILE_NAME =    
                                -- Desenvolvimento/homologa��o      
                                --FCAV_HOMOLOGACAO,      
                                -- Produ��o      
								VANZOLINI_BD,    
                                @recipients = @encaminha_email,  
								@copy_recipients = @encaminha_email,
								@reply_to = @encaminha_email,
                                @blind_copy_recipients = 'gabriel.scalione@vanzolini.com.br',
                                @subject = @assunto,    
                                @body = @mensagem,    
                                @body_format = 'HTML'     


			END -- FIM DO CONTROLE DE INSCRICAO
-------------------------------------
  
 --SE O N�MERO DE INSCRITOS FOR MAIOR QUE O NUMERO DE VAGAS, N�O ALOCA O ALUNO.  
 IF (  
   @alu_inscritos > @max_alunos   
  AND (@V_UNID_RESP = 'PALES') 
    )  
    BEGIN    
	  UPDATE LY_PRE_MATRICULA   
	  SET   
	   ALOCADO = 'N'   
	  WHERE   
	   ALUNO = @aluno   
    END    
  
RETURN      
  -- [FIM] Customiza��o - N�o escreva c�digo ap�s esta linha 