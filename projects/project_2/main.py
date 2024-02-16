#from shared_libs.my_conn.src.my_conn import my_conn
from shared_libs.my_logger.src.my_logger import get_ht_logger

if __name__ == "__main__":

    my_logger = get_ht_logger(__name__)
    my_logger.info("Your a project inside a menorepo.")
