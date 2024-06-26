-- inserir novo colaborador
INSERT INTO brh.papel (
    id,
    nome
) VALUES (
    8,
    'Especialista de Negocios'
);

INSERT INTO brh.endereco (
    cep,
    uf,
    cidade,
    bairro
) VALUES (
    '85296-037',
    'SP',
    'Valinhos',
    'Vila Nazare'
);

INSERT INTO brh.colaborador (
    matricula,
    nome,
    cpf,
    salario,
    departamento,
    cep,
    logradouro,
    complemento_endereco
) VALUES (
    'A124',
    'Fulano de Tal',
    '001.543.876-08',
    '4123',
    'SEDES',
    '85296-037',
    'Rua Caio da Silveira',
    'Casa 1'
);

INSERT INTO brh.telefone_colaborador (
    colaborador,
    numero,
    tipo
) VALUES (
    'A124',
    '(19) 95896-4289',
    'M'
);

INSERT INTO brh.telefone_colaborador (
    colaborador,
    numero,
    tipo
) VALUES (
    'A124',
    '(19) 3965-8542',
    'R'
);

INSERT INTO brh.email_colaborador (
    colaborador,
    email,
    tipo
) VALUES (
    'A124',
    'fulano@email.com',
    'P'
);

INSERT INTO brh.email_colaborador (
    colaborador,
    email,
    tipo
) VALUES (
    'A124',
    'fulano.tal@brh.com',
    'T'
);

INSERT INTO brh.dependente (
    cpf,
    colaborador,
    nome,
    parentesco,
    data_nascimento
) VALUES (
    '452.637.981-65',
    'A124',
    'Beltrana de Tal',
    'Filho(a)',
    TO_DATE('2014-05-27', 'yyyy-mm-dd')
);

INSERT INTO brh.dependente (
    cpf,
    colaborador,
    nome,
    parentesco,
    data_nascimento
) VALUES (
    '069.854.574-52',
    'A124',
    'Cicrana de Tal',
    'Conjuge',
    TO_DATE('1976-04-16', 'yyyy-mm-dd')
);

INSERT INTO brh.projeto (
    nome,
    responsavel,
    inicio,
    fim
) VALUES (
    'BI',
    'A123',
    TO_DATE('2023-09-01', 'yyyy-mm-dd'),
    NULL
);

INSERT INTO brh.atribuicao (
    projeto,
    colaborador,
    papel
) VALUES (
    9,
    'A124',
    8
);

COMMIT;

-- Relatorio de conjuges
SELECT
    brh.colaborador.nome,
    brh.dependente.nome,
    brh.dependente.data_nascimento,
    brh.dependente.parentesco
FROM
         brh.colaborador
    INNER JOIN brh.dependente ON brh.colaborador.matricula = brh.dependente.colaborador;

COMMIT;

-- Filtrar dependentes:
SELECT
    brh.colaborador.nome AS colaborador,
    brh.dependente.nome  AS dependente
FROM
         brh.colaborador
    INNER JOIN brh.dependente ON brh.dependente.colaborador = brh.colaborador.matricula
WHERE
    EXTRACT(MONTH FROM brh.dependente.data_nascimento) BETWEEN 04 AND 06
    OR brh.dependente.nome LIKE '%h%'
ORDER BY
    ( brh.colaborador.nome ),
    ( brh.dependente.nome );
    
COMMIT;

-- Listar colaborador com maior salario:
SELECT
    nome,
    salario
FROM
    brh.colaborador
WHERE
    salario = (
        SELECT
            MAX(salario)
        FROM
            brh.colaborador
    );
    
COMMIT;    

-- Relatorio de senioridade:
SELECT
    matricula,
    nome,
    salario,
    (
        CASE
            WHEN salario <= 3000               THEN
                'JUNIOR'
            WHEN salario BETWEEN 3001 AND 6000 THEN
                'PLENO'
            WHEN salario BETWEEN 6001 AND 20000 THEN
                'SENIOR'
            ELSE
                'CORPO DIRETOR'
        END
    ) AS senioridade
