const { readFileSync, writeFileSync } = require('fs');

let txt = readFileSync('./resource/zth_garages/html/index.html');
txt = txt.toString().replaceAll('/static/', 'static/');

writeFileSync('./resource/zth_garages/html/index.html', txt);
console.log('\nmid-build edits complete\n');