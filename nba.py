import requests
import calendar
from itertools import groupby
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
year = date.today().year
calendar = calendar.Calendar()

# Basic Request
player_info = commonplayerinfo.CommonPlayerInfo(player_id=2544)

# The main API call
response = requests.get("https://data.nba.com/data/10s/v2015/json/mobile_teams/nba/2021/league/00_full_schedule.json")

# All teams
teams = teams.get_teams()

# A dictionary containing teams and their respective IDs
teamsId = {}
for t in teams:
    teamsId[str(t['id'])] = t['full_name']
    
# A structured dictionary with teams and their abbreviations
teams_abbrev = {}
for team in teams:
    teams_abbrev[team['abbreviation']] = team['full_name']

# Retrieve the current active players
p = requests.get("http://data.nba.net/10s/prod/v1/2021/players.json")
players = p.json()['league']['standard']

# A dictionary containing active players and the team the last played for
activePlayers = {}

# A dictionary containing teams and the players that play(ed) for them this year
rosters = {}

for player in players:
    if len(player['teams']) > 0:
        if player['teams'][-1]['seasonEnd'] == '2021':
            link = activePlayers[player['firstName'] + ' ' + player['lastName']] = player['teams'][-1]['teamId']
            #now add the player to their team's roster
            if teamsId[link] in rosters:
                rosters[teamsId[link]].append(player['firstName'] + ' ' + player['lastName'])
            else:
                rosters[teamsId[link]] = []
    else:
        pass

# trying to work through the api call to understand how the data is stored
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

def gamesDayOf(day):
    """A pretty print representation of the NBA games scheduled for inputted day"""
    dateobject = date.fromisoformat(day) #turn the inputted date into a datetime object
    month = months[dateobject.month]

    if month not in season_months:
        return 'No Games On This Day'
    
    games = []
    index = season_months.index(month) 

    #so for every game in this month, if the game date matches todays date, add it to the list of today's games
    for game in response.json()['lscd'][index]['mscd']['g']:        
        if game['gdte'] == dateobject.isoformat():
            games.append(game['gcode'])

    return games

def teamsThatPlayOn(day):
    teams = []
    for game in gamesDayOf(day):
        home = game[9:12]
        away = game[12:]
        teams.append(teams_abbrev[home])
        teams.append(teams_abbrev[away])

    return teams
    

def scheduleDayOf(day):
    """A pretty print representation of the NBA games scheduled for the inputted date"""
    games = gamesDayOf(day)
    sched = []
    for game in games:
        home = game[9:12]
        away = game[12:]
        sched.append(teams_abbrev[home] + ' at ' + teams_abbrev[away])

    return sched

def backToBackNext(day):
    """Return a list of teams that play in a back-to-back on this day and the next."""
    same_day = date.fromisoformat(day)
    next_day = same_day + tomorrowDelta
    
    b2b = []
    
    for team in teamsThatPlayOn(day):
        if team in teamsThatPlayOn(date.isoformat(next_day)):
            b2b.append(team)
            
    return b2b

def backToBackPrevious(day):
    """Return a list of teams that play in a back-to-back on this day and the next."""
    same_day = date.fromisoformat(day)
    previous_day = same_day + tomorrowDelta
    
    b2b = []
    
    for team in teamsThatPlayOn(day):
        if team in teamsThatPlayOn(date.isoformat(previous_day)):
            b2b.append(team)
            
    return b2b

def backToBackDayOf(day):
    same_day = date.fromisoformat(day)
    next_day = same_day + tomorrowDelta
    previous_day = same_day - tomorrowDelta

    dayAndNext = 'The teams that play on this date and the next are: '
    dayAndBefore = 'The teams that play on this date and the previous are: '

    for team in backToBackNext(day):
        dayAndNext += team + ', '

    for team in backToBackPrevious(day):
        dayAndBefore += team + ', '


    return dayAndBefore[:-2] + '. ' + dayAndNext[:-2]

def gamesPerTeamWeek(week):
    weeks = (w for month in range(1, 13) for w in calendar.monthdatescalendar(year, month))
    weeks = [k for k, _ in groupby(weeks)]
    #this_week = date.today().isocalendar()[1]
    gamesPerTeam = {}
    
    for date in weeks[week]:
        teams = teamsThatPlayOn(date.isoformat())
        for team in teams:
            if team in gamesPerTeam:
                gamesPerTeam[team] += 1
            else:
                gamesPerTeam[team] = 1

    return gamesPerTeam 
        
def fourGameWeek(week):
    breakdown = gamesPerTeamWeek(week)

    teamsThatPlayFourTimes = []
    for team in breakdown:
        if breakdown[team] == 4:
            teamsThatPlayFourTimes.append(team)

    return teamsThatPlayFourTimes
    
"""
d = today.date()
ic = d.isocalendar()
ic.week = 2
He was a POI
"""
