<script setup>
import { computed } from 'vue'

const props = defineProps({ stamps: Array, collected: Set })
const emit = defineEmits(['select'])

// ponytail: estadísticas en el cliente; mover a una vista SQL cuando el catálogo sea todo Japón
const groups = computed(() => {
  const by = (key) => {
    const m = {}
    for (const s of props.stamps.filter((s) => s.status === 'approved')) {
      const g = (m[key(s)] ??= { label: key(s), total: 0, got: 0 })
      g.total++
      if (props.collected.has(s.id)) g.got++
    }
    return Object.values(m).sort((a, b) => b.total - a.total)
  }
  return [
    ['Por línea', by((s) => s.line || (s.kind === 'station' ? 'Otras estaciones' : 'Lugares'))],
    ['Por ciudad', by((s) => `${s.city}, ${s.prefecture}`)],
  ]
})
const total = computed(() => props.stamps.filter((s) => s.status === 'approved'))
const got = computed(() => total.value.filter((s) => props.collected.has(s.id)).length)
const missing = computed(() => total.value.filter((s) => !props.collected.has(s.id)))
const pct = (a, b) => (b ? Math.round((a / b) * 100) : 0)
</script>

<template>
  <section class="stats">
    <div class="banner hero">
      <div>
        <strong>Tu progreso</strong>
        <small>{{ got }} de {{ total.length }} estampas recogidas</small>
      </div>
      <span class="big">{{ pct(got, total.length) }}%</span>
      <progress :value="got" :max="total.length || 1"></progress>
    </div>

    <div class="cols">
      <div v-for="[title, list] in groups" :key="title" class="card">
        <h3>{{ title }}</h3>
        <div v-for="g in list" :key="g.label" class="stat">
          <span>{{ g.label }}</span>
          <span>{{ g.got }}/{{ g.total }}</span>
          <progress :value="g.got" :max="g.total"></progress>
        </div>
      </div>
    </div>

    <div class="card">
      <h3>Te faltan ({{ missing.length }})</h3>
      <ul class="list">
        <li v-for="s in missing" :key="s.id">
          <button class="item" @click="emit('select', s)">
            <img v-if="s.stamp_url || s.photo_url" :src="s.stamp_url || s.photo_url" alt="" loading="lazy" />
            <span v-else class="ph">🔖</span>
            <span class="txt"><strong>{{ s.name }}</strong><small>{{ s.line || s.city }}</small></span>
            <span aria-hidden="true">›</span>
          </button>
        </li>
      </ul>
    </div>
  </section>
</template>
