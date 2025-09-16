from os import path
from argparse import ArgumentParser
from sqlalchemy import create_engine
import logging
from sys import stdout
import pandas as pd
from sklearn.preprocessing import OneHotEncoder

# Logging pattern configuration
logger = logging.getLogger('example')
logger.setLevel(logging.DEBUG)

console = logging.StreamHandler(stdout)
console.setLevel(logging.INFO)

formatter = logging.Formatter("%(asctime)s [%(levelname)s] %(filename)s:%(lineno)d - %(message)s", datefmt="%Y-%m-%d %H:%M:%S")
console.setFormatter(formatter)

logger.addHandler(console)

# Arguments parsed when executing the model script
parser = ArgumentParser(prog='model_churn.py',
                        description='Generates a .pkl file with trained model metadata.')
parser.add_argument('-db', '--database', help='The name of the database where the ABT is located.')
parser.add_argument('-q', '--query', help='The .sql file to be executed when creating the dataframe.')
args = parser.parse_args()

db_name = args.database
query_file = args.query

# Paths to essential directories
CURRENT_DIR = path.dirname(__file__)
BASE_DIR = path.dirname(CURRENT_DIR)
DATA_DIR = path.join(BASE_DIR, 'data')

logger.info(f"Starting {path.basename(__file__)} execution.")
# Read query file helper function
def read_query(query_file: str) -> str:
    with open(path.join(CURRENT_DIR, query_file), 'r') as open_file:
        query = open_file.read()

    logger.info(f"Success reading {query_file} query file.")
    return query

# Read database table to Pandas dataframe helper function
def db_to_df(db: str, query: str) -> pd.DataFrame:
    engine = create_engine(f"sqlite:///{path.join(DATA_DIR, db)}")
    df_from_db = pd.read_sql(query, engine)

    logger.info(f"DataFrame with ABT info from the database was successfully created.")
    return df_from_db

# Raw DataFrame
df_raw = db_to_df(db_name, read_query(query_file))

# Filtered DataFrame
disposable_columns = ['obs_window_start_date', 'obs_window_end_date', 'seller_id', 'first_sale_date', 'last_sale_date']
df_filtered = df_raw.drop(columns=disposable_columns, inplace=False)

# One hot encoding categorical features ('seller_state')
categorical_features = df_filtered.dtypes[df_filtered.dtypes == 'object'].index.to_list()

one_hot_enc = OneHotEncoder(handle_unknown='ignore', sparse_output=False).set_output(transform="pandas")
one_hot_enc.fit(df_filtered[categorical_features])
encoded_seller_state = one_hot_enc.transform(df_filtered[categorical_features])

# Enconded DataFrame
df_encoded = pd.concat([df_filtered.iloc[:, :-1], encoded_seller_state, df_filtered.iloc[:, -1:]], axis=1)
df_encoded.drop(columns=categorical_features, inplace=True)

print(df_encoded.dtypes.to_string())
