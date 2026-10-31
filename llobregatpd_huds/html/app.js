const root = document.documentElement;
const loc = document.getElementById('loc');
const abpText = document.getElementById('abpText');
const dirText = document.getElementById('dirText');
const streetText = document.getElementById('streetText');

const dirArrow = document.getElementById('dirArrow');
let arrowAngle = 0;

const speedo = document.getElementById('speedo');
const arc = document.getElementById('arc');
const speedVal = document.getElementById('speedVal');
const speedUnit = document.getElementById('speedUnit');
const fuelBox = document.querySelector('.fuel');
const fuelFill = document.getElementById('fuelFill');
const fuelVal = document.getElementById('fuelVal');

const SIDE_GAP = 16;   // px entre el minimapa y las pastillas
const BOTTOM_PAD = 6;  // px de las pastillas sobre la parte baja del minimapa

let maxSpeed = 240;

// Color de la barra: blanco -> ambar -> rojo segun la velocidad
const STOPS = [
  [0.00, [255, 255, 255]],
  [0.60, [255, 255, 255]],
  [0.80, [255, 176, 32]],
  [0.95, [255, 64, 64]],
];
function arcColor(p) {
  if (p <= STOPS[0][0]) return 'rgb(' + STOPS[0][1].join(',') + ')';
  for (let i = 1; i < STOPS.length; i++) {
    if (p <= STOPS[i][0]) {
      const [p0, c0] = STOPS[i - 1];
      const [p1, c1] = STOPS[i];
      const t = (p - p0) / (p1 - p0);
      return 'rgb(' + c0.map((v, k) => Math.round(v + (c1[k] - v) * t)).join(',') + ')';
    }
  }
  return 'rgb(' + STOPS[STOPS.length - 1][1].join(',') + ')';
}

function fuelColor(f) {
  if (f <= 15) return '#ff4040';
  if (f <= 30) return '#ffb020';
  return '#ffffff';
}

window.addEventListener('message', (e) => {
  const d = e.data || {};

  if (d.action === 'abp' && d.text) abpText.textContent = 'ABP: ' + d.text;
  if (d.action === 'dir' && d.text) dirText.textContent = d.text;
  if (d.action === 'street' && d.text) streetText.textContent = d.text;
  if (d.action === 'heading') {
    // gira por el camino mas corto (sin dar la vuelta entera al pasar de 359 a 0)
    const delta = (((d.deg - arrowAngle) % 360) + 540) % 360 - 180;
    arrowAngle += delta;
    dirArrow.style.transform = 'rotate(' + arrowAngle + 'deg)';
  }

  if (d.action === 'veh') {
    loc.classList.toggle('onfoot', !d.inVeh);
    speedo.classList.toggle('show', !!d.inVeh);
    if (d.unit) speedUnit.textContent = d.unit;
    if (d.max) maxSpeed = d.max;
    // En coche: pastillas a la derecha del minimapa, alineadas con su parte baja.
    // A pie: esquina inferior izquierda.
    if (typeof d.left === 'number') root.style.setProperty('--left-foot', (d.left * 100) + 'vw');
    if (typeof d.right === 'number') root.style.setProperty('--left', 'calc(' + (d.right * 100) + 'vw + ' + SIDE_GAP + 'px)');
    if (typeof d.bottom === 'number') root.style.setProperty('--bottom', 'calc(' + ((1 - d.bottom) * 100) + 'vh + ' + BOTTOM_PAD + 'px)');
  }

  if (d.action === 'speedo') {
    const sp = d.speed || 0;
    const pct = Math.min(sp / maxSpeed, 1);
    speedVal.textContent = sp;
    arc.style.strokeDasharray = (pct * 75) + ' 100';
    arc.style.stroke = arcColor(pct);
    arc.classList.toggle('red', pct > 0.95);

    const fuel = typeof d.fuel === 'number' ? d.fuel : -1;
    fuelBox.classList.toggle('hidden', fuel < 0);
    if (fuel >= 0) {
      fuelFill.style.width = fuel + '%';
      fuelFill.style.background = fuelColor(fuel);
      fuelVal.textContent = fuel + '%';
      fuelBox.classList.toggle('low', fuel <= 15);
    }
  }
});
