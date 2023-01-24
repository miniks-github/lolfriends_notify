# AWESOMEWM widget: lolfriends_notify

This small widget allows you to get notified via AwesomeWM notifications on the
desktop when any of your given friends in the list finished one of their games.

## Config

1. Clone Project
2. Move to .config/awesome
3. Get yourself an API key from Riot Games
4. Create secrets file containing:
```lua
M.api_key = ""
M.friendlist = {}
```
5. Make sure to be under 100 request per 2 min (each summoner requires a
   request)

## Possible improvements

- feature: track win/lose after games
- feature: show emoji for win/loss streak
- feature: toggle button in UI to disable notifications
- feature: notification when friends enter a match
- fix issue: reappearing messages after game has finished
