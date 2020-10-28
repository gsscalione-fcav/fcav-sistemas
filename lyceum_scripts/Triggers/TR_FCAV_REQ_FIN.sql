  
--* ***************************************************************        
--*        
--*     *** TRIGGER TR_FCAV_REQ_FIN  ***        
--*        
--* DESCRICAO:        
--* - Aviso por email para Secretaria ou Financeiro quando houver alguma solicita��o   
--*   do aluno     
--*     
/**********************************************************************************/  
--*        
--* ALTERA��ES:        
--*        
--* Autor: Gabriel Serrano Scalione  
--* Data de cria��o: 01/09/2017       
--*        
--* ***************************************************************    
  
  
ALTER TRIGGER [dbo].[TR_FCAV_REQ_FIN]  
ON [dbo].[LY_ANDAMENTO]  
AFTER INSERT  
  
AS  
  
    IF EXISTS (SELECT  
            1  
        FROM INSERTED  
        WHERE STATUS != 'Atendido'  
        AND PROXIMO_SETOR IS NULL)  
    BEGIN  
  
        DECLARE @ALUNO varchar(20)  
        DECLARE @TURMA varchar(20)  
        DECLARE @ASSUNTO varchar(100)  
        DECLARE @SOLICITACAO varchar(3)  
        DECLARE @TEXTO varchar(1000)  
        DECLARE @DESTINATARIO varchar(100)  
        DECLARE @CONTATO VARCHAR(100)  
        DECLARE @RESPONDER_PARA varchar(100)  
        DECLARE @PREZADO varchar(10)  
        DECLARE @NOME varchar(200)  
        DECLARE @TELEFONE varchar(100)  
        DECLARE @UNIDADE_FISICA varchar(20)  
  
        SET @ALUNO = NULL  
        SET @TURMA = NULL  
        SET @ASSUNTO = NULL  
        SET @SOLICITACAO = NULL  
        SET @TEXTO = NULL  
        SET @DESTINATARIO = NULL  
        SET @CONTATO = NULL  
        SET @RESPONDER_PARA = NULL  
        SET @PREZADO = NULL  
        SET @NOME = NULL  
        SET @UNIDADE_FISICA = NULL  
  
        SELECT  
            @SOLICITACAO = SOLICITACAO  
        FROM INSERTED  
  
  
        --***************************************    
        SELECT  
            @ALUNO = SS.ALUNO  
        FROM LY_ANDAMENTO A  
        INNER JOIN LY_SOLICITACAO_SERV SS  
            ON (A.SOLICITACAO = SS.SOLICITACAO)  
  --***************************************    
        SELECT  
            @TURMA = TURMA  
        FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA  
        WHERE ALUNO = @ALUNO  
  
        --***************************************    
        SELECT DISTINCT  
            @UNIDADE_FISICA = FACULDADE  
        FROM LY_TURMA  
        WHERE TURMA = @TURMA  
          
        --***************************************   
        SELECT  
            @DESTINATARIO = P.E_MAIL  
        FROM LY_PESSOA P  
        INNER JOIN LY_ALUNO A  
            ON (P.PESSOA = A.PESSOA)  
        WHERE A.ALUNO = @ALUNO  
  
        --***************************************    
        SELECT  
            @PREZADO =  
                        CASE  
                            WHEN SEXO = 'M' THEN 'Prezado'  
                            WHEN SEXO = 'F' THEN 'Prezada'  
                        END  
        FROM LY_PESSOA P  
        INNER JOIN LY_ALUNO A  
            ON (P.PESSOA = A.PESSOA)  
        WHERE A.ALUNO = @ALUNO  
  
        --***************************************    
        SELECT  
            @NOME = A.NOME_COMPL  
        FROM LY_ALUNO A  
        WHERE A.ALUNO = @ALUNO  
  
        --***************************************    
        SELECT  
            @ASSUNTO = 'Solicita�ao de Servi�o - Funda��o Vanzolini'  
  
  
        --***************************************    
        IF (@UNIDADE_FISICA = 'USP')  
        BEGIN  
            SET @CONTATO = 'Unidade USP <br> Telefone: (11) 5525-5830'  
            SET @RESPONDER_PARA = 'secretariausp@vanzolini.com.br; '  
        END  
        ELSE  
        BEGIN  
            SET @CONTATO = 'Unidade Paulista <br> Telefone:(11) 3145-3700'  
            SET @RESPONDER_PARA = 'secretariapta@vanzolini.com.br; '  
        END  

		SET @RESPONDER_PARA = @RESPONDER_PARA + 'suporte_techne@vanzolini.com.br'

        --***************************************    
        SELECT  
            @TEXTO =  
            @PREZADO + ' ' + @NOME + ',    
   <br>  
   <br>    
   Informamos que ap�s an�lise o requerimento n� <strong>' + @SOLICITACAO + '</strong> j� possui resposta.  
   <br>  
   <br>    
   Para consult�-la acesse a Central do Aluno pelo link   
    <a href="https://sga.vanzolini.org.br/AOnline">  
     https://sga.vanzolini.org.br/AOnline  
    </a>  
   <br>  
   <br>  
   <li>Acessar o Menu secretaria virtual > Consulta de Servi�os Solicitados </li>  
   <br>  
   <br>    
   Qualquer d�vida entrar em contato via fone:  
   <br>  
   <br>' + @CONTATO + '  
   <br>  
   <br>  
   Atenciosamente,<br>    
   Secretaria Acad�mica.  
   <br>  
   <br>  
   <em>Aten��o: Favor n�o responder este e-mail, disparo autom�tico pelo sistema.</em>    
   '  
    
  INSERT INTO FCAV_EMAIL_AUX  
            VALUES (@ALUNO, @TURMA, @SOLICITACAO, @DESTINATARIO, @RESPONDER_PARA, @ASSUNTO, @TEXTO, 'N', NULL,NULL)  
  
  -----------------------------------------------------------------------------------------  
  
        EXEC MSDB.dbo.SP_SEND_DBMAIL @profile_name =  
                             -- Desenvolvimento/homologa��o      
                             --FCAV_HOMOLOGACAO,  
                             -- Produ��o      
                             VANZOLINI_BD,    
                             @recipients = @DESTINATARIO,  
                             @blind_copy_recipients = @RESPONDER_PARA,  
                             @subject = @ASSUNTO,  
                             @body = @TEXTO,  
                             @body_format = HTML;  
         
        -----------------------------------------------------------------------------------------  
          
   UPDATE FCAV_EMAIL_AUX  
   SET  
   ENVIADO = 'S',   
   DATA_ENVIO = GETDATE()  
   WHERE  
   SOLICITACAO = @SOLICITACAO  
              
    END