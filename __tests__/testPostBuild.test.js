const fs = require('fs');
const PATH = '../resource/zth_garages/html/';

const txt = fs.readFileSync(`${PATH}/index.html`).toString();
if (txt.includes('/static/')) {
    throw new Error('The string "/static/" is still present in the index.html file');
}

const regex = /main.([\d|\w].......).css$/gm;
const files = fs.readdirSync(`${PATH}/static/css`);
let cssFile = '';

files.forEach(file => {
    if (regex.test(file)) {
        cssFile = file;
    }
});

if (cssFile === '') {
    throw new Error('CSS file not found');
}

let css = fs.readFileSync(`${PATH}/static/css/${cssFile}`).toString();
if (css.includes('background-image:url(https://i.pinimg.com/originals/e2/6f/ba/e26fba8d9f2102d2dd8699c80b8ddc78.jpg);')) {
    throw new Error('The main CSS file has not been edited');
}