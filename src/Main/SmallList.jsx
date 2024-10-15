
import "./SmallList.css";

import ManageListTable from './ManageListTable';
import VehicleList from './VehicleList';
import BuySpotList from './BuySpotList';

import { Button, Tooltip } from '@mui/material';
import { Settings, Close, Check, ArrowBack } from '@mui/icons-material';
import { useEffect, useState } from 'react';
import { api } from '../index';
import { T } from '../lib/language';

function ManageList({ screen, setScreen, title, setTitle, parkingData, vehicles, showManage }) {
  const handleClick = (action) => {
    switch (action) {
      case "manage":
        setScreen("manage")
        setTitle(T("MANAGE_VEHICLES"))
        break;
      case "back":
        setScreen("list")
        setTitle(T("TAKE_VEHICLE"))
        break;
      case "close":
        api.callEvent("close", {});
        break;
      case "garage-buy":
        setTitle(T("BUY_SPOT"))
        break;
      default:
        setScreen("list")
        setTitle(T("TAKE_VEHICLE"))
        break;
    }
  }

  return (
    <>
      
      <div className={["SmallList_listContainer"]}>
        <div className={["SmallList_titleContainer"]}>
          <div className={["SmallList_title"]}>{title}</div>
          <div className={["SmallList_extraButtons"]}>
            {screen === "list" && showManage ?
              <Tooltip
                title={T("MANAGE")}
                placement="top"
                arrow
              >
                <Button
                  variant="text"
                  onClick={() => handleClick("manage")}
                >
                  <Settings />
                </Button>
              </Tooltip>
              : null}
            {screen === "manage" ?
              <Tooltip
                title={T("APPLY")}
                placement="top"
                arrow
              >
                <Button
                  style={{ backgroundColor: 'rgb(120, 200, 120)' }}
                  variant="text"
                >
                  <Check />
                </Button>
              </Tooltip>
              : null}
            {screen !== "manage" ?
              <Tooltip
                title={T("CLOSE")}
                placement="top"
                onClick={() => handleClick("close")}
                arrow
              >
                <Button
                  style={{ backgroundColor: 'rgb(255, 120, 120)' }}
                  variant="text"
                >
                  <Close />
                </Button>
              </Tooltip>
              :
              <Tooltip
                title={T("BACK")}
                placement="top"
                onClick={() => handleClick("back")}
                arrow
              >
                <Button
                  style={{ backgroundColor: 'rgb(255, 120, 120)' }}
                  variant="text"
                >
                  <ArrowBack />
                </Button>
              </Tooltip>
            }
          </div>
        </div>

        <div className={["SmallList_divider"]}></div>

        {screen === "manage" ? <ManageListTable /> : null}
        {screen === "list" ? <VehicleList vehicles={vehicles} /> : null}
        {screen === "garage-buy" ? <BuySpotList parkingData={parkingData} /> : null}
      </div>
    </>
  )
}

export default ManageList;