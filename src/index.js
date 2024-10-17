import React, { useState, useEffect } from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';

import Main from './Main/Main';

import config from './lib/config';
import { T } from './lib/language';
import API from "./lib/api";
const api = new API(config.resName);
export { api };

// check if config.debug is enabled, if so log
console.logger = function(message, ...params) {
  if (config.debug) {
    console.log(`[${config.resName}] ${message}`, ...params);
  }
}

console.logger_error = function(message, ...params) {
  if (config.debug) {
    console.error(`[${config.resName}] ${message}`, ...params);
  }
}

// const root = ReactDOM.createRoot(document.getElementById('root'));

const RootComponent = () => {
  const [visible, setVisible] = useState(false);
  const [render, setRender] = useState(false);
  const [parkingData, setParkingData] = useState({});
  const [showManage, setShowManage] = useState(false);
  const [vehicles, setVehicles] = useState([]);
  const [screen, setScreen] = useState('list');
  const [title, setTitle] = useState(T("UNKNOWN"));
  const [manageData, setManageData] = useState({});

  const HandleScreen = (action, data) => {
    switch (action) {
      case "garage-buy":
        setTitle(T("TITLE_BUY_SPOT"));
        setScreen("garage-buy");
        setParkingData(data);
        setShowManage(false);
        break;
      case "property-buy":
        setTitle(T("TITLE_BUY_PARKING"));
        setScreen("property-buy");
        break;
      case "garage-manage":
        setScreen("garage-manage");
        setParkingData(data);
        setShowManage(false);
        break;
      default:
        setScreen("list");
        setTitle(T("TITLE_TAKE_VEHICLE"));
        setVehicles(data.vehicles);
        setShowManage(false);
        break;
    }
  }

  const handleNuiCallback = (event) => {
    const message = event.data;
    console.logger('Received NUI message:', message.action);
    switch (event.data.action) {
      case 'open':
        console.logger('Received NUI message:', JSON.stringify(message));
        setVisible(true);
        setRender(true);
        HandleScreen(message.data.screen, message.data.garageData);
        break;
      case "close":
        console.logger('Received NUI message:', JSON.stringify(message));
        setVisible(false);
        break;
      case "show-manage":
        console.logger('Received NUI message:', JSON.stringify(message));
        setManageData(message.data);
        setShowManage(Boolean(message.value) || false);
        break;
      case "balance-update":
        api.callEvent("balance-update", event.data);
        break;
      default:
        console.logger('Unknown action', event.data.action);
        console.logger('Data:', JSON.stringify(event.data));
        api.callEvent(event.data.action, event.data);
        break;
    }
  }

  useEffect(() => {
    if (visible) {
      document.body.style.display = 'block'
      // increase opacity
      document.body.style.opacity = 0
      const interval = setInterval(() => {
        if (document.body.style.opacity < 1) {
          document.body.style.opacity = parseFloat(document.body.style.opacity) + 0.05
        } else {
          document.body.style.opacity = 1
          clearInterval(interval)
        }
      }, 10)
      return () => clearInterval(interval)
    } else {
      // decrease opacity
      document.body.style.opacity = 1
      const interval = setInterval(() => {
        if (document.body.style.opacity > 0) {
          document.body.style.opacity = parseFloat(document.body.style.opacity) - 0.05
        } else {
          document.body.style.opacity = 0
          document.body.style.display = 'none'
          setRender(false)
          api.post("close", {});
          clearInterval(interval)
        }
      }, 10)
      return () => clearInterval(interval)
    }
  }, [visible])
  
  useEffect(() => {
    api.registerEvent("close", (data) => {
      // fade out opacity
      if (data.post) api.post("close", {});
      setVisible(false);
    }, false)

    api.registerEvent("take", (data) => {
      api.post("take", data);
    }, false);

    api.registerEvent("money", (data) => {
      // parse check data.amount just in case
      data.amount = parseInt(data.amount);
      api.post("money", data);
    }, false)

    api.registerEvent("buySpot", data => {
      api.post("buySpot", data);
    }, false)

    api.registerEvent("changeSpot", data => {
      api.post("changeSpot", data);
    }, false)

    window.addEventListener('message', handleNuiCallback)
    window.addEventListener('keydown', (e) => {
      if ('Escape'.includes(e.code)) {
        api.callEvent("close", {});
      }
    })
  }, [])
  
  return (
    <React.StrictMode>
      {
        render &&
        <Main
          parkingData={parkingData}
          screen={screen}
          title={title}
          setScreen={setScreen}
          setTitle={setTitle}
          vehicles={vehicles}
          showManage={showManage}
          manageData={manageData}
        />
      }
    </React.StrictMode>
  )
}

ReactDOM.createRoot(document.getElementById('root')).render(<RootComponent />)

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
// reportWebVitals(root.render);
