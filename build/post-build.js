const {
  readFileSync,
  writeFileSync,
  readdirSync,
} = require('fs');

let txt = readFileSync('./resource/zth_garages/html/index.html');
txt = txt.toString().replaceAll('/static/', 'static/');

writeFileSync('./resource/zth_garages/html/index.html', txt);

// remove this string "background-image: url("https://i.pinimg.com/originals/e2/6f/ba/e26fba8d9f2102d2dd8699c80b8ddc78.jpg");" from the resource/html/static/css/main.***.css
const path = './resource/zth_garages/html/static/css';
const regex = /main.([\d|\w].......).css$/gm;
const files = readdirSync(path);
let cssFile = '';

files.forEach(file => {
  console.log('file ' + file);
  if (regex.test(file)) {
    cssFile = file;
  }
});

if (cssFile !== '') {
  console.log('css file found ' + cssFile);
  let css = readFileSync(`${path}/${cssFile}`);
  css = css.toString().replace('background-image:url(https://i.pinimg.com/originals/e2/6f/ba/e26fba8d9f2102d2dd8699c80b8ddc78.jpg);', '');
  writeFileSync(`${path}/${cssFile}`, css);
  console.log('css file edited');
}

console.log('post-build scripts exec done');