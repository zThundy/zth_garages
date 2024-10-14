
import CSS from './VehicleList.module.css';

import { useState } from 'react';

import { Button, Tooltip } from '@mui/material';
import { DriveEta, LocalGasStation } from '@mui/icons-material';

import { T } from '../lib/language';

function VehicleList() {
  const [carData, setCarData] = useState([]);

  return (
    <div className={CSS.container}>
      {
        carData.map((car) => {
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
                      <img src="/html/svg/engine.svg" alt="engine" />
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
                    <img src="/html/svg/wheel.svg" alt="wheel" />
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