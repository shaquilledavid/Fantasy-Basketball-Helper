import requests

url = "https://api-nba-v1.p.rapidapi.com/seasons"

headers = {
	"X-RapidAPI-Key": "b457502fd1msh99a32885cd78e9bp1ccaa7jsn62dfb8f041d8",
	"X-RapidAPI-Host": "api-nba-v1.p.rapidapi.com"
}

response = requests.get(url, headers=headers)

print(response.json())
