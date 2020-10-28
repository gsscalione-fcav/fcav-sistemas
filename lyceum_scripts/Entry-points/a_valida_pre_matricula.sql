--ALTERADA POR: NAT�LIA ORSETTI (TECHNE)  
--DATA: 07/11/2013  
--OBS: LIMITAR N�MERO DE DISCIPLINAS A SEREM INSERIDAS NA PR�-MATR�CULA  
  
--DATA: 21/11/2013  
--OBS: REALIZAR C�LCULO/REC�LCULO NA D�VIDA DO ALUNO QUANDO PR�-MATR�CULA REALIZADA PELO PORTAL 
-- 

--Data: 10/05/2017
--Altera��o: 	Corre��o da entry-point. Retirado valida��o de disponibilidade de pr�-matr�cula das disciplinas do CEAI, 
--				houve altera��o no processo definida pelo atual coordenador e estava impedindo a inclus�o de disciplinas 
--				para os alunos do curso CEAI.
--Autor: Gabriel S. Scalione
    
ALTER PROCEDURE a_valida_pre_matricula    
  @P_ALUNO              AS T_CODIGO,         
  @P_DISCIPLINA         AS T_CODIGO,         
  @P_TURMA              AS T_CODIGO,         
  @P_ANO                AS T_ANO,         
  @P_SEMESTRE           AS T_SEMESTRE2,         
  @P_VALIDO             AS T_SIMNAO OUTPUT,        
  @P_MSG                AS VARCHAR(1024) OUTPUT,      
  @P_CONTEXTO           AS VARCHAR(100),         
  @P_VERMAXREPROVACAO   AS T_SIMNAO,      
  @P_VERVAGA            AS T_SIMNAO,       
  @P_VERGRADE           AS T_SIMNAO,      
  @P_VERHORARIO         AS T_SIMNAO,      
  @P_VERPREREQ          AS T_SIMNAO,      
  @P_VERLIMITESCREDITOS AS T_SIMNAO,      
  @P_VERDISCIPADAP      AS T_SIMNAO,      
  @P_VERPLANOESTUDO     AS T_SIMNAO,      
  @P_CREDOBRIGFALTA     AS T_DECIMAL_MEDIO,      
  @P_CREDGRUPOFALTA     AS T_DECIMAL_MEDIO,      
  @p_Pos_Fechamento AS VARCHAR(1),      
  @p_subturma1 AS T_CODIGO,       
  @p_subturma2 AS T_CODIGO,       
  @p_serie_ideal AS T_NUMERO_PEQUENO,       
  @p_confirmada AS T_SIMNAO,       
  @p_dispensada AS T_SIMNAO,       
  @p_manual AS T_SIMNAO,       
  @p_serie_calculo AS T_NUMERO_PEQUENO,       
  @p_grupo_eletiva   AS T_CODIGO,       
  @p_confirmacao_lider AS T_SIMNAO,       
  @p_Opcao AS T_NUMERO_PEQUENO,       
  @p_DISCIPLINA_SUBST AS T_CODIGO,       
  @p_TURMA_SUBST AS T_CODIGO,       
  @p_ALOCADO AS T_SIMNAO    
AS    
    -- Chamar procedure que executa a valida��o das informa��es     
    -- para efetivar a pr�-matricula, conforme definido pela Institui��o.    
    select @P_VALIDO = 'S'      
    select @P_MSG = ''  
    
    -----------------------------------------------------------------------
    --Inicio da customizacao

	IF EXISTS( SELECT 1 FROM 
				LY_ALUNO AL
				INNER JOIN LY_PESSOA PE
					ON PE.PESSOA = AL.PESSOA
				INNER JOIN HD_MUNICIPIO MU 
					ON MU.MUNICIPIO = PE.END_MUNICIPIO
				WHERE	
					ENDERECO LIKE 'não informado'
					AND AL.ALUNO = @P_ALUNO	)
	BEGIN 
		SET @P_VALIDO = 'N'
		SET @P_MSG = 'Identificamos que o endere�o informado n�o � um endere�o v�lido, por favor atualizar seu endere�o.'
	END

    --Fim da customizacao
    -----------------------------------------------------------------------   
RETURN