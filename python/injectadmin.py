import sqlite3

# make sure the slashes are forward
db = "//192.168.2.21/Vault/testing stuff/ServerConfig.db"
query = """
INSERT OR REPLACE INTO "main"."Admin" ("id", "Name", "NameLowered", "Type", "LastActiveTime", "PasswordHash", "PasswordIsTemporary", "PasswordChangedTime", "PasswordHistory", "UnlockTime", "InvalidLoginAttempts", "Permissions") VALUES (X'b76a1d7bc3ad5ac4863606ce71ba3af3', 'Local computer\\Administrators', 'local computer\\administrators', '2', '1607536951', '', '1', '1607536951', '[]', '0', '[]', '{
  "ACLs": [],
  "Level": "Server",
  "ManageCom": true,
  "ManagePersonalData": true,
  "ManageReporting": true,
  "RestAccess": true,
  "RestAdminRole": "server_full_access",
  "SettingsTemplates": []
}');"""

conn = sqlite3.connect(db)
c = conn.cursor()
c.execute(query)
conn.commit()
conn.close()