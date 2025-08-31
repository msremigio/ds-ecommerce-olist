from os import path
from argparse import ArgumentParser
from sqlalchemy import create_engine, text, exc
from datetime import datetime

# Parse the reference date for the cohort to be extracted and add it to the features store table
parser = ArgumentParser(prog='generate_features_store_table.py',
                        description='Inserts data from a given dt_ref into a features store table. Create the table if it not exists.')
parser.add_argument('-d', '--date', help='Define the observation window date for the desired cohort. Format: YYYY-MM-DD')
parser.add_argument('-t', '--table', help='Define the name of the table that will be created or where the cohorts data will be inserted')
args = parser.parse_args()

DT_REF = args.date
TB_NAME = args.table

# Define the paths to useful directories
CURRENT_DIR = path.dirname(__file__)
BASE_DIR = path.dirname(CURRENT_DIR)
DATA_DIR = path.join(BASE_DIR, 'data')


# Helper function: Get the SQL query
def import_sql_query(query_path: str) -> str:
    with open(query_path, 'r') as open_file:
        sql_query = open_file.read()
    
    return sql_query

# Helper function: Connect to the database
def connect_db(db: str) -> object:
    engine = create_engine(f"sqlite:///{path.join(DATA_DIR, db)}")
    return engine.connect()

# Get query content
sql = import_sql_query(path.join(CURRENT_DIR, 'create_cohort.sql'))

# Define the parameters inside the query
# cohorts = ['2017-01-01', '2017-02-01', '2017-03-01', '2017-04-01', '2017-05-01',
#            '2017-06-01', '2017-07-01', '2017-08-01', '2017-09-01', '2017-10-01',
#            '2017-11-01', '2017-12-01', '2018-01-01', '2018-02-01', '2018-03-01']
sql_cohort = sql.format(date=DT_REF)

# Connect to DB and execute query
with connect_db('olist.sqlite') as conn:
    try:
        conn.execute(text(f"CREATE TABLE {TB_NAME} AS\n {sql_cohort}"))
        print(f"{datetime.now().replace(microsecond=0)} | CREATE TABLE {TB_NAME} successfully executed")
    except exc.OperationalError as e:
        print(f"{datetime.now().replace(microsecond=0)} | CREATE TABLE failed: {e.orig}")
        try:
            print(f"{datetime.now().replace(microsecond=0)} | Trying to INSERT INTO TABLE {TB_NAME} instead...")
            conn.execute(text(f"DELETE FROM {TB_NAME} WHERE obs_window_start_date = {DT_REF}"))
            conn.execute(text(f"INSERT INTO {TB_NAME}\n {sql_cohort}"))
            print(f"{datetime.now().replace(microsecond=0)} | INSERT INTO TABLE {TB_NAME} successfully executed. Cohort starting at: {DT_REF}")
        except Exception as e:
            print(f"{datetime.now().replace(microsecond=0)} | Execution failed: {e.__cause__}")
        