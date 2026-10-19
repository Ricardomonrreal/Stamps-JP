<script setup>
import { onMounted, onBeforeUnmount, ref, watch } from 'vue'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'
import 'maplibre-gl/dist/maplibre-gl.css'
import { maplibreGL } from '@maplibre/maplibre-gl-leaflet'
import { setWorkerUrl } from 'maplibre-gl'
import workerUrl from 'maplibre-gl/dist/maplibre-gl-worker.mjs?url'

// MapLibre busca su worker junto a su propio archivo; con Vite hay que indicarle dónde quedó
setWorkerUrl(workerUrl)

const props = defineProps({ stamps: Array, collected: Set, picking: Boolean })
const emit = defineEmits(['toggle', 'pick'])
const el = ref(null)
let map, layer

// DOM + textContent: los nombres vienen de usuarios, nada de innerHTML
function popup(s) {
  const has = props.collected.has(s.id)
  const div = document.createElement('div')
  div.appendChild(document.createElement('strong')).textContent = s.name
  div.appendChild(document.createElement('p')).textContent = [
    s.kind === 'station' ? 'Estación' : 'Lugar',
    s.city,
    s.status === 'pending' && 'Pendiente de revisión',
    s.description,
  ].filter(Boolean).join(' · ')
  if (s.status === 'approved') {
    const btn = div.appendChild(document.createElement('button'))
    btn.textContent = has ? '✓ Recogida (quitar)' : 'Marcar como recogida'
    btn.onclick = () => emit('toggle', s.id)
  }
  return div
}

function draw() {
  layer.clearLayers()
  for (const s of props.stamps) {
    const color = s.status === 'pending' ? '#999' : props.collected.has(s.id) ? '#2e9e5b' : '#d33'
    L.circleMarker([s.lat, s.lng], { radius: 9, weight: 2, color: '#fff', fillColor: color, fillOpacity: 0.9 })
      .bindPopup(() => popup(s))
      .addTo(layer)
  }
}

onMounted(() => {
  map = L.map(el.value).setView([34.69, 135.5], 12) // Osaka
  // OpenFreeMap: open source, sin key ni límites de uso
  maplibreGL({
    style: 'https://tiles.openfreemap.org/styles/positron',
    attribution:
      '<a href="https://openfreemap.org" target="_blank">OpenFreeMap</a> &copy; <a href="https://www.openmaptiles.org/" target="_blank">OpenMapTiles</a> &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
  }).addTo(map)
  layer = L.layerGroup().addTo(map)
  map.on('click', (e) => props.picking && emit('pick', e.latlng))
  draw()
})
watch(() => [props.stamps, props.collected], draw)
onBeforeUnmount(() => map.remove())

defineExpose({ locate: () => map.locate({ setView: true, maxZoom: 15 }) })
</script>

<template>
  <div ref="el" class="map" :class="{ picking }"></div>
</template>

<style scoped>
.map { height: 100%; }
.picking { cursor: crosshair; }
</style>
