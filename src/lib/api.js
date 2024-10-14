

class API {
  constructor(res) {
    this.baseUrl = `https://${res}/`;
    this.events = {};

    window.addEventListener("message", (event) => {
      console.log(JSON.stringify(event.data, null, 2));
      if (event.origin !== this.baseUrl) return;
      if (this.events[event.data.event]) this.events[event.data.event](event.data);
    });
  }

  async get(url) {
    return fetch(`${this.baseUrl}${url}`)
      .then(response => response.json());
  }

  async registerEvent(event, callback) {
    this.events[event] = callback;
  }

  async post(url, data) {
    return fetch(`${this.baseUrl}${url}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    })
      .then(response => response.json())
      .catch(error => console.error('Error:', error));
  }
}

export default API;