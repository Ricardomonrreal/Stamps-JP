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

const props = defineProps({ stamps: Array, collected: Set, picking: Boolean, selected: Object })
const emit = defineEmits(['select', 'pick'])
const el = ref(null)
let map, layer

// Marcador tipo "sello": el color indica el estado; sin texto de usuario, así que el HTML fijo es seguro
function icon(s) {
  const state = s.status === 'pending' ? 'pending' : props.collected.has(s.id) ? 'got' : 'todo'
  const on = props.selected?.id === s.id ? ' on' : ''
  return L.divIcon({
    className: '',
    html: `<span class="pin ${state}${on}">${state === 'got' ? '✓' : '印'}</span>`,
    iconSize: [30, 30],
    iconAnchor: [15, 15],
  })
}

function draw() {
  layer.clearLayers()
  for (const s of props.stamps) {
    L.marker([s.lat, s.lng], { icon: icon(s), title: s.name, zIndexOffset: props.selected?.id === s.id ? 1000 : 0 })
      .on('click', () => emit('select', s))
      .addTo(layer)
  }
}

onMounted(() => {
  map = L.map(el.value, { zoomControl: false }).setView([34.69, 135.5], 12) // Osaka
  L.control.zoom({ position: 'topright' }).addTo(map)
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
watch(() => [props.stamps, props.collected, props.selected], draw)
onBeforeUnmount(() => map.remove())

defineExpose({
  locate: () => map.locate({ setView: true, maxZoom: 15 }),
  // padding: deja el marcador visible junto a la ficha (derecha en escritorio, abajo en móvil)
  focus: (s) => {
    const { x, y } = map.getSize()
    map.flyToBounds(L.latLng(s.lat, s.lng).toBounds(500), {
      paddingBottomRight: x > 900 ? [420, 0] : [0, y * 0.6],
      maxZoom: 16,
      duration: 0.6,
    })
  },
})
</script>

<template>
  <div ref="el" class="map" :class="{ picking }"></div>
</template>

<style scoped>
.map { height: 100%; }
.picking { cursor: crosshair; }
</style>
