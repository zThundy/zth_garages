
import CSS from './MainContainer.module.css';

import SmallList from './SmallList';
import BuyParkingScreen from './BuyParkingScreen';
import ManageParkingScreen from './ManageParkingScreen';

import { T } from '../lib/language';

import { useState } from 'react';

const testParkingData = {
  name: 'Legion square parking',
  spots: 120,
  occupied: [12, 6, 15, 8, 120],
  price: 1800, // for 1 day
  managementPrice: 5000000,
  sellPrice: 400000,
  totEarning: 148343,
  spotsData: [
    {
      id: 1,
      name: "FORZA ROMA, SEMPRE!",
      plate: "ABC-1234",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 2,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 3,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 4,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 5,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 6,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 7,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 8,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 9,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 10,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 10,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 10,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 10,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 10,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 10,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 10,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 10,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 10,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 10,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 10,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 10,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 10,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    },
    {
      id: 10,
      name: "FORZA ROMA, SEMPRE 2!",
      plate: "DEF-5678",
      fromDate: new Date("2021-10-01T00:00:00"),
      toDate: new Date("2021-10-02T00:00:00"),
    }
  ]
}

function MainContainer() {
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
      <button
        style={{
          position: 'absolute',
          top: '10px',
          zIndex: '1000',
        }}
        onClick={() => handleClick("garage-buy")}
      >FORZA ROMA</button>

      <button
        style={{
          position: 'absolute',
          top: '10px',
          zIndex: '1000',
          left: '200px',
        }}
        onClick={() => handleClick("garage-manage")}
      >FORZA ROMA 2</button>

      <button
        style={{
          position: 'absolute',
          top: '10px',
          zIndex: '1000',
          left: '400px',
        }}
        onClick={() => handleClick("list")}
      >FORZA ROMA 3</button>


      <button
        style={{
          position: 'absolute',
          top: '10px',
          zIndex: '1000',
          left: '600px',
        }}
        onClick={() => handleClick("property-buy")}
      >FORZA ROMA 4</button>

      {
        screen === "garage-buy" || screen === "list" || screen === "manage" ?
          <div className={CSS.container}>
            <div className={CSS.app}>
              <SmallList
                screen={screen}
                setScreen={setScreen}
                title={title}
                setTitle={setTitle}
                parkingData={testParkingData}
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
                parkingData={testParkingData}
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
                parkingData={testParkingData}
              />
            </div>
          </div>
          : null
      }
    </>
  )
}

export default MainContainer;