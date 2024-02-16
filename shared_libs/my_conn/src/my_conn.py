class my_conn:
    def __init__(self, conn):
        self.conn = conn

    def __enter__(self):
        return self.conn

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.conn.close()
        return True

    def test_connection(self):
        print("We are connected to the database.")
        return self.conn
