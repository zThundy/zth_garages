import config from './config';

async function getLanguage() {
    return await fetch("/config/language.json")
        .then(response => response.json())
        .then(data => {
            return data[config.language];
        });
}

const lang = await getLanguage();

export function GetLang() {
    return config.lang;
}

export function T(key, ...args) {
    try {
        if (args.length > 0) {
            // replace all the %s with args in the string
            return lang[key].replace(/%s/g, () => args.shift());
        }
        return lang[key];
    } catch (e) {
        return key;
    }
}
