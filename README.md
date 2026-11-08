# corte-fino-modelagem-bd
Corte Fino
ERP para Barbearia Premium
Projeto Integrador da disciplina de Modelagem de Banco de Dados.

O projeto apresenta a modelagem e implementação, em PostgreSQL, da base de dados de um ERP simplificado para a barbearia fictícia Corte Fino.

Objetivo
Estruturar um banco relacional capaz de apoiar:

cadastro de clientes;
profissionais;
serviços;
agendamentos;
vendas de produtos;
controle de estoque;
histórico de preços;
consultas gerenciais.
Tecnologias
PostgreSQL
pgAdmin 4
SQL
Modelo
O modelo possui 9 tabelas:

CLIENTE
PROFISSIONAL
SERVICO
AGENDAMENTO
AGENDAMENTO_SERVICO
PRODUTO
VENDA
ITEM_VENDA
MOV_ESTOQUE
Estrutura do repositório
sql/
    barbearia_completo.sql
    barbearia_corte_fino_testes.sql
    07_queries_auditoria.sql
    09_update_delete.sql

diagramas/
    DER_Conceitual_Corte_Fino.png

evidencias/
    print_validacao_testes.png
    print_auditoria.png

documentacao/
    Relatorio_Final_Corte_Fino.docx
