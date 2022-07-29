# ppca-fbd
Código da Disciplina Fundamentos de Bancos de Dados

## Arquitetura

O código do trabalho é feito usando como SGBD MySQL. Para utilizá-lo, vamos usar uma imagem Docker que já roda o banco de dados.

Após isso, faremos a importação dos dados das Cotas Parlamentares dos Senadores. Os dados abertos estão em https://www12.senado.leg.br/transparencia/dados-abertos-transparencia/dados-abertos-ceaps, item Cotas para Exercício da Atividade Parlamentar dos Senadores (CEAPS). Esses dados serão importados para uma tabela única, e normalizados em tabelas específicas depois.

Utilizaremos como ferramenta de interação com o banco de dados o DBeaver 

## Montagem do ambiente

- Instale o Docker com o Docker Compose(https://docs.docker.com/compose/install/)
- Rode o seguinte comando no local onde está o arquivo docker-compose.yml para subir o banco de dados: `docker-compose up`. Ele vai criar um banco de dados com as seguintes características:
 - Server host: localhost
 - Port: 3306
 - Database: fbd
 - Username: root
 - Password: fbd
- Instale o DBeaver (https://dbeaver.io/download/)

### Configuração do DBeaver

Pra acessar com mais facilidade o banco de dados e permitir uma importação com facilidade, é necessário configurar uma conexão com o DBeaver. Ela será feita conforme o roteiro abaixo:

1. Na aba Navegador de Banco de Dados, clique com o botão direito e selecione Criar -> Connection:
![Conexão](images/conexao-criar.png)

2. Selecione, na lista de SGBDs, o driver do MySQL. Se ele não estiver na máquina, ele vai baixar:
![Seleção do driver MySQL](images/conexao-driver.png)

3. Configure a conexão com as credenciais do banco criado pelo Docker (se usar uma instalação própria, use as credenciais definidas lá):
![Configuração das credenciais](images/conexao-config.png)

4. Modifique a conexão para que a opção Allow Public Key seja setada para `true`. Isso evita o erro de conexão que acontece quando o MySQL tenta recuperar uma chave pública para a conexão:
![Configuração Allow Public Key](images/conexao-allow-public-key.png)

5. Salve a conexão. 

## Importação dos dados

Para dar a carga dos dados recuperados do site da Transparência no nosso banco de dados, precisaremos fazer a preparação dos dados dos arquivos e a importação no SGBD. Veremos todos os passos a seguir.

### Criação das tabelas do banco de dados

Vamos criar os objetos de banco necessários para que possamos receber os dados e tratá-los para obter as informações que queremos. O script de criação dos dados está em `fbd_scripts/fbd-tables.sql`, e vai gerar o banco de dados da figura abaixo:

![Modelo de dados](images/modelo-dados.png)

Para rodar o script, faça o seguinte roteiro:

- No DBeaver, clique com o botão direito em cima do banco `fbd` e abra um Editor SQL:

![DBeaver SQL](images/dbeaver-sql.png)

- Rode o script mencionado acima. Ele criará toda a estrutura apresentada no modelo.

Além de criar a estrutura de tabelas, o script também carrega a tabela  _Legislatura_ , que já tem valores conhecidos para o nosso problema.

### Dados brutos de despesa

#### Tratamento dos arquivos

- Baixar os dados do [site](https://www12.senado.leg.br/transparencia/dados-abertos-transparencia/dados-abertos-ceaps). Utilizaremos o período de 2009 a 2021, por estarem mais completos e íntegros
- Abra os arquivos `csv` e retire a primeira linha. Ela tem o seguinte formato: `"ULTIMA ATUALIZACAO";"06/08/2021 02:00"`

#### Importação dos dados para o SGBD

- No Navegador de banco de dados, clique com o botão direito na tabela CARGA_DESPESA, e selecione Importar dados

![DBeaver - Importar dados](images/importacao-inicio.png)

- Escolha a fonte de dados (CSV)

![DBeaver - Fonte de dados CSV](images/importacao-csv.png)

- O programa vai abrir uma janela para a escolha do arquivo. Selecione o arquivo que deseja importar:

![DBeaver - Fonte de dados CSV](images/importacao-escolha-arquivo.png)

- Informe as propriedades da importação:

![DBeaver - Propriedades de importação](images/importacao-propriedades-importacao.png)

Note que as seguintes propriedades são específicas para o nosso caso:
  * Encoding (Traduzido de forma errada para Encodificando): ISO-8859-1
  * Delimitador de coluna: `;`. Os dados não são separados por vírgula na fonte, e sim, por ponto-e-vírgula
  * Definir Strings vazias para NULL: `true`. Dessa forma as colunas ficarão nulas, e não com string vazias
  * Formato Date/Time: `dd/MM/yyyy`, para que as datas sejam importadas no formato correto


- Mapeie as colunas do CSV com as colunas da tabela. Atenção para a coluna `DATA`, que deve ser mapeada para `DATA_REEMBOLSO`

![DBeaver - Mapeamento das colunas](images/importacao-mapeamento-colunas.png)

- Avance no Wizard até o resumo, e confira as especificações que foram definidas:

![DBeaver - Resumo da importação](images/importacao-resumo.png)

- Conclua o procedimento, e os dados serão carregados na tabela CARGA_DESPESA

### Dados dos Senadores

O portal do Senado não possui um arquivo pronto com os dados dos Senadores das legislaturas anteriores. Sendo assim, será necessário recuperar esses dados através dos dados que estão nas páginas HTML e formatá-los como CSVs para importação no banco.

#### Tratamento dos arquivos

- Entre no endereço que contém as [legislaturas](https://www25.senado.leg.br/web/senadores/legislaturas-anteriores) do Senado Federal
- Escolha a legislatura que será importada. No caso em tela, faremos isso para as legislaturas de 53 a 55
- Em  _Organizar por_ , selecione a opção  _Sexo_ 
- Selecione os nomes na tela e copie as informações
- Abra um editor de planilhas da sua preferência e cole as informações nele
- Acrescente duas colunas à direita dos dados: `Sexo` e `Legislatura`
- Preencha o valor da coluna `Sexo` de acordo com o o grupo
- Preencha o valor da coluna `Legislatura` com o número da legislatura pesquisada
- Apague as linhas que contém os valores Masculino e Feminino
- Repita o procedimento para cada legislatura
- Ao terminar de importar os dados das legislaturas anteriores, vá até o endereço da (legislatura atual)[https://www25.senado.leg.br/web/senadores/em-exercicio/-/e/por-sexo]
- Faça o mesmo tratamento que foi feito para as legislaturas anteriores
- Retire os caracteres `  *` (dois espaços em branco e um asterisco) da massa de dados. Esse sinal gráfico é pra representar os suplentes que entraram em exercício, e podem impedir que os senadores sejam identificados corretamente. 

#### Importação dos dados para o SGBD

Assim como foi feito para os dados de despesa, os dados de Senadores também devem ser importados utilizando o DBeaver. Repita os passos que foram feitos para a tabela `CARGA_DESPESA`, tendo o cuidado de mapear as colunas do CSV corretamente. 

Há, porém, uma diferença. A tabela `CARGA_SENADOR` possui uma  _trigger_ que vai disparar a cada registro, populando as tabelas `SENADOR`, `MANDATO` e `MANDATO_LEGISLATURA`. A lógica desse gatilho vai fazer a seguinte lógica:

- Verificar se já existe um Senador com aquele nome na tabela `SENADOR`. Em caso negativo, incluir. Caso exista, recuperar o ID_SENADOR dele
- Verificar se os dados de mandato já estão cadastrados para aquele Senador. Caso esteja, não precisa fazer nada. Caso contrário, fazer o seguinte:
  - Inserir o dado do Mandato
  - Para aquele mandato, vincular às respectivas legislaturas, através da tabela `MANDATO_LEGISLATURA` 

### Processo de ETL das despesas

Uma vez que os dados brutos já estão cadastrados na base, faremos o processo de normalização dos dados de despesa dentro do nosso modelo. O objeto responsável por fazer essa transformação é a procedure `PRC_ETL_DESPESA`. 

## MANIPULAÇÃO DE DADOS

### PROCEDURE

- Despesas (Jubé)
  - Carga a partir de CSV.  
  - Realizar a transformação dos dados extraídos (separar mandato e legislatura no arquivo de depesas).
  - Realizar a carga inicial das informações extraídas por meio do CSV.
  - A cada chamada, ler toda a tabela e tratar os dados novos.

### TRIGGER 

Trigger (Ricardo)
- A cada insert na tabela carga_senador, verificar se já existe o registro do sernador e chamar a procedure de tratar senador. 
  - Carga a partir de CSV.
  - Realizar o tratamento de inserção de novos senadores.
  - Para cada registro, o senador está na base? Ele já tem mandato? 

### VIEW

Um requisito do projeto de banco de dados era a criação de uma view. As views são consultas armazenadas que funcionam como uma tabela virtual. Os dados, de fato, não estão presentes na view, mas sim em suas tabelas de origem. A view, assim, é uma consulta e pode trazer dados de várias tabelas e utilizar todas as funções normalmente utilizadas em consultas, como group by, having, sum, count etc.

Uma view pode ser atualizável. Isso significa que ela aceita comandos que permitam a manipulação dos dados, ou seja, receber comandos de "insert", "update" ou "delete". A view recebe o comando e o direciona para a tabela física correspondente. 

Essa capacidade de atualização pode gerar algumas inconsistências. Caso a view inclua condições na cláusula "where", pode ocorrer a situação em que um "insert" na view não representa a inclusão de um registro na view. Isso ocorre se o registro inserido não fizer parte da seleção ("where") realizada para formar a consulta. 

Existe uma cláusula importante no tratamento de views, chamada de "with check option". Essa opção, ao ser inserida na view, realiza um controle sobre o registro a ser manipulado, relacionado à capacidade do registro participar ou não da seleção da view. Caso o registro seja retornável pela consulta da view, o SGBD impede a manipulação do registro, ou seja, ele não permite a inserção, a alteração ou a exclusão do registro.

A opção "with check option" só se aplica a views que forem atualizáveis. O SGBD não permite seu uso com views não atualizáveis.

Uma view será não atualizável se não houver correspondência de um para um entre um registro da tabela física e um registro da view. Algumas cláusulas de consulta também tornam a view não atualizável. O MYSQL elenca as seguintes condições para uma view ser não atualizável:

- Funções de agregação (SUM(), MIN(), MAX(), COUNT() etc)
- DISTINCT
- GROUP BY
- HAVING
- UNION / UNION ALL
- Uso de subconsulta (subquery)
- Subconsultas não dependentes tem algumas restrições
- Alguns joins
- Referência à visão não atualizável na cláusula FROM
- Subconsulta na cláusula WHERE que se refere a uma tabela na cláusula FROM
- Não possui tabelas na consulta para atualizar
- Uso de uma tabela temporária
- Várias referências a qualquer coluna de uma tabela base 

A view escolhida tem por objetivo identificar quais são os maiores tipos de despesas por legislatura e por partido. Vale ressaltar que uma legislatura é um período de quatro anos. A partir desse objetivos, a seguinte consulta foi materializada:

```
CREATE OR REPLACE VIEW fbd.VW_DESPESA_POR_LEGISLATURA AS
SELECT TD.DESCRICAO AS DESCRICAO_DESPESA, CONCAT(L.ANO_INICIO, " - ", L.ANO_FIM) AS LEGISLATURA, 
       SUM(D.VALOR_REEMBOLSADO) AS VALOR_TOTAL, m.PARTIDO 
FROM fbd.TIPO_DESPESA TD, fbd.DESPESA D, fbd.MANDATO M, 
     fbd.LEGISLATURA L, fbd.MANDATO_LEGISLATURA ML   
WHERE TD.ID_TIPO_DESPESA = D.ID_TIPO_DESPESA AND 
      D.ID_SENADOR = M.ID_SENADOR  AND
      M.ID_MANDATO = ML.ID_MANDATO AND 
      M.LEGISLATURA = ML.NR_LEGISLATURA AND 
      ML.NR_LEGISLATURA = L.NR_LEGISLATURA # AND 
      #(D.ANO BETWEEN L.ANO_INICIO AND L.ANO_FIM)
GROUP BY TD.ID_TIPO_DESPESA, m.periodo, m.PARTIDO 
ORDER BY m.PERIODO DESC, td.descricao, VALOR_TOTAL DESC;
```

Como se pode observar, essa consulta possui vários elementos que não permitem que essa view seja atualizável. Dentre eles, vê-se o uso de cláusulas group by e que não existe correspondência de um-para-um com uma tabela física. A saída dessa consulta por ser vista abaixo, com a apresentação dos seus primeiros registros:

![Resultado_View](images/view.png)


### CONSULTAS

#### CONSULTA 1 - Quais senadores mais gastaram em cada legislatura. (Marcos) 
#### CONSULTA 2 - Quem é o fornecedor que mais ganhou dinheiro e quais senadores mais contrataram um dado fornecedor. (Marcos)
#### CONSULTA 3 - Para um mesmo tipo de despesa e um mesmo fornedor, verificar se há divergências nos preços cobrados de cada senador. (Ricardo)
#### CONSULTA 4 - Quantidade média de gastos por senador e por partido. (Marcos)
#### CONSULTA 5 - Evolução de percentual de parlamentares de cada gênero por legislatura. (Marcos)

