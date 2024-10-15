
import './MainContainer.css';

import SmallList from './SmallList';
import BuyParkingScreen from './BuyParkingScreen';
import ManageParkingScreen from './ManageParkingScreen';

import { T } from '../lib/language';

import { useState } from 'react';

function MainContainer({ parkingData, screen, title, setScreen, setTitle, vehicles, showManage }) {

  return (
    <>
      {
        screen === "garage-buy" || screen === "list" || screen === "manage" ?
          <div className={"MainContainer_container"}>
            <div className={"MainContainer_app"}>
              <SmallList
                screen={screen}
                setScreen={setScreen}
                title={title}
                setTitle={setTitle}
                parkingData={parkingData}
                vehicles={vehicles}
                showManage={showManage}
              />
            </div>
          </div>
          : null
      }

      {
        screen === "garage-manage" ?
          <div className={"MainContainer_containerFull"}>
            <div className={"MainContainer_fullscreen"}>
              <ManageParkingScreen
                parkingData={parkingData}
              />
            </div>
          </div>
          : null
      }

      {
        screen === "property-buy" ?
          <div className={"MainContainer_containerFull"}>
            <div className={"MainContainer_buyCurrent"}>
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