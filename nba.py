import requests
from datetime import date
from datetime import timedelta
from nba_api.stats.static import players
from nba_api.stats.static import teams
from nba_api.stats.endpoints import teamgamelog
from nba_api.stats.endpoints import commonplayerinfo

# Today's Date... documentation: https://docs.python.org/3/library/datetime.html
today = date.today().isoformat()
tomorrowDelta = timedelta(hours=24)
tomorrow = (date.today() + tomorrowDelta).isoformat()

# Basic Request
player_info = commonplayerinfo.CommonPlayerInfo(player_id=2544)

# All teams
teams = teams.get_teams()

# A structured list with teams and their respective ids
teams_id = [[str(t['id']), t['full_name']] for t in teams]

# A structured dictionary with teams and their abbreviations
teams_abbrev = {}
for team in teams:
    teams_abbrev[team['abbreviation']] = team['full_name']

# The main API call
response = requests.get("https://data.nba.com/data/10s/v2015/json/mobile_teams/nba/2021/league/00_full_schedule.json")

#trying to work through the api call to understand how the data is stored
#I understand that there are a set of 7 dictionaries with information -> len(response.json()['lscd'])

### TESTING PURPOSES ONLY ###
#with open("test.txt", "a") as o:
#    o.write(str(response.json()['lscd'][3]))
#    o.close()
    
#using a test text file, I write each set separately to read each section (printing in python console causes unresponsiveness)
# ['lscd'][0] -> January, ['lscd'][1] -> February, ['lscd'][2] -> March... [3] -> April, [4] -> October, [5] -> November, [6] -> December

#the data is structured in months. in each month, there is a list of all games, under the dictionary key 'g'
#so, we can retrieve the details of a game as follows: 
example_game = (response.json()['lscd'][3]['mscd']['g'][2])

#Number to month mapping
months = {1: 'January', 2: 'February', 3: 'March', 4: 'April', 5: 'May', 6: 'June', 7: 'July', 8: 'August', 9: 'September',
          10: 'October', 11: 'November', 12: 'December'}

season_months = []
for i in response.json()['lscd']:
    season_months.append(i['mscd']['mon'])
        
def gamesToday():
    today = date.today()
    month = months[today.month]

    if month not in season_months:
        return 'No Games Today'

    games = []
    
    #new index variable to keep track of the season months, as the data comes with January mapped to 1, Feb to 2, ... December to 6
    index = season_months.index(month) 

    #so for every game in this month, if the game date matches todays date, add it to the list of today's games
    for game in response.json()['lscd'][index]['mscd']['g']:        
        if game['gdte'] == today.isoformat():
            games.append(game['gcode'])

    return games

def scheduleToday():
    """A pretty print representation of the NBA games scheduled for today"""
    games = gamesToday()
    sched = []
    for game in games:
        home = game[9:12]
        away = game[12:]
        sched.append(teams_abbrev[home] + ' at ' + teams_abbrev[away])

    return sched
        
def gamesTomorrow():
    tomorrow = date.today() + tomorrowDelta
    month = months[tomorrow.month]

    if month not in season_months:
        return 'No Games Today'

    games = []
    index = season_months.index(month)
    for game in response.json()['lscd'][index]['mscd']['g']:        
        if game['gdte'] == tomorrow.isoformat():
            games.append(game['gcode'])

    return games

def scheduleTomorrow():
    """A pretty print representation of the NBA games scheduled for tomorrow"""
    games = gamesTomorrow()
    sched = []
    for game in games:
        home = game[9:12]
        away = game[12:]
        sched.append(teams_abbrev[home] + ' at ' + teams_abbrev[away])

    return sched

def teamsThatPlayToday():
    """Return a list of teams that play today"""
    teams = []
    for game in gamesToday():
        home = game[9:12]
        away = game[12:]
        teams.append(teams_abbrev[home])
        teams.append(teams_abbrev[away])

    return teams

def teamsThatPlayTomorrow():
    """Return a list of teams that play tomorrow"""
    teams = []
    for game in gamesTomorrow():
        home = game[9:12]
        away = game[12:]
        teams.append(teams_abbrev[home])
        teams.append(teams_abbrev[away])

    return teams
    
def backToBack():
    """Return a list of teams that play in a back-to-back. This means they have a game today and tomorrow."""
    b2b = []
    for team in teamsThatPlayToday():
        if team in teamsThatPlayTomorrow():
            b2b.append(team)

    return b2b
