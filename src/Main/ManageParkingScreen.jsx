
import './ManageParkingScreen.css';

import { useState, useRef, useEffect } from 'react';

import { Button, TextField, Modal, Tooltip, InputAdornment } from '@mui/material';
import { Check, Close, DirectionsCar, Download, LocalParking, MonetizationOn, Upload } from '@mui/icons-material';
import { api } from "../index";
import { T } from '../lib/language';
import { pad, formatDate } from '../lib/utils';

function ManageParkingScreen({ parkingData }) {
  const [pData, setPData] = useState(parkingData);
  const [balance, setBalance] = useState(parkingData.balance);
  const [modalOpen, setModalOpen] = useState(false);
  const [modalType, setModalType] = useState("WITHDRAW");
  const amountRef = useRef(null);

  const manageModal = (open) => {
    setModalOpen(open);
  }

  useEffect(() => {
    api.registerEvent("balance-update", (data) => {
      setPData((old) => {
        old.balance = data.balance
        setBalance(data.balance)
        return old
      })
    }, false)
  }, [])

  // bruh
  useEffect(() => {
    setBalance(pData.balance)
  }, [pData, balance])

  return (
    <>
      <Modal
        open={modalOpen}
        onClose={() => manageModal(false)}
        className={"ManageParkingScreen_modalContainer"}
      >
        <div className={"ManageParkingScreen_modalBG"}>
          <h2>{T(modalType)}</h2>
          <span className={"ManageParkingScreen_modalDescription"}>{T(modalType + "_DESCRIPTION")}</span>

          <TextField
            label={T("AMOUNT")}
            type="number"
            variant="outlined"
            autoCapitalize
            autoFocus
            defaultValue={5000}
            inputRef={amountRef}
            slotProps={{
              input: {
                startAdornment: <InputAdornment position="start">$</InputAdornment>,
              },
            }}
          />

          <Button
            variant="contained"
            color="primary"
            onClick={() => {
              manageModal(false)
              const amount = amountRef.current.value
              api.callEvent("money", { type: modalType.toLowerCase(), amount, id: pData.id })
            }}
            startIcon={<Check />}
          >
            {T("CONFIRM")}
          </Button>
        </div>
      </Modal>

      <div className={"ManageParkingScreen_container"}>
        <div className={"ManageParkingScreen_header"}>
          <div className={"ManageParkingScreen_parkingName"}>
            <span>{T("PARKING")}</span>
            <div>{pData.name}</div>
          </div>

          <Tooltip
            title={T("CLOSE")}
            placement="top"
            onClick={() => api.callEvent("close", {})}
            arrow
          >
            <Button
              style={{ backgroundColor: 'rgb(255, 120, 120)' }}
              variant="text"
            >
              <Close />
            </Button>
          </Tooltip>
        </div>

        {/* <div className={"ManageParkingScreen_divider"}><span></span></div> */}

        <div className={"ManageParkingScreen_content"}>
          <div className={"ManageParkingScreen_listContainer"}>
            <div className={"ManageParkingScreen_listHeader"}>
              <span>{T("BALANCE")}:</span>
              <i>${pad(balance)}</i>

              <div className={"ManageParkingScreen_divider"}><span></span></div>

              <div className={"ManageParkingScreen_buttonsContainer"}>
                <Button
                  variant="contained"
                  color="primary"
                  startIcon={<Upload />}
                  onClick={() => {
                    manageModal(true)
                    setModalType("WITHDRAW")
                  }}
                >
                  {T("WITHDRAW")}
                </Button>
                <Button
                  variant="contained"
                  color="primary"
                  startIcon={<Download />}
                  onClick={() => {
                    manageModal(true)
                    setModalType("DEPOSIT")
                  }}
                >
                  {T("DEPOSIT")}
                </Button>
              </div>
            </div>

            <div className={"ManageParkingScreen_list"}>
              <table className={"ManageParkingScreen_slot"}>
                <thead>
                  <tr>
                    <th>{T("ID")}</th>
                    <th>{T("NAME")}</th>
                    <th>{T("PLATE")}</th>
                    <th>{T("FROM_DATE")}</th>
                    <th>{T("TO_DATE")}</th>
                    <th>{T("ACTIONS")}</th>
                  </tr>
                </thead>
                <tbody>
                {
                  pData.spotsData.map((slot, index) => {
                    if (!slot) return null
                    return (
                      <tr key={index} style={{
                        backgroundColor: index % 2 === 0 ? 'rgba(80, 80, 80, 0.1)' : 'rgba(80, 80, 80, 0.2)'
                      }}>
                        <td>{slot.id}</td>
                        <td>{slot.name}</td>
                        <td>{slot.plate}</td>
                        <td>{formatDate(slot.fromDate)}</td>
                        <td>{formatDate(slot.toDate)}</td>
                        <td>
                          <div
                            style={{
                              display: "flex",
                              gap: "2rem",
                              justifyContent: "center"
                            }}
                          >
                          <Button
                            variant="contained"
                            color="primary"
                            onClick={() => api.callEvent("manageGarageButton", {
                              action: "revoke",
                              slot: slot,
                              pData: pData
                            })}
                          >
                            {T("REVOKE_SPOT")}
                          </Button>
                          <Button
                            variant="contained"
                            color="primary"
                            onClick={() => api.callEvent("manageGarageButton", {
                              action: "renew",
                              slot: slot,
                              pData: pData
                            })}
                          >
                            {T("RENEW_SPOT")}
                          </Button>
                          </div>
                        </td>
                      </tr>
                    )
                  })
                }
                </tbody>
              </table>
            </div>
          </div>
          <div className={"ManageParkingScreen_rightColumn"}>
            <div className={"ManageParkingScreen_rightContainer"}>
              <span>{T("TOTAL_EARN")}:</span>
              <i>${pad(pData.totEarning)}</i>
              <MonetizationOn className={"ManageParkingScreen_icon"} />
            </div>
            <div className={"ManageParkingScreen_rightContainer"}>
              <span>{T("PARKING_AVAILABLE")}:</span>
              <i>{pData.spots}</i>
              <LocalParking className={"ManageParkingScreen_icon"} />
            </div>
            <div className={"ManageParkingScreen_rightContainer"}>
              <span>{T("PARKING_OCCUPIED")}:</span>
              <i>{pData.occupied.length}</i>
              <DirectionsCar className={"ManageParkingScreen_icon"} />
            </div>
            <div className={"ManageParkingScreen_rightContainer"}>
              <span
                style={{
                  marginBottom: "1rem",
                  textAlign: "center"
                }}
              >{T("SELL_PARKING")}</span>
              <Button
                variant="contained"
                color="primary"
                onClick={() => {
                  api.callEvent("sellParking", { pData: pData })
                }}
              >
                ${pData.sellPrice}
              </Button>
            </div>
          </div>
        </div>
      </div>
    </>
  )
}

export default ManageParkingScreen;