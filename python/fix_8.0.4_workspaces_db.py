import sqlite3

# make sure the slashes are forward
db = "C:/Users/jbranan/Desktop/SiteConfig.94e925b5-6120-4d85-8660-60a74a495361.db.old-broken"
query = """PRAGMA foreign_keys = 0; CREATE TABLE sqlitestudio_temp_table AS SELECT * FROM Participation; DROP TABLE Participation; CREATE TABLE Participation( id BLOB NOT NULL, ParticipationInfo TEXT NOT NULL, InvitationInfo TEXT NOT NULL, Files TEXT NOT NULL, Workspace BLOB, Client BLOB, Secret TEXT NOT NULL, Invitation BLOB, PRIMARY KEY ( id), CONSTRAINT Client_fk FOREIGN KEY ( Client ) REFERENCES Client (id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED, CONSTRAINT Workspace_fk FOREIGN KEY ( Workspace ) REFERENCES Workspace (id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED, CONSTRAINT Invitation_fk FOREIGN KEY ( Invitation ) REFERENCES Invitation (id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED ); INSERT INTO Participation ( id, ParticipationInfo, InvitationInfo, Files, Workspace, Client, Secret, Invitation ) SELECT id, ParticipationInfo, InvitationInfo, Files, Workspace, Client, Secret, Invitation FROM sqlitestudio_temp_table; DROP TABLE sqlitestudio_temp_table; CREATE INDEX Participation_Client_i ON Participation ( "Client" ); CREATE INDEX Participation_Secret_i ON Participation ( "Secret" ); PRAGMA foreign_keys = 1;"""

conn = sqlite3.connect(db)
c = conn.cursor()
c.executescript(query)
conn.commit()
conn.close()