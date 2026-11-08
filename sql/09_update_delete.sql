-- ============================================================
-- 09. EXEMPLOS DE UPDATE E DELETE (com SELECT antes e depois)
-- Todos os exemplos devolvem a base ao estado original
-- ============================================================

-- ---------- UPDATE 1: reajuste de preco preserva o historico ----------

-- ANTES: preco atual 100, historico 90 e 100
SELECT s.nome AS servico, s.preco_atual,
       aus.id_agendamento, aus.preco_praticado
FROM servico s
JOIN agendamento_servico aus ON aus.id_servico = s.id_servico
WHERE s.id_servico = 1
ORDER BY aus.id_agendamento;

UPDATE servico
SET preco_atual = 110.00
WHERE id_servico = 1;

-- DEPOIS: preco atual 110, preco_praticado de cada agendamento inalterado
SELECT s.nome AS servico, s.preco_atual,
       aus.id_agendamento, aus.preco_praticado
FROM servico s
JOIN agendamento_servico aus ON aus.id_servico = s.id_servico
WHERE s.id_servico = 1
ORDER BY aus.id_agendamento;

-- Somente o servico 1 foi alterado (os demais mantem o preco)
SELECT id_servico, nome, preco_atual
FROM servico
ORDER BY id_servico;

-- Restaura o preco de catalogo
UPDATE servico
SET preco_atual = 100.00
WHERE id_servico = 1;

-- ---------- DELETE 1: exclusao permitida (registro sem historico) ----------
-- O INSERT sem id tambem comprova que as sequencias foram ajustadas
-- esperado: id_cliente maior que 6, sem erro de chave duplicada
-- (o valor exato pode ser 7 ou 8, pois testes que falham, como o NOT NULL
--  do arquivo 08, tambem consomem valores da sequencia)

INSERT INTO cliente (nome, telefone)
VALUES ('Cliente Temporario', '(11) 90000-0000');

-- ANTES: 1 registro
SELECT id_cliente, nome FROM cliente WHERE nome = 'Cliente Temporario';

DELETE FROM cliente
WHERE nome = 'Cliente Temporario';

-- DEPOIS: 0 registros
SELECT id_cliente, nome FROM cliente WHERE nome = 'Cliente Temporario';

-- ---------- DELETE 2: exclusao bloqueada (cliente com historico) ----------

DO $$
BEGIN
    DELETE FROM cliente WHERE id_cliente = 1;
    RAISE EXCEPTION 'FALHOU - a exclusao do cliente 1 deveria ser bloqueada';
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'PASSOU - exclusao bloqueada pela FK: %', SQLERRM;
END
$$;

-- ---------- UPDATE 2: inativacao (exclusao logica) preserva o historico ----------

-- ANTES: ativo = true
SELECT id_cliente, nome, ativo FROM cliente WHERE id_cliente = 4;

UPDATE cliente
SET ativo = FALSE
WHERE id_cliente = 4;

-- DEPOIS: ativo = false, e o historico continua consultavel
SELECT c.id_cliente, c.nome, c.ativo, a.id_agendamento, a.status
FROM cliente c
JOIN agendamento a ON a.id_cliente = c.id_cliente
WHERE c.id_cliente = 4;

-- Restaura o cadastro
UPDATE cliente
SET ativo = TRUE
WHERE id_cliente = 4;
