import logging, sys


def get_ht_logger(name=__name__, log_level=logging.INFO):
    # set the logging format
    log_format = "%(asctime)s  :: %(name)s :: %(levelname)s :: %(message)s"

    # Create the root logger using stdout output
    logging.basicConfig(
        stream=sys.stdout,
        format=log_format,
    )

    # Instantiate the logger for each class of using it
    logger = logging.getLogger(name)

    # set the logging level based on the user selection
    if log_level == "INFO":
        logger.setLevel(logging.INFO)
    elif log_level == "ERROR":
        logger.setLevel(logging.ERROR)
    elif log_level == "DEBUG":
        logger.setLevel(logging.DEBUG)
    elif log_level == "WARNING":
        logger.setLevel(logging.WARNING)
    logger.setLevel(log_level)
    return logger
