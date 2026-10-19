<script setup>
import { reactive, ref } from 'vue'
import { supabase } from '../supabase'

const props = defineProps({ at: Object })
const emit = defineEmits(['done'])
const form = reactive({ name: '', kind: 'station', prefecture: 'Osaka', city: 'Osaka', description: '' })
const error = ref('')

async function submit() {
  const { error: e } = await supabase
    .from('stamps')
    .insert({ ...form, description: form.description || null, lat: props.at.lat, lng: props.at.lng })
  if (e) return (error.value = e.message)
  emit('done', true)
}
</script>

<template>
  <form class="sheet" @submit.prevent="submit">
    <h3>Proponer estampa</h3>
    <small>{{ at.lat.toFixed(5) }}, {{ at.lng.toFixed(5) }}</small>
    <input v-model.trim="form.name" placeholder="Nombre (ej. JR Osaka)" required minlength="2" maxlength="120" />
    <select v-model="form.kind">
      <option value="station">Estación</option>
      <option value="place">Lugar</option>
    </select>
    <input v-model.trim="form.prefecture" placeholder="Prefectura" required />
    <input v-model.trim="form.city" placeholder="Ciudad" required />
    <textarea v-model.trim="form.description" placeholder="¿Dónde está la estampa exactamente?" maxlength="500"></textarea>
    <p v-if="error" class="error">{{ error }}</p>
    <div class="row">
      <button type="button" @click="emit('done', false)">Cancelar</button>
      <button>Enviar</button>
    </div>
  </form>
</template>
