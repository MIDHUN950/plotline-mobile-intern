from sqlite3 import paramstyle
import requests
URL = "https://opencv-server.herokuapp.com/opencv"
files = {
    "file": open('test.jpg','rb'),
}
parms = {
    "id": "gfgcdrxex576e4as"
}
r = requests.post(url = URL,files=files,params=parms)
print(r.text)
print(r.status_code)
print(r.json)
print(r.content)