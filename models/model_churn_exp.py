#%%
from os import path
from sqlalchemy import create_engine
import pandas as pd
from sklearn.preprocessing import OneHotEncoder
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score

#%%
db_name = 'olist.sqlite'
query_file = 'abt_churn.sql'

#%%
# Paths to essential directories
CURRENT_DIR = path.dirname(__file__)
BASE_DIR = path.dirname(CURRENT_DIR)
DATA_DIR = path.join(BASE_DIR, 'data')
MODELS_DIR = path.join(BASE_DIR, 'models')

#%%
# Read query file helper function
def read_query(query_file: str) -> str:
    with open(path.join(CURRENT_DIR, query_file), 'r') as open_file:
        query = open_file.read()

    return query

#%%
# Read database table to Pandas dataframe helper function
def db_to_df(db: str, query: str) -> pd.DataFrame:
    engine = create_engine(f"sqlite:///{path.join(DATA_DIR, db)}")
    df_from_db = pd.read_sql(query, engine)

    return df_from_db

#%%
# Raw DataFrame
df_raw = db_to_df(db_name, read_query(query_file))

#%%
# Out of time DataFrame
df_oot = df_raw[df_raw['obs_window_end_date'] == df_raw['obs_window_end_date'].max()].copy()

#%%
# Raw DataFrame without OOT cohort
df_abt = df_raw[df_raw['obs_window_end_date'] < df_raw['obs_window_end_date'].max()].copy()

#%%
# Filtered DataFrames
disposable_columns = ['obs_window_start_date', 'obs_window_end_date', 'seller_id', 'first_sale_date', 'last_sale_date', 'months_since_first_sale', 'months_since_last_sale', 'months_between_first_last_sale']
df_oot = df_oot.drop(columns=disposable_columns, inplace=False)
df_abt = df_abt.drop(columns=disposable_columns, inplace=False)

#%%
# Separate target, categorical features and numerical features
target = 'flag_model'
categorical_features = df_abt.dtypes[df_abt.dtypes == 'object'].index.to_list()
numerical_features = df_abt.dtypes[df_abt.dtypes != 'object'].index.to_list()
#numerical_features.remove(target[0])

#%%
# One hot encoding categorical features ('seller_state')
one_hot_enc = OneHotEncoder(handle_unknown='ignore', sparse_output=False).set_output(transform='pandas')
one_hot_enc.fit(df_abt[categorical_features])
encoded_abt_seller_state = one_hot_enc.transform(df_abt[categorical_features])
encoded_oot_seller_state = one_hot_enc.transform(df_oot[categorical_features])

#%%
# Enconded DataFrames
df_oot = pd.concat([df_oot.iloc[:, :-1], encoded_oot_seller_state, df_oot.iloc[:, -1:]], axis=1).copy()
df_abt = pd.concat([df_abt.iloc[:, :-1], encoded_abt_seller_state, df_abt.iloc[:, -1:]], axis=1).copy()

#%%
# Remove categorical features from the DataFrames
df_oot.drop(columns=categorical_features, inplace=True)
df_abt.drop(columns=categorical_features, inplace=True)

#%%
# Extract and Remove target variable from the DataFrames 'flag_model'
y_oot = df_oot[target]
y_abt = df_abt[target]

df_oot.drop(columns=target, inplace=True)
df_abt.drop(columns=target, inplace=True)

# %%
# Split ABT DataFrame into train and test components
X_train, X_test, y_train, y_test = train_test_split(df_abt, y_abt, test_size=0.2, random_state=1995)

# %%
# Define a RandomForestClassifier Model
clf = RandomForestClassifier(n_estimators=100, criterion='gini', max_depth=50, min_samples_leaf=30, n_jobs=-1, random_state=1995)

# %%
# Train the model with ABT data
clf.fit(X_train, y_train)

#%%
# Features importances for future definition of independent variables
pd.Series(clf.feature_importances_, index=X_train.columns).sort_values(ascending=False)[:25]

