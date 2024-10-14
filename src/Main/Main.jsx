
import MainContainer from "./MainContainer"

import { createTheme, ThemeProvider } from "@mui/material/styles";
import { useEffect, useState } from "react";

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

function Main() {
  const [visible, setVisible] = useState(false)

  const handleNuiCallback = (event) => {
    switch (event.data.action) {
      case 'open':
        setVisible(true);
        break;
    }
  }

  const keyHandler = (e) => {
    if ('Escape'.includes(e.code)) {
      setVisible(false)
      fetch(`https://${GetParentResourceName()}/hide`, {
        method: 'post'
      })
    }
  }

  useEffect(() => {
    if (visible) {
      document.body.style.display = 'flex'
    } else {
      document.body.style.display = 'none'
    }
  }, [visible])

  window.addEventListener('message', handleNuiCallback)
  window.addEventListener('keydown', keyHandler)

  return (
    <ThemeProvider theme={theme}>
      <MainContainer />
      <div
        style={{
          position: 'absolute',
          bottom: '10px',
          zIndex: '1000',
          left: '10px',
          color: "white",
          opacity: 0.2
        }}
      >
        Made with ❤️ by zThundy__
      </div>
    </ThemeProvider>
  );
}

export default Main;
