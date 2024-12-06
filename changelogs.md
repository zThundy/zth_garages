## 0.1.0

First release of `zth_garages`

- Initial publish
- Lua section
- Github workflow
- Changelogs

# Features

- Parking spots with spawning cars
- Parking spots with despawning of cars
- Impounds with whitelist for jobs
- Auto impound of cars
- Secure communication between client and server with scrambling id tunneling

## 0.1.1

# Changelogs

- Fixes to impound system
- Added default impund depotprice value
- Fixed bug on opening manage NUI
- Fixed date conver bug (maybe?)
- Fixed auto impound of vehicles with a parking spot
- Fixed bug on Job garages that would prevend deposit and take of vehicles with a shorter plate
- Fixed bug on Job garages where it would register all markers anyway, even if the job wasn't the right one
- Fixed issue where garages would refresh even if no change to playerdata happened
- Fixed some styling
- Fixed issue on search in impounds
- Fixed issue when buying new parking spots
- Fixed issue where timeouts on nui callbacks would cause some unintended waits
- Rewrite of "INIT" logic in client side, to not fuck up the server

# New features

- You can add parking spots to garages using the /add command and providing the garage_id `/add garage_1`
- Added buttons on manage screen
- Added logic to manually revoke parking spots
- Added logic to manually add a day to the expiration date of a parking spot
- Added some logic to sell and buy garages
- Origen housing integration
- Added camera to parking spots when buying
- Job Garages will now also follow the onDuty state. Configurable.
- You can now configure more than one deposit spots for all Deposit type garages (NOT PARKING SPOTS OBV)
- If QB then take label from Shared
- Added search box in vehicle list
- Added vehicle type to job garages

## 0.1.2

# Changelogs

- Fixed some issues with debug functions
- Fixed issue where the script would error if there was no spawnpoint configured for a garage
- Fixed issue where garages would not update when switching job
- Removed a useless check on account balance logic

# New features

- Changed some configurations
- Added some debugging features
- Added commands logic to register commands in the script

## 0.1.3