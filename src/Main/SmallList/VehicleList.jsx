
import './VehicleList.css';

import { useState } from 'react';

import { Button, Tooltip } from '@mui/material';
import { DriveEta, LocalGasStation, AttachMoney } from '@mui/icons-material';

import { T } from '../../lib/language';
import { api, loadStaticSvg } from '../../index';

function VehicleList({ vehicles }) {
  const [carData, _] = useState(vehicles);

  return (
    <div className={"VehicleList_container"}>
      {
        carData.map((car) => {
          return (
            <div key={car.id} className={"VehicleList_vehicleRow"}>
              <div className={"VehicleList_leftAlign"}>
                <span className={"VehicleList_carName"}>{car.name}</span>
                <span className={"VehicleList_plate"}>{T("PLATE")}: <i>{car.plate}</i></span>
              </div>
              <div className={"VehicleList_rightAlign"}>
                <div className={"VehicleList_levels"}>
                  {
                    car.isImpounded ?
                      <Tooltip
                        title={T("IMPOUND_PAYAMOUNT", car.impoundAmount)}
                        style={{ cursor: "pointer" }}
                        placement="top"
                        arrow
                      >
                        <div className={"VehicleList_impound"}>
                          <div
                            className={"VehicleList_impoundBar"}
                            style={{ transform: `translateY(${0}%)` }}
                          ></div>
                          <AttachMoney />
                        </div>
                      </Tooltip>
                      : null
                  }
                  <Tooltip
                    title={T("FUEL_LEVEL", car.fuelLevel)}
                    style={{ cursor: "pointer" }}
                    placement="top"
                    arrow
                  >
                    <div className={"VehicleList_fuelLevel"}>
                      <div
                        className={"VehicleList_fuelLevelBar"}
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
                    <div className={"VehicleList_engineLevel"}>
                      <div
                        className={"VehicleList_engineLevelBar"}
                        style={{ transform: `translateY(${100 - car.engineLevel}%)` }}
                      ></div>
                      <img
                        src={`${loadStaticSvg("engine")}`}
                        alt="engine"
                      />
                    </div>
                  </Tooltip>
                  <Tooltip
                    title={T("BODY_LEVEL", car.bodyLevel)}
                    style={{ cursor: "pointer" }}
                    placement="top"
                    arrow
                  >
                    <div className={"VehicleList_bodyLevel"}>
                      <div
                        className={"VehicleList_bodyLevelBar"}
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
                    className={"VehicleList_takeButton"}
                    variant="text"
                    disableRipple
                    disableFocusRipple
                    disableTouchRipple
                    onClick={() => {
                      api.callEvent("take", { car });
                    }}
                  >
                    <img
                      src={`${loadStaticSvg("wheel")}`}
                      alt="wheel"
                    />
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