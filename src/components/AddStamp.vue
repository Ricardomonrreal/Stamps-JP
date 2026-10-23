<script setup>
import { reactive, ref } from 'vue'
import { supabase } from '../supabase'

const props = defineProps({ at: Object, user: Object, lines: Array })
const emit = defineEmits(['done'])
const form = reactive({ name: '', name_ja: '', kind: 'station', line: '', prefecture: 'Osaka', city: 'Osaka', description: '' })
const files = reactive({ stamp: null, photo: null })
const previews = reactive({ stamp: '', photo: '' })
const error = ref('')
const busy = ref(false)

function pickFile(key, e) {
  const f = e.target.files[0] ?? null
  files[key] = f
  if (previews[key]) URL.revokeObjectURL(previews[key])
  previews[key] = f ? URL.createObjectURL(f) : ''
}

// Las fotos del móvil pesan 3-10 MB: se reducen a 1280 px en WebP antes de subirlas
async function shrink(file) {
  const img = await createImageBitmap(file)
  const k = Math.min(1, 1280 / Math.max(img.width, img.height))
  const c = Object.assign(document.createElement('canvas'), { width: img.width * k, height: img.height * k })
  c.getContext('2d').drawImage(img, 0, 0, c.width, c.height)
  return new Promise((ok) => c.toBlob(ok, 'image/webp', 0.82))
}

async function upload(file) {
  const path = `${props.user.id}/${crypto.randomUUID()}.webp`
  const { error: e } = await supabase.storage
    .from('stamp-images')
    .upload(path, await shrink(file), { contentType: 'image/webp' })
  if (e) throw e
  return supabase.storage.from('stamp-images').getPublicUrl(path).data.publicUrl
}

async function submit() {
  busy.value = true
  error.value = ''
  try {
    const [stamp_url, photo_url] = await Promise.all([files.stamp, files.photo].map((f) => f && upload(f)))
    const blank = (v) => v || null
    const { error: e } = await supabase.from('stamps').insert({
      ...form,
      name_ja: blank(form.name_ja),
      line: blank(form.line),
      description: blank(form.description),
      stamp_url,
      photo_url,
      lat: props.at.lat,
      lng: props.at.lng,
    })
    if (e) throw e
    emit('done', true)
  } catch (e) {
    error.value = e.message
  } finally {
    busy.value = false
  }
}
</script>

<template>
  <form class="sheet add" @submit.prevent="submit">
    <button type="button" class="close" aria-label="Cerrar" @click="emit('done', false)">✕</button>
    <h3>Proponer estampa</h3>
    <small class="coords">📍 {{ at.lat.toFixed(5) }}, {{ at.lng.toFixed(5) }}</small>

    <div class="uploads">
      <label class="drop" :class="{ filled: previews.stamp }">
        <img v-if="previews.stamp" :src="previews.stamp" alt="Vista previa de la estampa" />
        <span v-else>印<small>Imagen de la estampa *</small></span>
        <input type="file" accept="image/*" required @change="pickFile('stamp', $event)" />
      </label>
      <label class="drop" :class="{ filled: previews.photo }">
        <img v-if="previews.photo" :src="previews.photo" alt="Vista previa del lugar" />
        <span v-else>📷<small>Foto del lugar</small></span>
        <input type="file" accept="image/*" @change="pickFile('photo', $event)" />
      </label>
    </div>

    <div class="grid2">
      <input v-model.trim="form.name" placeholder="Nombre (ej. JR Osaka) *" required minlength="2" maxlength="120" />
      <input v-model.trim="form.name_ja" placeholder="Nombre en japonés (大阪駅)" maxlength="120" />
      <select v-model="form.kind" aria-label="Tipo">
        <option value="station">🚉 Estación</option>
        <option value="place">⛩️ Lugar</option>
      </select>
      <input v-model.trim="form.line" list="lines" placeholder="Línea (opcional)" maxlength="120" />
      <input v-model.trim="form.prefecture" placeholder="Prefectura *" required />
      <input v-model.trim="form.city" placeholder="Ciudad *" required />
    </div>
    <datalist id="lines"><option v-for="l in lines" :key="l" :value="l" /></datalist>
    <textarea v-model.trim="form.description" rows="2" placeholder="¿Dónde está la estampa exactamente? (ej. junto al torniquete central)" maxlength="500"></textarea>

    <p v-if="error" class="error">{{ error }}</p>
    <div class="row end">
      <button type="button" class="ghost" @click="emit('done', false)">Cancelar</button>
      <button class="primary" :disabled="busy">{{ busy ? 'Subiendo…' : 'Enviar propuesta' }}</button>
    </div>
  </form>
</template>
