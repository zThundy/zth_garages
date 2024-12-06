
import './VehicleList.css';

import { useState } from 'react';

import { Button, TextField, Tooltip } from '@mui/material';
import { DriveEta, LocalGasStation, AttachMoney } from '@mui/icons-material';

import { T } from '../../lib/language';
import { api, loadStaticSvg } from '../../index';
import { pad } from '../../lib/utils';

function VehicleList({ vehicles }) {
  const [carData, _] = useState(vehicles);

  return (
    <div className={"VehicleList_container"}>
      <div className={"VehicleList_searchBoxContainer"}>
        <TextField
          className={"VehicleList_searchBox"}
          type="text"
          fullWidth
          placeholder={T("SEARCH_VEHICLE")}
          onChange={(e) => {
            const value = e.target.value.toLowerCase();
            const filteredData = vehicles.filter((car) => {
              return car.label.toLowerCase().includes(value) || car.plate.toLowerCase().includes(value);
            });
            _([...filteredData]);
          }}
        />
      </div>
      <div className={"VehicleList_vehicleRows"}>
        {
          carData.map((car) => {
            return (
              <div key={car.id} className={"VehicleList_vehicleRow"}>
                <div className={"VehicleList_leftAlign"}>
                  <span className={"VehicleList_carName"}>{car.label}</span>
                  <span className={"VehicleList_plate"}>{T("PLATE")}: <i>{car.plate}</i></span>
                  {car.assignedTo ? <span className={"VehicleList_plate"}>{T("ASSIGNED_TO")}: <i>{car.assignedTo}</i></span> : null}
                  {car.isImpounded ? <span className={"VehicleList_impoundText"}>{T("IMPOUND_PAYAMOUNT", pad(car.impoundAmount))}</span> : null}
                </div>
                <div className={"VehicleList_rightAlign"}>
                  <div className={"VehicleList_levels"}>
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
                  {
                    car.isImpounded ?
                      <Tooltip
                        title={T("PAY_IMPOUND_FEE")}
                        placement="top"
                        arrow
                      >
                        <Button
                          className={"VehicleList_takeButton"}
                          style={{
                            backgroundColor: "var(--mui-palette-primary-dark)",
                          }}
                          variant="text"
                          disableRipple
                          disableFocusRipple
                          disableTouchRipple
                          onClick={() => {
                            api.callEvent("payFee", { car });
                          }}
                        >
                          <AttachMoney />
                        </Button>
                      </Tooltip>
                      :
                      <Tooltip
                        title={T("TAKE_VEHICLE")}
                        placement="top"
                        arrow
                      >
                        <Button
                          className={"VehicleList_takeButton"}
                          style={{
                            backgroundColor: "var(--mui-palette-primary-main)",
                          }}
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
                  }
                </div>
              </div>
            )
          })
        }
      </div>
    </div>
  )
}

export default VehicleList;