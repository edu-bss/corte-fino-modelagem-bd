Corte Fino
ERP para Barbearia Premium
Projeto Integrador da disciplina de Modelagem de Banco de Dados.

O projeto apresenta a modelagem e implementação, em PostgreSQL, da base de dados de um ERP simplificado para a barbearia fictícia Corte Fino.

Objetivo
Estruturar um banco de dados relacional capaz de apoiar:

cadastro de clientes;
cadastro de profissionais;
serviços;
agendamentos;
vendas de produtos;
controle de estoque;
preservação do histórico de preços;
consultas operacionais e gerenciais.
Tecnologias
PostgreSQL
pgAdmin 4
SQL
Modelo de Dados
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
Estrutura do Repositório
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
Execução
Pré-requisitos
PostgreSQL
pgAdmin 4, DBeaver ou cliente PostgreSQL compatível
Criar o banco
CREATE DATABASE erp_barbearia;
Depois, conectar-se ao banco:

erp_barbearia
e executar:

sql/barbearia_completo.sql
O script:

cria as 9 tabelas;
cria constraints e índices;
carrega a massa de dados;
ajusta as sequences;
executa consultas operacionais;
executa consultas gerenciais;
executa auditorias;
executa os testes negativos de integridade;
demonstra operações de UPDATE e DELETE.
Validação
A implementação foi executada e validada em PostgreSQL.

Resultados obtidos:

9 tabelas criadas;
massa de dados carregada;
18 testes negativos de integridade aprovados;
11 auditorias sem inconsistências;
PK, FK, NOT NULL, UNIQUE e CHECK validados;
preservação do histórico de preços validada;
integridade referencial validada;
UPDATE e DELETE testados.
As evidências estão disponíveis na pasta evidencias/.

Arquitetura Analítica Futura
Business Intelligence e Inteligência Artificial não foram implementados neste projeto.

Como evolução futura, é proposta a arquitetura:

PostgreSQL
    ↓
Camada analítica
    ↓
Power BI
    ↓
KPIs e dashboards
Também são propostas aplicações futuras de IA para:

previsão de demanda;
otimização da agenda;
previsão de reposição de estoque;
recomendação de produtos e serviços.
Privacidade e LGPD
Os dados utilizados no projeto são fictícios e destinados exclusivamente a fins acadêmicos.

Uma futura implantação produtiva deverá incorporar controles técnicos, administrativos e organizacionais compatíveis com a Lei Geral de Proteção de Dados Pessoais (LGPD).

Autores:
EDUARDO BATISTA DA SILVA SOUSA
GUILHERME COUTO PEREIRA
GUILHERME MARQUES HONORIA 
MATHEUS BORGES CORDEIRO


Status
Projeto acadêmico implementado e validado em PostgreSQL.
