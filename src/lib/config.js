
async function getConfig() {
    return await fetch("/config/config.json")
        .then(response => response.json());
}

export default await getConfig();