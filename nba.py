import requests
from datetime import date
from datetime import timedelta
from nba_api.stats.static import players

from nba_api.stats.endpoints import commonplayerinfo

# Today's Date
today = date.today().isoformat()
tomorrowDelta = timedelta(hours=24)
tomorrow = (date.today() + tomorrowDelta).isoformat()

# Basic Request
player_info = commonplayerinfo.CommonPlayerInfo(player_id=2544)


from nba_api.stats.static import teams
from nba_api.stats.endpoints import teamgamelog

teams = teams.get_teams()
teams_id = [[str(t['id']), t['full_name']] for t in teams]


example = teamgamelog.TeamGameLog(teams_id[0][0]).get_dict()

response = requests.get("https://data.nba.com/data/10s/v2015/json/mobile_teams/nba/2021/league/00_full_schedule.json")


#trying to work through the api call to understand how the data is stored
#I understand that there are a set of 7 dictionaries with information -> len(response.json()['lscd'])

with open("test.txt", "a") as o:
    o.write(str(response.json()['lscd'][3]))
    o.close()
    
#using a test text file, I write each set separately to read each section (printing in python console causes unresponsiveness)
# ['lscd'][0] -> January, ['lscd'][1] -> February, ['lscd'][2] -> March... [3] -> April, [4] -> October, [5] -> November, [6] -> December

#the data is structured in months. in each month, there is a list of all games, under the dictionary key 'g'
#so, we can retrieve the details of a game as follows: 
example_game = (response.json()['lscd'][3]['mscd']['g'][2])

