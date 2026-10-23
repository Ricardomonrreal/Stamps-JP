<script setup>
defineProps({ stamp: Object, has: Boolean })
const emit = defineEmits(['toggle', 'close'])
</script>

<template>
  <article class="sheet detail" :aria-label="stamp.name">
    <button class="close" aria-label="Cerrar" @click="emit('close')">✕</button>

    <div class="media">
      <img v-if="stamp.photo_url" class="photo" :src="stamp.photo_url" :alt="`Foto de ${stamp.name}`" />
      <div v-else class="photo none">Sin foto todavía</div>
      <figure class="stamp-img">
        <img v-if="stamp.stamp_url" :src="stamp.stamp_url" :alt="`Estampa de ${stamp.name}`" />
        <span v-else>印<small>Sin imagen de la estampa</small></span>
      </figure>
    </div>

    <h3>{{ stamp.name }} <small v-if="stamp.name_ja">{{ stamp.name_ja }}</small></h3>
    <p class="meta">
      <span class="tag">{{ stamp.kind === 'station' ? '🚉 Estación' : '⛩️ Lugar' }}</span>
      <span v-if="stamp.line" class="tag">{{ stamp.line }}</span>
      <span class="tag">📍 {{ stamp.city }}, {{ stamp.prefecture }}</span>
      <span v-if="stamp.status === 'pending'" class="tag warn">Pendiente de revisión</span>
    </p>
    <p v-if="stamp.description" class="desc">{{ stamp.description }}</p>

    <div class="row">
      <a class="btn ghost" target="_blank" rel="noopener"
        :href="`https://www.google.com/maps/dir/?api=1&destination=${stamp.lat},${stamp.lng}`">🧭 Cómo llegar</a>
      <button v-if="stamp.status === 'approved'" :class="has ? 'got' : 'primary'" @click="emit('toggle')">
        {{ has ? '✓ Recogida' : '🔖 Marcar como recogida' }}
      </button>
    </div>
  </article>
</template>
