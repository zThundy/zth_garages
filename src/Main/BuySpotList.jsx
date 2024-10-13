
import { Button } from '@mui/material';
import CSS from './BuySpotList.module.css';

import { useState } from 'react';
import { ArrowBack, ArrowForward } from '@mui/icons-material';
import { pad } from '../lib/utils';
import { T } from '../lib/language';

function BuySpotList({ parkingData }) {
  const [pData, setParkingData] = useState(parkingData);
  const [currentSpot, setCurrentSpot] = useState(1);
  const [showingPrice, setShowingPrice] = useState(0);

  const showPrice = (days) => {
    if (days === 0) return setShowingPrice(0);
    if (pData.occupied.includes(currentSpot)) return setShowingPrice(-1);
    setShowingPrice(pData.price * days);
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
    <div className={CSS.container}>
      <div className={CSS.infoContainer}>
        <div className={CSS.info}>
          <div className={CSS.parkingName}>{pData.name}</div>
          <div className={CSS.spots}>
            <div className={CSS.spotsTotal}>
              <span className={CSS.label}>{T("TOTAL")}:</span>
              <span className={CSS.red}>{pData.spots}</span>
            </div>
            <div className={CSS.spotsOccupied}>
              <span className={CSS.label}>{T("TAKEN")}:</span>
              <span className={CSS.red}>{parseInt(pData.spots) >= 100 ? parkingData.occupied.length.toString().padStart(3, "0") : parkingData.occupied.length}</span>
            </div>
          </div>
        </div>
        <div className={CSS.price}>
          <div className={CSS.pricePeriod}>{T("PRICE_PER_DAY")}:</div>
          <div className={CSS.priceValue}>${pad(pData.price)}</div>
        </div>
      </div>

      <div className={CSS.divider}><span></span></div>

      <div className={CSS.buyContainer}>
        <div className={CSS.buyButtons}>
          <Button
            variant="contained"
            color="primary"
            className={CSS.buyButton}
            onMouseEnter={() => showPrice(1)}
            onMouseLeave={() => showPrice(0)}
          >
            {T("DAY", 1)}
          </Button>
          <Button
            variant="contained"
            color="primary"
            className={CSS.buyButton}
            onMouseEnter={() => showPrice(3)}
            onMouseLeave={() => showPrice(0)}
          >
            {T("DAYS", 3)}
          </Button>
          <Button
            variant="contained"
            color="primary"
            className={CSS.buyButton}
            onMouseEnter={() => showPrice(5)}
            onMouseLeave={() => showPrice(0)}
          >
            {T("DAYS", 5)}
          </Button>
          <Button
            variant="contained"
            color="primary"
            className={CSS.buyButton}
            onMouseEnter={() => showPrice(7)}
            onMouseLeave={() => showPrice(0)}
          >
            {T("DAYS", 7)}
          </Button>
          <Button
            variant="contained"
            color="primary"
            className={CSS.buyButton}
            onMouseEnter={() => showPrice(14)}
            onMouseLeave={() => showPrice(0)}
          >
            {T("DAYS", 14)}
          </Button>
          <Button
            variant="contained"
            color="primary"
            className={CSS.buyButton}
            onMouseEnter={() => showPrice(21)}
            onMouseLeave={() => showPrice(0)}
          >
            {T("DAYS", 21)}
          </Button>
          <Button
            variant="contained"
            color="primary"
            className={CSS.buyButton}
            onMouseEnter={() => showPrice(300)}
            onMouseLeave={() => showPrice(0)}
          >
            {T("PERMANENT")}
          </Button>
        </div>
      </div>

      <div className={CSS.divider}><span></span></div>

      <div className={CSS.scrollSpots}>
        <Button
          variant="contained"
          color="primary"
          className={CSS.leftArrow}
          onClick={leftArrowClick}
          disableElevation
          disableRipple
          disableTouchRipple
        >
          <ArrowBack />
        </Button>

        <div className={CSS.spotsList}>
          {showingPrice === 0 ? <>{currentSpot} / {pData.spots}</> : null}
          {showingPrice !== 0 && showingPrice !== -1 ? <>{T("BUY_FOR", pad(showingPrice))}</> : null}
          {showingPrice === -1 ? <>{T("NOT_AVAILABLE")}</> : null}
        </div>

        <Button
          variant="contained"
          color="primary"
          className={CSS.rightArrow}
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