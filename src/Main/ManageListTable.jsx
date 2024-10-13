
import Table from "./ManageListTable.module.css";

import { Checkbox } from '@mui/material';
import { pad } from '../lib/utils';
import { T } from '../lib/language';

const testCarData = [];
for (let i = 0; i < 50; i++) {
  testCarData.push({
    id: i,
    name: `Car ${i + 1}`,
    price: (i + 1) * 1000,
  })
}

const testAgenteData = [];
for (let i = 0; i < 20; i++) {
  testAgenteData.push({
    id: i,
    name: `Agente ${i + 1}`
  })
}

const testRangoData = [];
for (let i = 0; i < 20; i++) {
  testRangoData.push({
    id: i,
    name: `Rango ${i + 1}`
  })
}

function ManageListTable() {
  return (
    <div className={Table.table}>
    <div className={Table.FirstRow}>
      <div className={Table.Header}>{T("USERS")}</div>
      <div className={Table.Column}>
        {
          testAgenteData.map((usr) => {
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
          testRangoData.map((car) => {
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
          testCarData.map((car) => {
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