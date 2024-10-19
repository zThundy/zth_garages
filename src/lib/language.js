import config from './config';

async function getLanguage() {
    if (process.env.NODE_ENV === "development") {
        return await fetch("/config/language.json")
            .then(response => response.json())
            .then(data => {
                return data[config.language];
            });
    } else {
        return await fetch("/html/config/language.json")
            .then(response => response.json())
            .then(data => {
                return data[config.language];
            });
    }
}

const lang = await getLanguage();

export function GetLang() {
    return config.lang;
}

export function T(key, ...args) {
    try {
        if (!lang[key]) throw new Error("Key not found");
        console.logger("T", key, args);
        if (args.length > 0) {
            // replace all the %s with args in the string
            return lang[key].replace(/%s/g, () => args.shift());
        }
        return lang[key];
    } catch (e) {
        console.error("Error getting language key", key)
        return key;
    }
}
