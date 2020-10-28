
/*
	CONSULTA PARA TRAZER A RELAÇAÕ DE BOLETOS VENCIDOS A MAIS DE 15 DIAS PARA 
	DISPARO DE E-MAIL AUTOMÁTICO.

*/

SELECT 
	VT.CURSO, CS.NOME, VT.TURMA, 
	EX.ALUNO, PE.NOME_COMPL,PE.E_MAIL,
	SUM(IL.VALOR) VALOR_PAGAR
FROM 
	VW_FCAV_EXTRATO_FINANCEIRO2 EX
	INNER JOIN 	VW_FCAV_INI_FIM_CURSO_TURMA VT
		ON VT.TURMA = EX.TURMA
	INNER JOIN LY_ITEM_LANC IL
		ON IL.COBRANCA = EX.COBRANCA
	INNER JOIN LY_CURSO CS
		ON CS.CURSO = VT.CURSO
	INNER JOIN LY_ALUNO AL
		ON AL.ALUNO = EX.ALUNO
	INNER JOIN LY_PESSOA PE
		ON PE.PESSOA = AL.PESSOA
WHERE 
	VT.UNIDADE_RESPONSAVEL IN ('CAPAC','ESPEC', 'DIFUS')			  --> Somente para os cursos de Capacitação, Especialização e Difusão;
	AND DAY(DATA_DE_VENCIMENTO) between 15 and 18					  --> Boletos com o dia de vencimento entre 15 e 18. Se refere aos boletos de mensalidades;
	AND DATEDIFF(DAY,DATA_DE_VENCIMENTO,GETDATE()) between 15 and 90  --> 15 dias - prazo para negociação com o banco /  90 dias para envio ao SERASA;
	AND IL.PARCELA != 1												  --> Não traz o primeiro boleto de matrícula;
	AND EX.VALOR_PAGO = 0											  --> Boletos que estão com o pago zerados;
	AND VALOR_PAGAR > 0												  --> Valor a pagar maior que zero;
	AND EX.SITUACAO_BOLETO = 'Vencido'								  --> Boletos vencidos.
GROUP BY VT.CURSO,CS.NOME,VT.TURMA,EX.ALUNO,PE.NOME_COMPL,PE.E_MAIL




/*
Mensagem padrão do e-mail

Prezado(a) Aluno(a), Bom Dia!

Informamos que consta pendente de pagamento em nosso sistema parcelas de mensalidade 

referente ao seu Curso de Especialização.

Solicitamos que entre em contato, para negociação do valor em aberto, o mais breve possível.

Parcelas vencidas a mais de 90 dias, serão inseridas no SERASA.

Estamos à disposição.  

Claudia/Danitiela/Cibele
Tel. (11) 3024-2272/2257/2271 Whatsapp: (11) 97590-5458
e-mail: cobranca@vanzolini.org.br
 
Horário de atendimento: segunda à sexta-feira das 8h00 às 16h30.
Caso o pagamento tenha sido efetuado, solicitamos desconsiderar a cobrança e pedimos a gentileza de nos contatar para a devida regularização. 

Cordialmente,

Departamento de Cobrança
Fundação Carlos Alberto Vanzolini

*/