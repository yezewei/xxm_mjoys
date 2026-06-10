const fs = require('fs');
const p = 'src/pages/QualityTask.vue';
const lines = fs.readFileSync(p, 'utf8').split('\n');
const newLines = [...lines.slice(0, 525), ...lines.slice(1218)];
fs.writeFileSync(p, newLines.join('\n'));
console.log('Done. Removed', 1218 - 525, 'lines. New total:', newLines.length);
