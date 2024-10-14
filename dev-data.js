

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

const _testCarData = [];
for (let i = 0; i < 50; i++) {
  _testCarData.push({
    id: i,
    name: `Car ${i + 1}`,
    price: (i + 1) * 1000,
  })
}

const testAgenteData = [];
for (let i = 0; i < 20; i++) {
  testAgenteData.push({
    id: i,
    name: `Agente ${i + 1}`
  })
}

const testRangoData = [];
for (let i = 0; i < 20; i++) {
  testRangoData.push({
    id: i,
    name: `Rango ${i + 1}`
  })
}

const testCarData = [];
for (let i = 0; i < 50; i++) {
  testCarData.push({
    id: i,
    name: `Car ${i + 1}`,
    // make a plate number for each car with a random number
    plate: `ABC-${Math.floor(Math.random() * 1000)}`,
    // random number between 0 and 100 for fuel, engine, and body levels
    fuelLevel: Math.floor(Math.random() * 100),
    engineLevel: Math.floor(Math.random() * 100),
    bodyLevel: Math.floor(Math.random() * 100),
  })
}