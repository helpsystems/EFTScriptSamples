import sqlite3
import logging
import logging.handlers
# make sure the slashes are forward
# create logger
filename = "C:/Users/jbranan/Desktop/temp/a/log.txt"

logger = logging.getLogger('sqllite')
logger.setLevel(logging.DEBUG)

# create console handler and set level to debug
ch = logging.handlers.RotatingFileHandler(filename, mode='a', maxBytes=20971520, backupCount=5, encoding=None, delay=False)
ch.setLevel(logging.INFO)

# create formatter
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# add formatter to ch
ch.setFormatter(formatter)

# add ch to logger
logger.addHandler(ch)



db = "C:/Users/jbranan/Desktop/temp/a/SiteConfig.e05dd013-0099-47c5-a727-dc0285e74204.db"
query = r"""
SELECT count(PathLowered)
FROM FSEntry
WHERE PathLowered LIKE '%az%';
"""

conn = sqlite3.connect(db)
c = conn.cursor()
c.execute(query)
data = c.fetchone()[0]
logger.info(f'{data} %az%')
conn.close()