import requests
import json

# Authentication
baseURL = "http://192.168.4.14:4450/admin"
user = "a"
password = "QjIlmT4H"
authURL = f"{baseURL}/v1/authentication"
body = {"userName": user, "password": password, "authType": "EFT"}
r1 = requests.post(authURL, json=body)
eftresp1 = r1.json()
authheader ={"Authorization": f"EFTAdminAuthToken {eftresp1['authToken']}"}

# Get Site ID
sitename = 'My Site'
getsiteURL = f"{baseURL}/v2/sites"
r2 = requests.get(getsiteURL, headers=authheader)
eftresp2 = r2.json()
# print(r2.status_code)
for index, site in enumerate(eftresp2["data"]):
    if site["attributes"]["name"] == sitename:
        print(f'Name: {eftresp2["data"][index]["attributes"]["name"]} Site ID: {eftresp2["data"][index]["id"]}')
        siteid = eftresp2["data"][index]["id"]
        break

#Get User ID
username = 'b'
getusersURL = f"{baseURL}/v2/sites/{siteid}/users"
r3 = requests.get(getusersURL, headers=authheader)
eftresp3 = r3.json()
for index, user in enumerate(eftresp3["data"]):
    if user["attributes"]["loginName"] == username:
        print(f'User ID: {eftresp3["data"][index]["id"]}')
        userid = eftresp3["data"][index]["id"]
        break

#Get Template id
desttemplate = 'Default Settings'
gettemplateURL = f"{baseURL}/v2/sites/{siteid}/users"
r4 = requests.get(gettemplateURL, headers=authheader)
eftresp4 = r4.json()
for index, user in enumerate(eftresp4["data"]):
    if eftresp4["data"][index]["relationships"]["userTemplate"]["data"]["meta"]["name"] == desttemplate:
        print(f'Template ID: {eftresp4["data"][index]["relationships"]["userTemplate"]["data"]["id"]}')
        usertemplateid = eftresp4["data"][index]["relationships"]["userTemplate"]["data"]["id"]
        break

# Data to change, usertemplateid is the destination template
payload = {
    "data": {
        "type": "userTemplate",
        "relationships": {
            "userTemplate": {
               "data": {
                    "id": usertemplateid
                       }
            }
        }
    }
}

#Push the change
patchuserURL = f"{baseURL}/v2/sites/{siteid}/users/{userid}"
r5 = requests.patch(patchuserURL, json.dumps(payload), headers=authheader)
eftresp5 = r5.json()
print(r5.status_code)