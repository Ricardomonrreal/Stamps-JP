<script setup>
import { computed } from 'vue'

const props = defineProps({ stamps: Array, collected: Set })

// ponytail: estadísticas en el cliente; mover a una vista SQL cuando el catálogo sea todo Japón
const groups = computed(() => {
  const by = (key) => {
    const m = {}
    for (const s of props.stamps.filter((s) => s.status === 'approved')) {
      const g = (m[key(s)] ??= { label: key(s), total: 0, got: 0 })
      g.total++
      if (props.collected.has(s.id)) g.got++
    }
    return Object.values(m)
  }
  return {
    total: by(() => 'Total'),
    kind: by((s) => (s.kind === 'station' ? 'Estaciones' : 'Lugares')),
    area: by((s) => `${s.prefecture} / ${s.city}`),
  }
})
const missing = computed(() => props.stamps.filter((s) => s.status === 'approved' && !props.collected.has(s.id)))
</script>

<template>
  <section class="stats">
    <template v-for="(list, name) in groups" :key="name">
      <div v-for="g in list" :key="g.label" class="stat">
        <span>{{ g.label }}</span>
        <span>{{ g.got }} / {{ g.total }} ({{ Math.round((g.got / g.total) * 100) }}%)</span>
        <progress :value="g.got" :max="g.total"></progress>
      </div>
    </template>
    <h3>Te faltan ({{ missing.length }})</h3>
    <ul>
      <li v-for="s in missing" :key="s.id">{{ s.name }} <small>· {{ s.city }}</small></li>
    </ul>
  </section>
</template>
