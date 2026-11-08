-- ============================================================
-- 07. CONSULTAS DE AUDITORIA
-- Cada consulta procura uma inconsistencia. Na massa oficial todas
-- devem retornar 0 registros
-- ============================================================

-- [A1] Atendimento CONCLUIDO sem nenhum servico realizado
-- esperado: 0 registros
SELECT a.id_agendamento, a.data_hora_inicio, a.status
FROM agendamento a
WHERE a.status = 'CONCLUIDO'
  AND NOT EXISTS (
      SELECT 1
      FROM agendamento_servico aus
      WHERE aus.id_agendamento = a.id_agendamento
        AND aus.realizado = TRUE
  );

-- [A2] Agendamento sem nenhum servico associado
-- esperado: 0 registros
SELECT a.id_agendamento, a.data_hora_inicio, a.status
FROM agendamento a
LEFT JOIN agendamento_servico aus ON aus.id_agendamento = a.id_agendamento
WHERE aus.id_agendamento_servico IS NULL;

-- [A3] Servico marcado como realizado em atendimento nao concluido
-- esperado: 0 registros
SELECT a.id_agendamento, a.status, s.nome AS servico
FROM agendamento_servico aus
JOIN agendamento a ON a.id_agendamento = aus.id_agendamento
JOIN servico s ON s.id_servico = aus.id_servico
WHERE aus.realizado = TRUE
  AND a.status <> 'CONCLUIDO';

-- [A4] Venda sem nenhum item
-- esperado: 0 registros
SELECT v.id_venda, v.id_cliente, v.data_hora
FROM venda v
LEFT JOIN item_venda iv ON iv.id_venda = v.id_venda
WHERE iv.id_item_venda IS NULL;

-- [A5] Estoque negativo
-- esperado: 0 registros
SELECT p.id_produto, p.nome AS produto,
       SUM(CASE WHEN me.tipo = 'ENTRADA' THEN me.quantidade
                ELSE -me.quantidade END) AS saldo_atual
FROM produto p
JOIN mov_estoque me ON me.id_produto = p.id_produto
GROUP BY p.id_produto, p.nome
HAVING SUM(CASE WHEN me.tipo = 'ENTRADA' THEN me.quantidade
                ELSE -me.quantidade END) < 0;

-- [A6] Divergencia entre itens de venda e saidas de estoque
-- A saida de cada venda e identificada pela observacao 'Venda N'
-- esperado: 0 registros
SELECT iv.id_venda, iv.id_produto,
       iv.quantidade AS quantidade_vendida,
       COALESCE(SUM(me.quantidade), 0) AS saida_registrada
FROM item_venda iv
LEFT JOIN mov_estoque me
       ON me.id_produto = iv.id_produto
      AND me.tipo = 'SAIDA'
      AND me.observacao = 'Venda ' || iv.id_venda
GROUP BY iv.id_venda, iv.id_produto, iv.quantidade
HAVING COALESCE(SUM(me.quantidade), 0) <> iv.quantidade;

-- [A7] Clientes possivelmente duplicados (mesmo telefone)
-- esperado: 0 registros
SELECT c.id_cliente, c.nome, c.telefone
FROM cliente c
WHERE c.telefone IN (
    SELECT telefone
    FROM cliente
    GROUP BY telefone
    HAVING COUNT(*) > 1
)
ORDER BY c.telefone, c.id_cliente;

-- [A8] Sobreposicao de horarios do mesmo profissional
-- Usa a duracao prevista dos servicos agendados (agendamentos cancelados ignorados)
-- esperado: 0 registros
WITH duracao AS (
    SELECT aus.id_agendamento,
           SUM(s.duracao_prevista_min) AS duracao_min
    FROM agendamento_servico aus
    JOIN servico s ON s.id_servico = aus.id_servico
    WHERE aus.agendado = TRUE
    GROUP BY aus.id_agendamento
),
janela AS (
    SELECT a.id_agendamento, a.id_profissional,
           a.data_hora_inicio AS inicio,
           a.data_hora_inicio + (d.duracao_min * INTERVAL '1 minute') AS fim
    FROM agendamento a
    JOIN duracao d ON d.id_agendamento = a.id_agendamento
    WHERE a.status <> 'CANCELADO'
)
SELECT j1.id_profissional,
       j1.id_agendamento AS agendamento_a,
       j2.id_agendamento AS agendamento_b,
       j1.inicio AS inicio_a, j1.fim AS fim_a, j2.inicio AS inicio_b
FROM janela j1
JOIN janela j2
  ON j1.id_profissional = j2.id_profissional
 AND j1.id_agendamento < j2.id_agendamento
 AND j1.inicio < j2.fim
 AND j2.inicio < j1.fim
ORDER BY j1.id_profissional, j1.inicio;

-- ============================================================
-- CHECAGENS SOBRE OS DADOS EXISTENTES
-- As constraints CHECK ja impedem estes casos em novas gravacoes.
-- Estas consultas confirmam que a massa carregada tambem esta limpa
-- ============================================================

-- [A9] Associacao agendamento-servico invalida (agendado = FALSE e realizado = FALSE)
-- esperado: 0 registros
SELECT *
FROM agendamento_servico
WHERE agendado = FALSE
  AND realizado = FALSE;

-- [A10] Quantidade invalida em item de venda
-- esperado: 0 registros
SELECT *
FROM item_venda
WHERE quantidade <= 0;

-- [A11] Quantidade invalida em movimentacao de estoque
-- esperado: 0 registros
SELECT *
FROM mov_estoque
WHERE quantidade <= 0;
