
import "./ManageListTable.css";

import { useState } from 'react';

import { Checkbox } from '@mui/material';
import { pad } from '../lib/utils';
import { T } from '../lib/language';

function ManageListTable() {
  const [carData, setCarData] = useState([]);
  const [officerData, setOfficerData] = useState([]);
  const [rankData, setRankData] = useState([]);

  return (
    <div className={"ManageListTable_table"}>
    <div className={"ManageListTable_FirstRow"}>
      <div className={"ManageListTable_Header"}>{T("USERS")}</div>
      <div className={"ManageListTable_Column"}>
        {
          officerData.map((usr) => {
            return (
              <div key={usr.id} className={"ManageListTable_ContentRow"}>
                <span>{usr.name}</span>
                <div className={"ManageListTable_ContentRow"}>
                  <div className={"ManageListTable_ColumnButtons"}>
                    <Checkbox
                      disableFocusRipple
                      disableRipple
                      disableTouchRipple
                    />
                  </div>
                </div>
              </div>
            )
          })
        }
      </div>
      <div className={"ManageListTable_Header"}>{T("LEVELS")}</div>
      <div className={"ManageListTable_Column"}>
        {
          rankData.map((car) => {
            return (
              <div key={car.id} className={"ManageListTable_ContentRow"}>
                <span>{car.name}</span>
                <div className={"ManageListTable_ContentRow"}>
                  <div className={"ManageListTable_ColumnButtons"}>
                    <Checkbox
                      disableFocusRipple
                      disableRipple
                      disableTouchRipple
                    />
                  </div>
                </div>
              </div>
            )
          })
        }
      </div>
    </div>
    <div className={"ManageListTable_SecondRow"}>
      <div className={"ManageListTable_SecondRow_Column"}>
        {
          carData.map((car) => {
            return (
              <div key={car.id} className={"ManageListTable_ContentRow"}>
                <span>{car.name}</span>
                <div className={"ManageListTable_ContentRow"}>
                  ${pad(car.price)}
                  <div className={"ManageListTable_ColumnButtons"}>
                    <Checkbox
                      disableFocusRipple
                      disableRipple
                      disableTouchRipple
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