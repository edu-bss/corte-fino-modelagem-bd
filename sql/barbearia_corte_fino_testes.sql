DROP FUNCTION IF EXISTS pg_temp.testar_rejeicao(TEXT, TEXT, TEXT);

CREATE FUNCTION pg_temp.testar_rejeicao(
    p_nome     TEXT,
    p_sql      TEXT,
    p_esperado TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $fn$

DECLARE
    v_constraint TEXT;
    v_coluna     TEXT;
    v_msg        TEXT;

BEGIN
    EXECUTE p_sql;

    RAISE EXCEPTION
        'FALHOU | %: a operacao foi aceita, mas deveria ser rejeitada',
        p_nome;

EXCEPTION
    WHEN raise_exception THEN
        RAISE;

    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_constraint = CONSTRAINT_NAME,
            v_coluna     = COLUMN_NAME,
            v_msg        = MESSAGE_TEXT;

        IF COALESCE(v_constraint, '') =
               ANY (string_to_array(p_esperado, '|'))
           OR COALESCE(v_coluna, '') =
               ANY (string_to_array(p_esperado, '|'))
        THEN
            RETURN
                'PASSOU | ' || p_nome || ' | ' || v_msg;
        ELSE
            RAISE EXCEPTION
                'FALHOU | %: rejeitada por outro motivo: %',
                p_nome,
                v_msg;
        END IF;

END;

$fn$;

SELECT 1 AS teste,
       pg_temp.testar_rejeicao(
           'PK duplicada em cliente',
           $t$
           INSERT INTO cliente
               (id_cliente, nome, telefone)
           VALUES
               (1, 'Teste PK', '(11) 90000-0001')
           $t$,
           'pk_cliente'
       ) AS resultado

UNION ALL

SELECT 2,
       pg_temp.testar_rejeicao(
           'FK: agendamento para cliente inexistente',
           $t$
           INSERT INTO agendamento
               (id_cliente, id_profissional, data_hora_inicio, status, pago)
           VALUES
               (9999, 1, '2026-12-20 10:00:00', 'AGENDADO', NULL)
           $t$,
           'fk_agendamento_cliente'
       )

UNION ALL

SELECT 3,
       pg_temp.testar_rejeicao(
           'FK: agendamento para profissional inexistente',
           $t$
           INSERT INTO agendamento
               (id_cliente, id_profissional, data_hora_inicio, status, pago)
           VALUES
               (1, 9999, '2026-12-20 10:00:00', 'AGENDADO', NULL)
           $t$,
           'fk_agendamento_profissional'
       )

UNION ALL

SELECT 4,
       pg_temp.testar_rejeicao(
           'NOT NULL: cliente sem nome',
           $t$
           INSERT INTO cliente (nome, telefone)
           VALUES (NULL, '(11) 90000-0002')
           $t$,
           'nome'
       )

UNION ALL

SELECT 5,
       pg_temp.testar_rejeicao(
           'UNIQUE: servico repetido no mesmo agendamento',
           $t$
           INSERT INTO agendamento_servico
               (id_agendamento, id_servico, agendado, realizado, preco_praticado)
           VALUES
               (1, 1, TRUE, TRUE, 90.00)
           $t$,
           'uq_agendamento_servico'
       )

UNION ALL

SELECT 6,
       pg_temp.testar_rejeicao(
           'UNIQUE: produto repetido na mesma venda',
           $t$
           INSERT INTO item_venda
               (id_venda, id_produto, quantidade, preco_praticado)
           VALUES
               (1, 1, 1, 55.00)
           $t$,
           'uq_item_venda_produto'
       )

UNION ALL

SELECT 7,
       pg_temp.testar_rejeicao(
           'CHECK: CONCLUIDO com pago FALSE',
           $t$
           INSERT INTO agendamento
               (id_cliente, id_profissional, data_hora_inicio, status, pago)
           VALUES
               (1, 1, '2026-12-20 10:00:00', 'CONCLUIDO', FALSE)
           $t$,
           'ck_agendamento_pagamento'
       )

UNION ALL

SELECT 8,
       pg_temp.testar_rejeicao(
           'CHECK: CONCLUIDO com pago NULL',
           $t$
           INSERT INTO agendamento
               (id_cliente, id_profissional, data_hora_inicio, status, pago)
           VALUES
               (1, 1, '2026-12-20 10:00:00', 'CONCLUIDO', NULL)
           $t$,
           'ck_agendamento_pagamento'
       )

UNION ALL

SELECT 9,
       pg_temp.testar_rejeicao(
           'CHECK: AGENDADO com pago TRUE',
           $t$
           INSERT INTO agendamento
               (id_cliente, id_profissional, data_hora_inicio, status, pago)
           VALUES
               (1, 1, '2026-12-20 10:00:00', 'AGENDADO', TRUE)
           $t$,
           'ck_agendamento_pagamento'
       )

UNION ALL

SELECT 10,
       pg_temp.testar_rejeicao(
           'CHECK: status invalido',
           $t$
           INSERT INTO agendamento
               (id_cliente, id_profissional, data_hora_inicio, status, pago)
           VALUES
               (1, 1, '2026-12-20 10:00:00', 'REMARCADO', NULL)
           $t$,
           'ck_agendamento_status'
       )

UNION ALL

SELECT 11,
       pg_temp.testar_rejeicao(
           'CHECK: servico nem agendado nem realizado',
           $t$
           INSERT INTO agendamento_servico
               (id_agendamento, id_servico, agendado, realizado, preco_praticado)
           VALUES
               (8, 3, FALSE, FALSE, 35.00)
           $t$,
           'ck_agendamento_servico_situacao'
       )

UNION ALL

SELECT 12,
       pg_temp.testar_rejeicao(
           'CHECK: preco de servico zerado',
           $t$
           INSERT INTO servico
               (nome, categoria, preco_atual, duracao_prevista_min)
           VALUES
               ('Teste', 'Cabelo', 0, 10)
           $t$,
           'ck_servico_preco'
       )

UNION ALL

SELECT 13,
       pg_temp.testar_rejeicao(
           'CHECK: quantidade de item igual a zero',
           $t$
           INSERT INTO item_venda
               (id_venda, id_produto, quantidade, preco_praticado)
           VALUES
               (1, 2, 0, 48.00)
           $t$,
           'ck_item_venda_quantidade'
       )

UNION ALL

SELECT 14,
       pg_temp.testar_rejeicao(
           'CHECK: tipo de movimentacao invalido',
           $t$
           INSERT INTO mov_estoque
               (id_produto, tipo, quantidade)
           VALUES
               (1, 'AJUSTE', 1)
           $t$,
           'ck_mov_estoque_tipo'
       )

UNION ALL

SELECT 15,
       pg_temp.testar_rejeicao(
           'CHECK: quantidade de movimentacao igual a zero',
           $t$
           INSERT INTO mov_estoque
               (id_produto, tipo, quantidade)
           VALUES
               (1, 'ENTRADA', 0)
           $t$,
           'ck_mov_estoque_quantidade'
       )

UNION ALL

SELECT 16,
       pg_temp.testar_rejeicao(
           'DELETE: cliente com historico',
           $t$
           DELETE FROM cliente
           WHERE id_cliente = 1
           $t$,
           'fk_agendamento_cliente|fk_venda_cliente'
       )

UNION ALL

SELECT 17,
       pg_temp.testar_rejeicao(
           'DELETE: servico utilizado em agendamentos',
           $t$
           DELETE FROM servico
           WHERE id_servico = 1
           $t$,
           'fk_agendamento_servico_servico'
       )

UNION ALL

SELECT 18,
       pg_temp.testar_rejeicao(
           'DELETE: produto com movimentacao',
           $t$
           DELETE FROM produto
           WHERE id_produto = 1
           $t$,
           'fk_item_venda_produto|fk_mov_estoque_produto'
       )

ORDER BY teste;