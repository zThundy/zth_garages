
import CSS from './BuyParkingScreen.module.css'

import { Button } from '@mui/material';

import { pad } from '../lib/utils';
import { T } from '../lib/language';
import config from '../lib/config';

function BuyParkingScreen({ parkingData }) {
  const computeText = () => {
    const html = []
    for (let i in config.buyMenu) {
      if (i.includes("paragraph"))
        html.push(
          <span>
            {config.buyMenu[i]}
          </span>
        )
      if (i.includes("list")) {
        html.push(
          <ul>
            <li>{config.buyMenu[i]}</li>
          </ul>
        )
      }
    }
    return html
  }

  return (
    <div className={CSS.container}>
      <div className={CSS.infoContainer}>
        <div className={CSS.label}>
          {T("NAME")}: <b>{parkingData.name}</b>
        </div>
        <div className={CSS.label}>
          {T("SPOTS")}: <b>{parkingData.spots}</b>
        </div>
        <div className={CSS.label}>
          {T("PRICE")}: <b>${pad(parkingData.managementPrice)}</b>
        </div>
      </div>

      <div className={CSS.divider}><span></span></div>

      <div className={CSS.textContainer}>
        {computeText()}
      </div>

      <Button
        variant="contained"
        color="primary"
        className={CSS.buyButton}
      >{T("BUY_FOR", pad(parkingData.managementPrice))}</Button>
    </div>
  )
}

export default BuyParkingScreen