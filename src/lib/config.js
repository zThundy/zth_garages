
async function getConfig() {
    return await fetch("/html/config/config.json")
        .then(response => response.json());
}

export default await getConfig();