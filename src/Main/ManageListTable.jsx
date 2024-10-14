
import Table from "./ManageListTable.module.css";

import { useState } from 'react';

import { Checkbox } from '@mui/material';
import { pad } from '../lib/utils';
import { T } from '../lib/language';

function ManageListTable() {
  const [carData, setCarData] = useState([]);
  const [officerData, setOfficerData] = useState([]);
  const [rankData, setRankData] = useState([]);

  return (
    <div className={Table.table}>
    <div className={Table.FirstRow}>
      <div className={Table.Header}>{T("USERS")}</div>
      <div className={Table.Column}>
        {
          officerData.map((usr) => {
            return (
              <div key={usr.id} className={Table.ContentRow}>
                <span>{usr.name}</span>
                <div className={Table.ContentRow}>
                  <div className={Table.ColumnButtons}>
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
      <div className={Table.Header}>{T("LEVELS")}</div>
      <div className={Table.Column}>
        {
          rankData.map((car) => {
            return (
              <div key={car.id} className={Table.ContentRow}>
                <span>{car.name}</span>
                <div className={Table.ContentRow}>
                  <div className={Table.ColumnButtons}>
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
    <div className={Table.SecondRow}>
      <div className={Table.Column}>
        {
          carData.map((car) => {
            return (
              <div key={car.id} className={Table.ContentRow}>
                <span>{car.name}</span>
                <div className={Table.ContentRow}>
                  ${pad(car.price)}
                  <div className={Table.ColumnButtons}>
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