
import './BuyParkingScreen.css'

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
          <span key={i}>
            {config.buyMenu[i]}
          </span>
        )
      if (i.includes("list")) {
        html.push(
          <ul key={i}>
            <li>{config.buyMenu[i]}</li>
          </ul>
        )
      }
    }
    return html
  }

  return (
    <div className={"BuyParkingScreen_container"}>
      <div className={"BuyParkingScreen_infoContainer"}>
        <div className={"BuyParkingScreen_label"}>
          {T("NAME")}: <b>{parkingData.name}</b>
        </div>
        <div className={"BuyParkingScreen_label"}>
          {T("SPOTS")}: <b>{parkingData.spots}</b>
        </div>
        <div className={"BuyParkingScreen_label"}>
          {T("PRICE")}: <b>${pad(parkingData.managementPrice)}</b>
        </div>
      </div>

      <div className={"BuyParkingScreen_divider"}><span></span></div>

      <div className={"BuyParkingScreen_textContainer"}>
        {computeText()}
      </div>

      <Button
        variant="contained"
        color="primary"
        className={"BuyParkingScreen_buyButton"}
      >{T("BUY_FOR", pad(parkingData.managementPrice))}</Button>
    </div>
  )
}

export default BuyParkingScreen