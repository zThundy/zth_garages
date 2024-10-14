import React, { useState, useEffect } from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
// import reportWebVitals from './reportWebVitals';

import Main from './Main/Main';

import config from './lib/config';
import { T } from './lib/language';
import API from "./lib/api";
const api = new API(config.resName);
export { api };

// const root = ReactDOM.createRoot(document.getElementById('root'));

const RootComponent = () => {
  const [visible, setVisible] = useState(false);
  const [parkingData, setParkingData] = useState({});
  const [screen, setScreen] = useState('list');
  const [title, setTitle] = useState(T("UNKNOWN"));

  const HandleScreen = (action) => {
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

  const handleNuiCallback = (event) => {
    console.log('Received NUI message:', event.data.action);
    switch (event.data.action) {
      case 'open':
        setVisible(true);
        HandleScreen(event.data.data.screen);
        break;
      default:
        console.log('Unknown action', event.data.action);
        console.log('Data:', JSON.stringify(event.data));
        api.callEvent(event.data.action, event.data);
        break;
    }
  }

  const keyHandler = (e) => {
    if ('Escape'.includes(e.code)) {
      setVisible(false)
      api.post('close', {})
    }
  }

  useEffect(() => {
    if (visible) {
      document.body.style.display = 'block'
    }else{
      document.body.style.display = 'none'
    }
  }, [visible])
  
  window.addEventListener('message', handleNuiCallback)
  window.addEventListener('keydown', keyHandler)
  
  return (
    <React.StrictMode>
      {visible && <Main parkingData={parkingData} screen={screen} title={title} setScreen={setScreen} setTitle={setTitle} />}
    </React.StrictMode>
  )
}

ReactDOM.createRoot(document.getElementById('root')).render(<RootComponent />)

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
// reportWebVitals(root.render);
