

class API {
  constructor(res) {
    this.baseUrl = `https://${res}/html/`;
    this.events = {};
  }

  callEvent(event, data) {
    console.logger(`Calling event: ${event}`);
    if (this.events[event]) {
      this.events[event](data);
      if (this.events[event].callEvent) this.post(event, data);
    }
  }

  async registerEvent(event, callback, callEvent) {
    console.logger(`Registering event: ${event}`);
    this.events[event] = callback;
    this.events[event].callEvent = callEvent;
  }

  async get(url) {
    return fetch(`${this.baseUrl}${url}`)
      .then(response => response.json());
  }

  async post(url, data) {
    if (!data) data = {};
    return await fetch(`${this.baseUrl}${url}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    })
      .then(response => {
        console.logger("Got response", response)
        try {
          if (!response.ok) {
            console.logger_error("Response not ok", response)
            return response.status;
          } else {
            console.logger("Parsing response...")
            return response.json()
          }
        } catch (error) {
          console.logger_error("Error parsing response", error)
          return "ok"
        }
      })
      .catch(error => console.logger_error('Error:', error));
  }
}

export default API;