#%%
# Grid search for hyperparameter tunning
param_grid = {'n_estimators': [50, 100, 150, 200],
              'criterion': ['gini', 'entropy', 'log_loss'],
              'max_depth': [20, 30, 50],
              'min_samples_leaf': [10, 20, 30, 50, 100]}

grid = GridSearchCV(clf, param_grid, cv=5, scoring='roc_auc')
grid.fit(X_train, y_train)
print(f"Best Parameters: {grid.best_params_}")

#%%
# Best hyperparameters setting according to the GridSearch
clf = RandomForestClassifier(n_estimators=150, criterion='entropy', max_depth=50, min_samples_leaf=10, n_jobs=-1, random_state=1995)
clf.fit(X_train, y_train)


# %%
# Accuracy analysis
y_train_pred = clf.predict(X_train)
train_acc = accuracy_score(y_train, y_train_pred)
print(f"Train Data Accuracy: {train_acc}")

y_test_pred = clf.predict(X_test)
test_acc = accuracy_score(y_test, y_test_pred)
print(f"Test Data Accuracy: {test_acc}")

y_oot_pred = clf.predict(df_oot)
oot_acc = accuracy_score(y_oot, y_oot_pred)
print(f"OOT Data Accuracy: {oot_acc}")

# %%
# Precision analysis
train_precision = precision_score(y_train, y_train_pred)
print(f"Train Data Precision: {train_precision}")

test_precision = precision_score(y_test, y_test_pred)
print(f"Test Data Precision: {test_precision}")

oot_precision = precision_score(y_oot, y_oot_pred)
print(f"OOT Data Precision: {oot_precision}")

# %%
# Recall analysis
train_recall = recall_score(y_train, y_train_pred)
print(f"Train Data Recall: {train_recall}")

test_recall = recall_score(y_test, y_test_pred)
print(f"Test Data Recall: {test_recall}")

oot_recall = recall_score(y_oot, y_oot_pred)
print(f"OOT Data Recall: {oot_recall}")

# %%
# ROC AUC Analysis
y_train_proba = clf.predict_proba(X_train)[:,1]
train_roc_auc_score = roc_auc_score(y_train, y_train_proba)
print(f"Train Data ROC AUC Score: {train_roc_auc_score}")

y_test_proba = clf.predict_proba(X_test)[:,1]
test_roc_auc_score = roc_auc_score(y_test, y_test_proba)
print(f"Test Data ROC AUC Score: {test_roc_auc_score}")

y_oot_proba = clf.predict_proba(df_oot)[:,1]
oot_roc_auc_score = roc_auc_score(y_oot, y_oot_proba)
print(f"OOT Data ROC AUC Score: {oot_roc_auc_score}")

# %%
# Analyze different threshold values to maximize recall
thresholds = [0.2, 0.23, 0.25, 0.28, 0.3, 0.33, 0.35, 0.38, 0.4, 0.45, 0.5]
best_threshold = 0
best_f1 = -1

for t in thresholds:
    y_pred_oot = (y_oot_proba >= t).astype(int)
    precision = precision_score(y_oot, y_pred_oot)
    recall = recall_score(y_oot, y_pred_oot)
    f1 = f1_score(y_oot, y_pred_oot)
    print(f"Threshold: {t}\nPrecision: {precision}\nRecall: {recall}\nF1 Score: {f1}\n-------------------\n")

    if f1 > best_f1:
        best_f1 = f1
        best_threshold = t

#%%
# Best threshold found
print(f"Best threshold: {best_threshold}")

#%%
# New metrics considering the best threshold

# Train
y_pred_train = (y_train_proba >= best_threshold).astype(int)
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

# Test
y_pred_test = (y_test_proba >= best_threshold).astype(int)
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

# OOT
y_pred_oot = (y_oot_proba >= best_threshold).astype(int)
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

#%%
print(f"Train metrics (0.33 threshold): {model_train_metrics}\n")
print(f"Test metrics (0.33 threshold): {model_test_metrics}\n")
print(f"OOT metrics (0.33 threshold): {model_oot_metrics}")

#%%
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