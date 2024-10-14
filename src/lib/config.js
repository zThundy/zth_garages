
async function getConfig() {
    if (process.env.NODE_ENV === "development") {
        return await fetch("/config/config.json")
            .then(response => response.json());
    } else {
        return await fetch("/html/config/config.json")
            .then(response => response.json());
    }
}

export default await getConfig();