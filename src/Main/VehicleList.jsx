
import CSS from './VehicleList.module.css';

import { Button, Tooltip } from '@mui/material';
import { DriveEta, LocalGasStation } from '@mui/icons-material';

import { T } from '../lib/language';

const testCarData = [];
for (let i = 0; i < 50; i++) {
  testCarData.push({
    id: i,
    name: `Car ${i + 1}`,
    // make a plate number for each car with a random number
    plate: `ABC-${Math.floor(Math.random() * 1000)}`,
    // random number between 0 and 100 for fuel, engine, and body levels
    fuelLevel: Math.floor(Math.random() * 100),
    engineLevel: Math.floor(Math.random() * 100),
    bodyLevel: Math.floor(Math.random() * 100),
  })
}

function VehicleList() {
  return (
    <div className={CSS.container}>
      {
        testCarData.map((car) => {
          return (
            <div key={car.id} className={CSS.vehicleRow}>
              <div className={CSS.leftAlign}>
                <span className={CSS.carName}>{car.name}</span>
                <span className={CSS.plate}>{T("PLATE")}: <i>{car.plate}</i></span>
              </div>
              <div className={CSS.rightAlign}>
                <div className={CSS.levels}>
                  <Tooltip
                    title={T("FUEL_LEVEL", car.fuelLevel)}
                    style={{ cursor: "pointer" }}
                    placement="top"
                    arrow
                  >
                    <div className={CSS.fuelLevel}>
                      <div
                        className={CSS.fuelLevelBar}
                        style={{ transform: `translateY(${100 - car.fuelLevel}%)` }}
                      ></div>
                      <LocalGasStation />
                    </div>
                  </Tooltip>
                  <Tooltip
                    title={T("ENGINE_LEVEL", car.engineLevel)}
                    style={{ cursor: "pointer" }}
                    placement="top"
                    arrow
                  >
                    <div className={CSS.engineLevel}>
                      <div
                        className={CSS.engineLevelBar}
                        style={{ transform: `translateY(${100 - car.engineLevel}%)` }}
                      ></div>
                      <img src="/svg/engine.svg" alt="engine" />
                    </div>
                  </Tooltip>
                  <Tooltip
                    title={T("BODY_LEVEL", car.bodyLevel)}
                    style={{ cursor: "pointer" }}
                    placement="top"
                    arrow
                  >
                    <div className={CSS.bodyLevel}>
                      <div
                        className={CSS.bodyLevelBar}
                        style={{ transform: `translateY(${100 - car.bodyLevel}%)` }}
                      ></div>
                      <DriveEta />
                    </div>
                  </Tooltip>
                </div>
                <Tooltip
                  title={T("TAKE_VEHICLE")}
                  placement="top"
                  arrow
                >
                  <Button
                    className={CSS.takeButton}
                    variant="text"
                    disableRipple
                    disableFocusRipple
                    disableTouchRipple
                  >
                    <img src="/svg/wheel.svg" alt="wheel" />
                  </Button>
                </Tooltip>
              </div>
            </div>
          )
        })
      }
    </div>
  )
}

export default VehicleList;