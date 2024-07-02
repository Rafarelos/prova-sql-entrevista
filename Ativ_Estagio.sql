-- Lista de funcionários ordenando pelo salário decrescente.
SELECT *
FROM VENDEDORES
ORDER BY salario DESC;

-- Lista de pedidos de vendas ordenado por data de emissão.
SELECT *
FROM PEDIDO
ORDER BY data_emissao;

-- Valor de faturamento por cliente.
SELECT cli.*, SUM(pd.valor_total) AS valor_faturamento
FROM CLIENTES AS cli
INNER JOIN PEDIDO AS pd ON cli.id_cliente = pd.id_cliente
GROUP BY cli.id_cliente
ORDER BY valor_faturamento;

-- Valor de faturamento por empresa.
SELECT e.id_empresa, e.razao_social, SUM(pd.valor_total) AS valor_faturamento
FROM EMPRESA AS e
INNER JOIN PEDIDO AS pd ON e.id_empresa = pd.id_empresa
GROUP BY e.id_empresa
ORDER BY valor_faturamento;

-- Valor de faturamento por vendedor.
SELECT v.*, SUM(pd.valor_total) AS valor_faturamento
FROM VENDEDORES AS v
INNER JOIN PEDIDO AS pd ON v.id_vendedor = pd.id_pedido
GROUP BY v.id_vendedor
ORDER BY valor_faturamento;

-- Consultas de Junção:
WITH UltimoPrecoPraticado AS (
    SELECT
        I.id_produto,
        P.id_cliente,
        I.preco_praticado,
        ROW_NUMBER() OVER (PARTITION BY I.id_produto, P.id_cliente ORDER BY P.data_emissao DESC) AS rn
    FROM ITENS_PEDIDO I
    JOIN PEDIDO P ON I.id_pedido = P.id_pedido
) -- WITH usado pra unir as listas PEDIDO e CLIENTES
-- Utilizei a Query pra achar o valor do último preço praticado
-- Depois utilizei um ORDER DESC com a data de emissão.
	
SELECT 
    P.id_produto,
    P.descricao,
    C.id_cliente,
    C.razao_social AS razao_social_cliente,
    E.id_empresa,
    E.razao_social AS razao_social_empresa,
    V.id_vendedor,
    V.nome AS nome_vendedor,
    CPP.preco_minimo,
    CPP.preco_maximo,
    UPP.preco_praticado, CPP.preco_minimo AS preco_base
	-- escolhi as colunas que a atividade pedia
FROM PRODUTOS P
	WHERE preco_base IS NOT null -- para remover os valores `null`
JOIN CLIENTES C ON TRUE -- 'on true' para atribuir todas as linhas da tabela CLIENTES
JOIN EMPRESA E ON C.id_empresa = E.id_empresa
JOIN VENDEDORES V ON C.id_vendedor = V.id_vendedor
LEFT JOIN CONFIG_PRECO_PRODUTO CPP ON P.id_produto = CPP.id_produto AND C.id_empresa = CPP.id_empresa
LEFT JOIN UltimoPrecoPraticado UPP ON P.id_produto = UPP.id_produto AND C.id_cliente = UPP.id_cliente AND UPP.rn = 1
ORDER BY C.id_cliente, P.id_produto;