FROM
    brh.colaborador
ORDER BY
    ( senioridade ),
    ( brh.colaborador.nome );

COMMIT;

-- Relatorio de contatos
SELECT
    brh.colaborador.nome,
    brh.email_colaborador.email,
    brh.telefone_colaborador.numero
FROM
         brh.colaborador
    INNER JOIN brh.email_colaborador ON brh.colaborador.matricula = brh.email_colaborador.colaborador
    INNER JOIN brh.telefone_colaborador ON brh.colaborador.matricula = brh.telefone_colaborador.colaborador
WHERE
        brh.email_colaborador.tipo = 'T'
    AND brh.telefone_colaborador.tipo = 'M'
ORDER BY
    ( brh.colaborador.nome );

-- Listar colaboradores com mais dependentes:
SELECT
    *
FROM
    (
        SELECT
            brh.colaborador.nome              AS nome_do_colaborador,
            COUNT(brh.dependente.colaborador) AS quantidade_de_dependentes
        FROM
                 brh.colaborador
            INNER JOIN brh.dependente ON brh.dependente.colaborador = brh.colaborador.matricula
        GROUP BY
            brh.colaborador.nome
        ORDER BY
            brh.colaborador.nome
    )
WHERE
    quantidade_de_dependentes >= 2
ORDER BY
    quantidade_de_dependentes DESC,
    nome_do_colaborador;

COMMIT;

-- Relatorio de dependentes menores de idade:
SELECT 
    colaborador,
    nome,
    trunc(months_between(sysdate, data_nascimento)/12) as idade
FROM 
    brh.dependente
WHERE
    trunc(months_between(sysdate, data_nascimento)/12) < 18;
    
COMMIT;

-- Relatorio analitico de equipes
SELECT
    brh.departamento.nome           AS "DEPARTAMENTO",
    brh.departamento.chefe,
    brh.colaborador.nome            AS "COLABORADOR",
    brh.atribuicao.projeto          AS "ID PROJETO",
    brh.projeto.nome                AS "NOME PROJETO",
    brh.atribuicao.papel            AS "ID PAPEL",
    brh.papel.nome                  AS "NOME DO PAPEL",
    brh.telefone_colaborador.numero AS "TELEFONE",
    brh.dependente.nome             AS "DEPENDENTE"
FROM
         brh.departamento
    INNER JOIN brh.colaborador ON brh.departamento.sigla = brh.colaborador.departamento
    INNER JOIN brh.atribuicao ON brh.atribuicao.colaborador = brh.colaborador.matricula
    INNER JOIN brh.projeto ON brh.projeto.id = brh.atribuicao.projeto
    INNER JOIN brh.papel ON brh.papel.id = brh.atribuicao.papel
    INNER JOIN brh.telefone_colaborador ON brh.telefone_colaborador.colaborador = colaborador.matricula
    INNER JOIN brh.dependente ON brh.dependente.colaborador = colaborador.matricula
ORDER BY
    ( brh.departamento.nome ),
    ( brh.projeto.nome ),
    ( brh.colaborador.nome );

COMMIT;

-- Listar colaboradores em projetos:
SELECT
    brh.departamento.nome             AS "DEPARTAMENTO",
    brh.projeto.nome                  AS "PROJETO",
    COUNT(brh.atribuicao.colaborador) AS "QUANTIDADE DE COLABORADORES"
FROM
         brh.departamento
    INNER JOIN brh.colaborador ON brh.departamento.sigla = brh.colaborador.departamento
    INNER JOIN brh.atribuicao ON brh.atribuicao.colaborador = brh.colaborador.matricula
    INNER JOIN brh.projeto ON brh.projeto.id = brh.atribuicao.projeto
GROUP BY
    brh.departamento.nome,
    brh.projeto.nome
ORDER BY
    ( brh.departamento.nome ),
    ( brh.projeto.nome );

COMMIT;