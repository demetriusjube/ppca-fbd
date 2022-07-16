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

Uma vez que os dados brutos já estão cadastrados na base, faremos o processo de normalização dos dados de despesa dentro do nosso modelo. 

--------

Consultas 
- Quais são os maiores tipos de despesas (view) por mandato de senador (agregar legislaturas). (Ricardo)
- Quais senadores mais gastaram em cada legislatura. (Marcos) 
- Quem é o fornecedor que mais ganhou dinheiro e quais senadores mais contrataram um dado fornecedor. (Marcos)
- Para um mesmo tipo de despesa e um mesmo fornedor, verificar se há divergências nos preços cobrados de cada senador. (Ricardo)
- Quantidade média de gastos por senador e por partido. (Marcos)
- Evolução de percentual de parlamentares de cada gênero por legislatura. (Marcos)

Procedure
- Senador (Ricardo)
  - Carga a partir de CSV.
  - Realizar o tratamento de inserção de novos senadores.
  - Para cada registro, o senador está na base? Ele já tem mandato? 
- Despesas (Jubé)
  - Carga a partir de CSV.  
  - Realizar a transformação dos dados extraídos (separar mandato e legislatura no arquivo de depesas).
  - Realizar a carga inicial das informações extraídas por meio do CSV.
  - A cada chamada, ler toda a tabela e tratar os dados novos.
 

Trigger (Ricardo)
- A cada insert na tabela carga_senador, verificar se já existe o registro do sernador e chamar a procedure de tratar senador. 


