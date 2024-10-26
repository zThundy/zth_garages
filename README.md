# zth_garages

<a href="https://github.com/zThundy/zth_garages/releases/latest">![Version](https://img.shields.io/badge/latest%20version-0.1.1-green.svg "Current Version of Script")</a>

`zth_garages` is a FiveM script designed to manage garages with a high level of customization and reliability. This script allows players to deposit cars on physical spots or in despawn spots, manage impounds, and handle job-specific garages for company vehicles.

Frontend is made using ReactJS and Materail UI for components, images and styling.
You can change whatever you want.

## Framework

- **QBCore**: Done
- **ESX**: In progress
- **VRP**: Planned

## Features

- **Parking Spots**: Players can park their vehicles in designated spots.
- **Despawn Spots**: Vehicles can be stored in despawn spots to free up space.
- **Impound System**: Manage impounded vehicles with a whitelist for specific jobs.
- **Job Garages**: Buy and manage vehicles for your company, with features like onDuty state tracking.
- **Highly Customizable**: Configure parking spots, impound settings, job garages, and more.
- **Bug-Free**: Developed with a focus on stability and performance.
- **Origen_Housing**: WIP Integration with `origen_housing` to create and manage garages

## Installation

1. Download the release from this repository
2. Place the `zth_garages` folder in your FiveM resources directory.
3. Add `start zth_garages` to your `server.cfg`.

## Configuration

The script is highly customizable through various configuration files located in the `zth_garages` directory:

- `config.garages.lua`: Configure parking spots and garage settings.
- `config.houses.lua`: Configure house-related garage settings.
- `config.impounds.lua`: Configure impound settings.
- `config.language.lua`: Localization settings.
- `config.main.lua`: Main configuration file.

## Usage

- **Parking a Vehicle**: Drive to a designated parking spot and press the interaction key to park your vehicle.
- **Impounding a Vehicle**: Vehicles can be impounded based on job roles and other criteria.
- **Managing Job Garages**: Use the in-game menu to buy, sell, and manage company vehicles.
- **Buy Job Vehicles for Grades and Users**: Buy vehicles as boss of a company to both grades or specific players.

## Dependencies

- `gridsystem`
- `oxmysql`

## Developing

If you want to Develop of view the frontend from your Computer, just clone the repository, install all the npm packages with the `npm install` command.

To start the project, if all the npm packages have installed successfully (**Used node version is 20.x LTS**), just execute `npm start`.

If you want to build the project, just run the `npm run build` that will also execute the pre and post build.

## Known issues

- The garages with spawning cars are limited by the FiveM limit of spawnable entities in a server.
- Some optimizations are needed to actually use the cache as intended.

## Contributing

Feel free to submit issues and pull requests to help improve the script.

## License

This project is licensed under the MIT License.