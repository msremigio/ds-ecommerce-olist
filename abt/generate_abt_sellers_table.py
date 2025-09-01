from os import path
from argparse import ArgumentParser
from sqlalchemy import create_engine, text, exc
import logging
from sys import stdout

# Configure logging pattern
logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.DEBUG)
logger.propagate = False

console = logging.StreamHandler(stdout)
console.setLevel(logging.INFO)

formatter = logging.Formatter("%(asctime)s [%(levelname)s] %(filename)s:%(lineno)d - %(message)s", datefmt="%Y-%m-%d %H:%M:%S")
console.setFormatter(formatter)

logger.addHandler(console)

# Parse the reference date for the cohort to be extracted and add it to the features store table
parser = ArgumentParser(prog='generate_abt_sellers_table.py',
                        description='Generates an Analytical Base Table (ABT) from the features store table.')
parser.add_argument('-t', '--table', help='Define the name of the table that will be created as ABT')
args = parser.parse_args()

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

    return engine

# Get query content
sql_abt = import_sql_query(path.join(CURRENT_DIR, 'create_abt.sql'))

# mature_cohorts = ['2017-01-01', '2017-02-01', '2017-03-01', '2017-04-01', '2017-05-01',
#                   '2017-06-01', '2017-07-01', '2017-08-01', '2017-09-01', '2017-10-01',
#                   '2017-11-01', '2017-12-01']

# Connect to DB and execute query
engine = connect_db('olist.sqlite')

with engine.begin() as conn:
    try:
        logger.info(f"Starting ABT {TB_NAME} creation attempt")
        conn.execute(text(f"CREATE TABLE {TB_NAME} AS\n {sql_abt}"))
        logger.info(f"CREATE TABLE {TB_NAME} successfully executed")
    except exc.OperationalError as e:
        logger.warning(f"CREATE TABLE failed: {e.orig}")
        try:
            logger.info(f"Trying to DROP TABLE {TB_NAME} before a new recreation attempt...")
            conn.execute(text(f"DROP TABLE {TB_NAME};"))
            logger.info(f"TABLE {TB_NAME} successfully dropped...")
            logger.info(f"Attempting to CREATE TABLE {TB_NAME}")
            conn.execute(text(f"CREATE TABLE {TB_NAME} AS\n {sql_abt}"))
            logger.info(f"CREATE TABLE {TB_NAME} successfully executed")
        except Exception as e:
            logger.exception(f"Execution failed: {e.__cause__}")
            conn.rollback()
        