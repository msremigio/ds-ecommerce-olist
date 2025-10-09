## ds-ecommerce-olist

Projeto de análise e modelagem preditiva de churn para vendedores do e-commerce Olist.


### Estrutura do Projeto

```text
ds-ecommerce-olist/
├── abt/
│   ├── create_abt.sql
│   ├── generate_abt_sellers_table.py
├── data/
│   ├── db-schema.png
│   └── olist.sqlite
├── features_store/
│   ├── create_cohort.sql
│   ├── first_cohort.sql
│   ├── generate_features_store_table.py
├── models/
│   ├── abt_churn.sql
│   ├── model_churn.py
│   ├── model_churn_exp.py
│   └── random_forest.pkl
├── sql_data_preparation/
│   ├── sellers_features_store.sql
│   ├── tb_customers.sql
│   ├── tb_leads_closed.sql
│   ├── tb_orders.sql
│   ├── tb_order_items.sql
│   ├── tb_order_payments.sql
│   ├── tb_order_reviews.sql
│   ├── tb_products.sql
│   ├── tb_sellers.sql
├── main.py
├── pyproject.toml
├── README.md
├── uv.lock
```

- `abt/`: Scripts e consultas para geração da tabela ABT (Analytical Base Table), incluindo SQL e Python para manipulação e criação da base de modelagem.
- `features_store/`: Scripts para geração e manipulação da tabela de features dos vendedores.
- `models/`: Scripts de modelagem, experimentos e metadados do modelo.
- `sql_data_preparation/`: Scripts SQL para preparação e consulta dos dados do banco.
- `data/`: Banco de dados SQLite e imagem do schema.

### Requisitos

- Verifique o arquivo `pyproject.toml`.

### Scripts de Geração das Tabelas

#### features_store/generate_features_store_table.py

- **Função:** Extrai uma coorte de dados para uma data de referência e insere/cria a tabela de features dos sellers.
- **Argumentos:**
	- `-d` ou `--date`: Data de referência da coorte (formato YYYY-MM-DD)
	- `-t` ou `--table`: Nome da tabela de destino
- **Fluxo:**
	- Lê o SQL de `create_cohort.sql`
	- Formata a query com a data informada
	- Tenta criar a tabela; se já existir, insere os dados da nova coorte após remover dados antigos da mesma data.

**Exemplo de execução:**
```bash
python features_store/generate_features_store_table.py -d 2017-01-01 -t sellers_features_store
```

#### abt/generate_abt_sellers_table.py

- **Função:** Gera a tabela ABT (Analytical Base Table) a partir da tabela de features.
- **Argumentos:**
	- `-t` ou `--table`: Nome da tabela ABT a ser criada
- **Fluxo:**
	- Lê o SQL de `create_abt.sql`
	- Tenta criar a tabela ABT; se já existir, faz o drop e recria.

**Exemplo de execução:**
```bash
python abt/generate_abt_sellers_table.py -t abt_churn
```

Consulte cada diretório para detalhes sobre os scripts e arquivos disponíveis.

### Scripts de Geração e Dump do Modelo

#### 1. model_churn.py

Este script treina um modelo RandomForest para prever churn de sellers.

**Argumentos parseáveis:**

- `-db` ou `--database`: Nome do arquivo do banco SQLite (ex: `olist.sqlite`)
- `-q` ou `--query`: Caminho do arquivo SQL com a consulta para gerar a ABT (ex: `abt_churn.sql`)

**Exemplo de execução:**
```bash
python models/model_churn.py -db olist.sqlite -q abt_churn.sql
```

#### 2. model_churn_exp.py

Script para experimentos, tuning e análise de thresholds do modelo. Os parâmetros de banco e consulta SQL estão definidos no início do arquivo, podendo ser ajustados manualmente.

### Consultas SQL

Os arquivos `.sql` em `sql_data_preparation/` são usados para preparar e consultar dados do banco. O arquivo passado via argumento (`--query`) deve retornar uma tabela com as colunas necessárias para o modelo, incluindo a variável alvo `flag_model`.

Exemplo de uso:
```sql
SELECT * FROM sellers_features_store;
```

### Metadados do Modelo

Após o treinamento, o modelo e seus metadados são salvos em `models/random_forest.pkl`.

**Conteúdo dos metadados:**
- `categorical_features`: Lista de variáveis categóricas usadas no modelo
- `numerical_features`: Lista de variáveis numéricas (incluindo a variável alvo na última coluna)
- `one_hot_enc`: Objeto do one hot encoder utilizado
- `model`: Objeto RandomForest treinado
- `model_params`: Hiperparâmetros do modelo
- `best_threshold`: Threshold ótimo para classificação
- `model_train_metrics`: Métricas de treino (acc, precision, recall, f1, roc_auc)
- `model_test_metrics`: Métricas de teste
- `model_oot_metrics`: Métricas OOT (out-of-time)

### Exemplo de leitura dos metadados
```python
import pandas as pd
from os import path
model_metadata = pd.read_pickle(path.join('models', 'random_forest.pkl'))
print(model_metadata)
```

### Observações
- Certifique-se de que o arquivo SQL retorna as colunas esperadas.
- O modelo utiliza OneHotEncoder para variáveis categóricas.
- O threshold padrão para classificação é 0.33, mas pode ser ajustado conforme análise de métricas.

---
Para dúvidas ou sugestões, abra uma issue ou entre em contato.
