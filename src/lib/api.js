

class API {
  constructor(res) {
    this.baseUrl = `https://${res}/html`;
    this.events = {};
  }

  callEvent(event, data) {
    if (this.events[event]) {
      this.events[event](data);
    }
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