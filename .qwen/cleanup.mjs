import { readFileSync, writeFileSync } from 'fs';
const p = 'src/pages/QualityTask.vue';
const lines = readFileSync(p, 'utf8').split('\n');
// Find the STEP3_REMOVED marker line
const markerIdx = lines.findIndex(l => l.includes('STEP3_REMOVED'));
// Find the FIRST modal-footer AFTER the marker
const footerIdx = lines.findIndex((l, i) => i > markerIdx && l.includes('<div class="modal-footer">'));
// Remove everything from markerIdx+1 to footerIdx-1
const newLines = [...lines.slice(0, markerIdx + 1), '', ...lines.slice(footerIdx)];
writeFileSync(p, newLines.join('\n'));
console.log(`Removed ${footerIdx - markerIdx - 1} lines. New total: ${newLines.length}`);
