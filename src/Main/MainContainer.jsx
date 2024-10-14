
import CSS from './MainContainer.module.css';

import SmallList from './SmallList';
import BuyParkingScreen from './BuyParkingScreen';
import ManageParkingScreen from './ManageParkingScreen';

import { T } from '../lib/language';

import { useState } from 'react';

function MainContainer() {
  const [parkingData, setParkingData] = useState([])
  const [screen, setScreen] = useState('list')
  const [title, setTitle] = useState(T("UNKNOWN"))

  const handleClick = (action) => {
    switch (action) {
      case "garage-buy":
        setScreen("garage-buy")
        setTitle(T("BUY_SPOT"))
        break;
      case "property-buy":
        setScreen("property-buy")
        break;
      case "garage-manage":
        setScreen("garage-manage")
        break;
      default:
        setScreen("list")
        break;
    }
  }

  return (
    <>
      {
        screen === "garage-buy" || screen === "list" || screen === "manage" ?
          <div className={CSS.container}>
            <div className={CSS.app}>
              <SmallList
                screen={screen}
                setScreen={setScreen}
                title={title}
                setTitle={setTitle}
                parkingData={parkingData}
              />
            </div>
          </div>
          : null
      }

      {
        screen === "garage-manage" ?
          <div className={CSS.containerFull}>
            <div className={CSS.fullscreen}>
              <ManageParkingScreen
                parkingData={parkingData}
              />
            </div>
          </div>
          : null
      }

      {
        screen === "property-buy" ?
          <div className={CSS.containerFull}>
            <div className={CSS.buyCurrent}>
              <BuyParkingScreen
                parkingData={parkingData}
              />
            </div>
          </div>
          : null
      }
    </>
  )
}

export default MainContainer;