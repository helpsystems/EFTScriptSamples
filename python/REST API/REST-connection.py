import requests

# Authentication
baseURL = "http://192.168.4.14:4450/admin"
user = "a"
password = "QjIlmT4H"
authURL = f"{baseURL}/v1/authentication"
body = {"userName": user, "password": password, "authType": "EFT"}
r1 = requests.post(authURL, json=body)
eftresp1 = r1.json()
# print(r1.status_code)
# print(eftresp1)
authheader ={"Authorization": f"EFTAdminAuthToken {eftresp1['authToken']}"}
# print(authheader)

# Get Server Info
getserverURL = f"{baseURL}/v2/server"
r2 = requests.get(getserverURL, headers=authheader)
eftresp2 = r2.json()
# print(r2.status_code)
print(eftresp2)

#Get Server Metrics
getservermetricsURL = f"{baseURL}/v2/server/metrics"
r3 = requests.get(getservermetricsURL, headers=authheader)
eftresp3 = r3.json()
# print(r3.status_code)
print(eftresp3)