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

# Get Site ID
sitename = 'test.jbranan.com'
getsiteURL = f"{baseURL}/v2/sites"
r2 = requests.get(getsiteURL, headers=authheader)
eftresp2 = r2.json()
# print(r2.status_code)
for index, site in enumerate(eftresp2["data"]):
    if site["attributes"]["name"] == sitename:
        print(f'Name: {eftresp2["data"][index]["attributes"]["name"]} ID: {eftresp2["data"][index]["id"]}')
        siteid = eftresp2["data"][index]["id"]

print(eftresp2)

getsiteinfoURL = f"{baseURL}/v2/sites/{siteid}/users"
r3 = requests.get(getsiteinfoURL, headers=authheader)
eftresp3 = r3.json()
print(r3.status_code)
# for index, site in enumerate(eftresp2["data"]):
#     if site["attributes"]["name"] == sitename:
#         print(f'Name: {eftresp2["data"][index]["attributes"]["name"]} ID: {eftresp2["data"][index]["id"]}')
#         siteid = eftresp2["data"][index]["id"]
print(eftresp3)