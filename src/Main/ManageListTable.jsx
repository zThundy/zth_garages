
import "./ManageListTable.css";

import { useEffect, useState } from 'react';

import { Checkbox } from '@mui/material';
import { pad } from '../lib/utils';
import { T } from '../lib/language';

import { api } from '../index';
import { DriveEta, Numbers, Person } from "@mui/icons-material";

function ManageListTable({ manageData }) {
  const [carData, setCarData] = useState(manageData.vehicles || []);
  const [officerData, setOfficerData] = useState(manageData.users || []);
  const [rankData, setRankData] = useState(manageData.levels || []);

  const splitAndTrim = (string, length) => {
    if (!length) length = 30;
    if (string && string.length > length) {
      return string.slice(0, length).trim() + "...";
    }
    return string.trim();
  }

  useEffect(() => {
    api.registerEvent("appliedChanges", () => {
      setCarData((_carData) => {
        setOfficerData((_officerData) => {
          setRankData((_rankData) => {
            // get all checked values and combine themm in one single array
            const filteredCars = _carData.filter((item) => item.selected);
            const filteredOfficers = _officerData.filter((item) => item.selected);
            const filteredRanks = _rankData.filter((item) => item.selected);

            api.post("saveData", {
              vehicles: filteredCars,
              officers: filteredOfficers,
              ranks: filteredRanks
            });
            return _rankData;
          })
          return _officerData;
        })
        return _carData;
      })
    })
  }, []);

  return (
    <div className={"ManageListTable_table"}>
      <div className={"ManageListTable_FirstRow"}>
        <div className={"ManageListTable_FirstRow_Content_Container"}>
          <div className={"ManageListTable_Header"}>
            <div className={"ManageListTable_Header_Content_Container"}>
              <Person />
              {T("USERS")}
            </div>
          </div>
          <div className={"ManageListTable_Column"}>
            {
              officerData.map((usr) => {
                return (
                  <div key={usr.id} className={"ManageListTable_ContentRow"}>
                    <span>{splitAndTrim(usr.name, 30)}</span>
                    <div className={"ManageListTable_ContentRow"}>
                      <div className={"ManageListTable_ColumnButtons"}>
                        <Checkbox
                          disableFocusRipple
                          disableRipple
                          disableTouchRipple
                          onChange={() => {
                            setOfficerData(() => officerData.map((officer) => {
                              if (officer.id === usr.id) {
                                return {
                                  ...officer,
                                  selected: !officer.selected
                                }
                              }
                              return officer;
                            }))
                          }}
                        />
                      </div>
                    </div>
                  </div>
                )
              })
            }
          </div>
        </div>
        <div className={"ManageListTable_FirstRow_Content_Container"}>
          <div className={"ManageListTable_Header"}>
            <div className={"ManageListTable_Header_Content_Container"}>
              <Numbers />
              {T("LEVELS")}
            </div>
          </div>
          <div className={"ManageListTable_Column"}>
            {
              rankData.map((car) => {
                return (
                  <div key={car.id} className={"ManageListTable_ContentRow"}>
                    <span>{splitAndTrim(car.name)}</span>
                    <div className={"ManageListTable_ContentRow"}>
                      <div className={"ManageListTable_ColumnButtons"}>
                        <Checkbox
                          disableFocusRipple
                          disableRipple
                          disableTouchRipple
                          onChange={() => {
                            setRankData(() => rankData.map((rank) => {
                              if (rank.id === car.id) {
                                return {
                                  ...rank,
                                  selected: !rank.selected
                                }
                              }
                              return rank;
                            }))
                          }}
                        />
                      </div>
                    </div>
                  </div>
                )
              })
            }
          </div>
        </div>
      </div>
      <div className={"ManageListTable_SecondRow"}>
        <div className={"ManageListTable_Header"}>
          <div className={"ManageListTable_Header_Content_Container"}>
            <DriveEta />
            {T("VEHICLES")}
          </div>
        </div>
        <div className={"ManageListTable_SecondRow_Column"}>
          {
            carData.map((car) => {
              return (
                <div key={car.id} className={"ManageListTable_ContentRow"}>
                  <span>{splitAndTrim(car.name, 20)}</span>
                  <div className={"ManageListTable_ContentRow"}>
                    ${pad(car.price)}
                    <div className={"ManageListTable_ColumnButtons"}>
                      <Checkbox
                        disableFocusRipple
                        disableRipple
                        disableTouchRipple
                        onChange={() => {
                          setCarData(() => carData.map((vehicle) => {
                            if (vehicle.id === car.id) {
                              return {
                                ...vehicle,
                                selected: !vehicle.selected
                              }
                            }
                            return vehicle;
                          }))
                        }}
                      />
                    </div>
                  </div>
                </div>
              )
            })
          }
        </div>
      </div>
    </div>
  )
}

export default ManageListTable;