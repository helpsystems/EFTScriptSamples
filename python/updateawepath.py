import sqlite3

db = "C:/Users/jonbr/OneDrive/pyprojects/work.py/update values in sqllite/SiteConfig.33ffaac4-ee37-4fb3-95a2-928ae6333757.db"
awe_path = '\\\\file.core.windows.net\\gsbslogs\\AWE\\'

conn = sqlite3.connect(db)
c = conn.cursor()
c.execute(f"UPDATE AdvancedWorkflow set settings = json_set(AdvancedWorkflow.Settings, '$.LogDir', '{awe_path}')")
conn.commit()
conn.close()