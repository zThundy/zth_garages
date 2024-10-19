
import "./ImpoundVehicle.css";

import { api } from "../index";
import { T } from "../lib/language";
import { TextField, InputAdornment, Button } from "@mui/material";
import { useRef, useState } from "react";

function ImpoundVehicle({ impoundData }) {
  const inputRef = useRef(null);
  const [description, setDescription] = useState(impoundData.description || "");
  const [money, setMoney] = useState(impoundData.money || 0);

  return (
    <div className={"ImpoundVehicle_Container"}>
      <div className={"ImpoundVehicle_Header"}>
        <div className={"ImpoundVehicle_Title"}><b>{T("NAME")}:</b> <u><i>{impoundData.name}</i></u></div>
      </div>

      <div className={"ImpoundVehicle_divider"}><span></span></div>

      <div className={"ImpoundVehicle_Body"}>
        <div className={"ImpoundVehicle_SubTitle"}>{T("IMPOUND_VEHICLE_DESCRIPTION")} <i style={{ fontSize: ".8rem" }}>Max: 500</i></div>
        <TextField
          className={"ImpoundVehicle_TextField"}
          label={T("IMPOUND_DESCRIPTION")}
          ref={inputRef}
          multiline
          onChange={(e) => {
            if (e.target.value.length > 500) return;
            setDescription(e.target.value)
          }}
          value={description}
          rows={12}
          variant="outlined"
        />
        <div className={"ImpoundVehicle_SubTitle"}>{T("IMPOUND_VEHICLE_MONEY")}</div>
        <TextField
          className={"ImpoundVehicle_TextField"}
          placeholder={T("IMPOUND_VEHICLE_MONEY_VALUE")}
          ref={inputRef}
          type="number"
          variant="outlined"
          value={money}
          onChange={(e) => {
            // remove all 0 from the start
            let money = e.target.value.replace(/^0+/, "");
            // remove all non numeric characters
            money = money.replace(/\D/g, "");
            // if the field is empty set it to 0
            if (money === "") money = 0;
            // if the money is more than 10 digits, remove the last digit
            if (money.length > 15) money = money.slice(0, -1);
            // set the money state
            setMoney(money);
          }}
          slotProps={{
            input: {
              startAdornment: <InputAdornment position="start">$</InputAdornment>,
            },
          }}
        />
      </div>

      <div className={"ImpoundVehicle_divider"} style={{ margin: "1rem 0" }}><span></span></div>

      <div className={"ImpoundVehicle_Footer"}>
        <Button
          className={"ImpoundVehicle_Button"}
          variant="contained"
          onClick={() => {
            if (description === "") description = T("IMPOUND_VEHICLE_NO_DESCRIPTION");
            // if the money is 0 return
            if (money === 0) return;
            // send the impound data to the server
            impoundData.description = description;
            impoundData.money = money;
            api.callEvent("impoundVehicle", impoundData);
          }}
        >{T("IMPOUND_VEHICLE_IMPOUND")}</Button>
      </div>
    </div>
  );
}

export default ImpoundVehicle;