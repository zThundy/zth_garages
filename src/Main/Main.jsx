
import MainContainer from "./MainContainer"

import { createTheme, ThemeProvider } from "@mui/material/styles";
// import { useEffect, useState } from "react";
// import { api } from "../index";

const theme = createTheme({
  palette: {
    primary: {
      main: "rgb(255, 80, 80)",
    },
    secondary: {
      main: "rgb(100, 100, 100)",
    },
  },
  cssVariables: true
});

function Main({
  parkingData,
  screen,
  title,
  setScreen,
  setTitle,
  vehicles,
  showManage,
  manageData,
  impoundData
}) {
  return (
    <ThemeProvider theme={theme}>
      <MainContainer
        parkingData={parkingData}
        screen={screen}
        title={title}
        setScreen={setScreen}
        setTitle={setTitle}
        vehicles={vehicles}
        showManage={showManage}
        manageData={manageData}
        impoundData={impoundData}
      />
      <div
        style={{
          position: 'absolute',
          bottom: '10px',
          zIndex: '1000',
          right: '20px',
          color: "white",
          opacity: 0.6
        }}
      >
        Made with ❤️ by zThundy__
      </div>
    </ThemeProvider>
  );
}

export default Main;
