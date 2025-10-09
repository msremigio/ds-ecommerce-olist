from os import path
from argparse import ArgumentParser
from sqlalchemy import create_engine
import logging
from sys import stdout
import pandas as pd
from sklearn.preprocessing import OneHotEncoder
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score

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
MODELS_DIR = path.join(BASE_DIR, 'models')

logger.info(f"Starting {path.basename(__file__)} execution")
# Read query file helper function
def read_query(query_file: str) -> str:
    with open(path.join(CURRENT_DIR, query_file), 'r') as open_file:
        query = open_file.read()

    logger.info(f"Success reading {query_file} query file")
    return query

# Read database table to Pandas dataframe helper function
def db_to_df(db: str, query: str) -> pd.DataFrame:
    engine = create_engine(f"sqlite:///{path.join(DATA_DIR, db)}")
    df_from_db = pd.read_sql(query, engine)

    logger.info(f"DataFrame with ABT info from the database was successfully created")
    return df_from_db


logger.info(f"Starting OOT and ABT DataFrames pre-processing")
# Raw DataFrame
df_raw = db_to_df(db_name, read_query(query_file))

# Out of time DataFrame
df_oot = df_raw[df_raw['obs_window_end_date'] == df_raw['obs_window_end_date'].max()].copy()

# Raw DataFrame without OOT cohort
df_abt = df_raw[df_raw['obs_window_end_date'] < df_raw['obs_window_end_date'].max()].copy()

# Filtered DataFrames
disposable_columns = ['obs_window_start_date', 'obs_window_end_date', 'seller_id', 'first_sale_date', 'last_sale_date', 'months_since_first_sale', 'months_since_last_sale', 'months_between_first_last_sale']
df_oot = df_oot.drop(columns=disposable_columns, inplace=False)
df_abt = df_abt.drop(columns=disposable_columns, inplace=False)

# Separate target, categorical features and numerical features
target = 'flag_model'
categorical_features = df_abt.dtypes[df_abt.dtypes == 'object'].index.to_list()
numerical_features = df_abt.dtypes[df_abt.dtypes != 'object'].index.to_list()

logger.info(f"One Hot Enconding categorical features")
# One hot encoding categorical features ('seller_state')
one_hot_enc = OneHotEncoder(handle_unknown='ignore', sparse_output=False).set_output(transform='pandas')
one_hot_enc.fit(df_abt[categorical_features])
encoded_abt_seller_state = one_hot_enc.transform(df_abt[categorical_features])
encoded_oot_seller_state = one_hot_enc.transform(df_oot[categorical_features])

# Enconded DataFrames
df_oot = pd.concat([df_oot.iloc[:, :-1], encoded_oot_seller_state, df_oot.iloc[:, -1:]], axis=1).copy()
df_abt = pd.concat([df_abt.iloc[:, :-1], encoded_abt_seller_state, df_abt.iloc[:, -1:]], axis=1).copy()

# Remove categorical features from the DataFrames
df_oot.drop(columns=categorical_features, inplace=True)
df_abt.drop(columns=categorical_features, inplace=True)

# Extract and Remove target variable from the DataFrames 'flag_model'
y_oot = df_oot[target]
y_abt = df_abt[target]

df_oot.drop(columns=target, inplace=True)
df_abt.drop(columns=target, inplace=True)

logger.info(f"Separating train and test data")
# Split ABT DataFrame into train and test components
X_train, X_test, y_train, y_test = train_test_split(df_abt, y_abt, test_size=0.2, random_state=1995)

logger.info(f"Training the defined model")
# Best hyperparameters setting according to the GridSearch
clf = RandomForestClassifier(n_estimators=150, criterion='entropy', max_depth=50, min_samples_leaf=10, n_jobs=-1, random_state=1995)
clf.fit(X_train, y_train)

logger.info(f"Model {clf} trained")

# Train
y_train_proba = clf.predict_proba(X_train)[:,1]
y_pred_train = (y_train_proba >= 0.33).astype(int)
accuracy = accuracy_score(y_train, y_pred_train)
precision = precision_score(y_train, y_pred_train)
recall = recall_score(y_train, y_pred_train)
f1 = f1_score(y_train, y_pred_train)
roc_auc = roc_auc_score(y_train, y_train_proba)
model_train_metrics = {
    'acc': accuracy,
    'precision': precision,
    'recall': recall,
    'f1': f1,
    'roc_auc': roc_auc
}
logger.info(f"Train metrics (Threshold = 0.33) {model_train_metrics}")

# Test
y_test_proba = clf.predict_proba(X_test)[:,1]
y_pred_test = (y_test_proba >= 0.33).astype(int)
accuracy = accuracy_score(y_test, y_pred_test)
precision = precision_score(y_test, y_pred_test)
recall = recall_score(y_test, y_pred_test)
f1 = f1_score(y_test, y_pred_test)
roc_auc = roc_auc_score(y_test, y_test_proba)
model_test_metrics = {
    'acc': accuracy,
    'precision': precision,
    'recall': recall,
    'f1': f1,
    'roc_auc': roc_auc
}
logger.info(f"Test metrics (Threshold = 0.33) {model_test_metrics}")

# OOT
y_oot_proba = clf.predict_proba(df_oot)[:,1]
y_pred_oot = (y_oot_proba >= 0.33).astype(int)
accuracy = accuracy_score(y_oot, y_pred_oot)
precision = precision_score(y_oot, y_pred_oot)
recall = recall_score(y_oot, y_pred_oot)
f1 = f1_score(y_oot, y_pred_oot)
roc_auc = roc_auc_score(y_oot, y_oot_proba)
model_oot_metrics = {
    'acc': accuracy,
    'precision': precision,
    'recall': recall,
    'f1': f1,
    'roc_auc': roc_auc
}
logger.info(f"OOT metrics (Threshold = 0.33) {model_oot_metrics}")

logger.info(f"Dumping model metadata file (.pkl)")
# Defining model Metadata
model_metadata = pd.Series(
    {
    'categorical_features': categorical_features,
    'numerical_features': numerical_features,
    'one_hot_enc': one_hot_enc,
    'model': clf,
    'model_params': clf.get_params(),
    'best_threshold': 0.33,
    'model_train_metrics': model_train_metrics,
    'model_test_metrics': model_test_metrics,
    'model_oot_metrics': model_oot_metrics
    }
)

model_metadata.to_pickle(path.join(MODELS_DIR, 'random_forest.pkl'))

logger.info(f"Model saved into {MODELS_DIR}")