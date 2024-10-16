
import { Button } from '@mui/material';
import './BuySpotList.css';

import { useState } from 'react';
import { ArrowBack, ArrowForward } from '@mui/icons-material';

import { pad } from '../lib/utils';
import { T } from '../lib/language';
import { api } from '../index';

function BuySpotList({ parkingData }) {
  const [pData, _] = useState(parkingData);
  const [currentSpot, setCurrentSpot] = useState(1);
  const [showingPrice, setShowingPrice] = useState(0);

  const showPrice = (days) => {
    if (days === 0) return setShowingPrice(0);
    if (pData.occupied.includes(currentSpot.toString())) return setShowingPrice(-1);
    setShowingPrice(pData.price * days);
  }

  const buySpot = (days) => {
    api.callEvent("buySpot", { parkingId: pData.id, spotId: currentSpot, days: days });
  }

  const leftArrowClick = () => {
    if (currentSpot === 1) return;
    setCurrentSpot(currentSpot - 1);
  }

  const rightArrowClick = () => {
    if (currentSpot === pData.spots) return;
    setCurrentSpot(currentSpot + 1);
  }

  return (
    <div className={"BuySpotList_container"}>
      <div className={"BuySpotList_infoContainer"}>
        <div className={"BuySpotList_info"}>
          <div className={"BuySpotList_parkingName"}>{pData.name}</div>
          <div className={"BuySpotList_spots"}>
            <div className={"BuySpotList_spotsTotal"}>
              <span className={"BuySpotList_spotsTotal_label"}>{T("TOTAL")}:</span>
              <span className={"BuySpotList_spotsTotal_red"}>{pData.spots}</span>
            </div>
            <div className={"BuySpotList_spotsOccupied"}>
              <span className={"BuySpotList_spotsOccupied_label"}>{T("TAKEN")}:</span>
              <span className={"BuySpotList_spotsOccupied_red"}>{parseInt(pData.spots) >= 100 ? parkingData.occupied.length.toString().padStart(3, "0") : parkingData.occupied.length}</span>
            </div>
          </div>
        </div>
        <div className={"BuySpotList_price"}>
          <div className={"BuySpotList_pricePeriod"}>{T("PRICE_PER_DAY")}:</div>
          <div className={"BuySpotList_priceValue"}>${pad(pData.price)}</div>
        </div>
      </div>

      <div className={"BuySpotList_divider"}><span></span></div>

      <div className={"BuySpotList_buyContainer"}>
        <div className={"BuySpotList_buyButtons"}>
          { /* BUTTONS ARE SINGLE CAUSE I DON'T FUCKING CARE :))))) */ }
          <Button
            variant="contained"
            color="primary"
            className={"BuySpotList_buyButton"}
            onMouseEnter={() => showPrice(1)}
            onMouseLeave={() => showPrice(0)}
            onClick={() => buySpot(1)}
          >
            {T("DAY", 1)}
          </Button>
          <Button
            variant="contained"
            color="primary"
            className={"BuySpotList_buyButton"}
            onMouseEnter={() => showPrice(3)}
            onMouseLeave={() => showPrice(0)}
            onClick={() => buySpot(3)}
          >
            {T("DAYS", 3)}
          </Button>
          <Button
            variant="contained"
            color="primary"
            className={"BuySpotList_buyButton"}
            onMouseEnter={() => showPrice(5)}
            onMouseLeave={() => showPrice(0)}
            onClick={() => buySpot(5)}
          >
            {T("DAYS", 5)}
          </Button>
          <Button
            variant="contained"
            color="primary"
            className={"BuySpotList_buyButton"}
            onMouseEnter={() => showPrice(7)}
            onMouseLeave={() => showPrice(0)}
            onClick={() => buySpot(7)}
          >
            {T("DAYS", 7)}
          </Button>
          <Button
            variant="contained"
            color="primary"
            className={"BuySpotList_buyButton"}
            onMouseEnter={() => showPrice(14)}
            onMouseLeave={() => showPrice(0)}
            onClick={() => buySpot(14)}
          >
            {T("DAYS", 14)}
          </Button>
          <Button
            variant="contained"
            color="primary"
            className={"BuySpotList_buyButton"}
            onMouseEnter={() => showPrice(21)}
            onMouseLeave={() => showPrice(0)}
            onClick={() => buySpot(21)}
          >
            {T("DAYS", 21)}
          </Button>
          <Button
            variant="contained"
            color="primary"
            className={"BuySpotList_buyButton"}
            onMouseEnter={() => showPrice(300)}
            onMouseLeave={() => showPrice(0)}
            onClick={() => buySpot(300)} // ????? WHY THE FUCK??? DON'T CARE
          >
            {T("PERMANENT")}
          </Button>
        </div>
      </div>

      <div className={"BuySpotList_divider"}><span></span></div>

      <div className={"BuySpotList_scrollSpots"}>
        <Button
          variant="contained"
          color="primary"
          className={"BuySpotList_leftArrow"}
          onClick={leftArrowClick}
          disableElevation
          disableRipple
          disableTouchRipple
        >
          <ArrowBack />
        </Button>

        <div className={"BuySpotList_spotsList"}>
          {showingPrice === 0 ? <>{currentSpot} / {pData.spots}</> : null}
          {showingPrice !== 0 && showingPrice !== -1 ? <>{T("BUY_FOR", pad(showingPrice))}</> : null}
          {showingPrice === -1 ? <>{T("NOT_AVAILABLE")}</> : null}
        </div>

        <Button
          variant="contained"
          color="primary"
          className={"BuySpotList_rightArrow"}
          onClick={rightArrowClick}
          disableElevation
          disableRipple
          disableTouchRipple
        >
          <ArrowForward />
        </Button>
      </div>
    </div>
  )
}

export default BuySpotList;