import React, { useState, useEffect } from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
// import reportWebVitals from './reportWebVitals';

import Main from './Main/Main';

import config from './lib/config';
import API from "./lib/api";
const api = new API(config.resName);
export { api };

// const root = ReactDOM.createRoot(document.getElementById('root'));

const RootComponent = () => {
  const [visible, setVisible] = useState(false)

  const handleNuiCallback = (event) => {
    switch (event.data.action) {
      case 'open':
        setVisible(true);
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
      {visible && <Main />}
    </React.StrictMode>
  )
}

ReactDOM.createRoot(document.getElementById('root')).render(<RootComponent />)

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
// reportWebVitals(root.render);
