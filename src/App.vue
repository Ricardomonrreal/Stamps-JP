<script setup>
import { computed, ref } from 'vue'
import { supabase } from './supabase'
import StampMap from './components/StampMap.vue'
import StatsPanel from './components/StatsPanel.vue'
import AddStamp from './components/AddStamp.vue'
import StampDetail from './components/StampDetail.vue'

const user = ref(null)
const stamps = ref([])
const collected = ref(new Set())
const tab = ref('map')
const picking = ref(false)
const draft = ref(null)
const email = ref('')
const msg = ref('')
const mapRef = ref(null)
const selected = ref(null)
const query = ref('')
const filter = ref('all')
const line = ref('')
const panelOpen = ref(false)
const loginOpen = ref(false)

async function loadStamps() {
  // ponytail: carga todas las aprobadas; filtrar por límites del mapa cuando sea todo Japón
  const { data, error } = await supabase.from('stamps').select('*').order('name')
  if (error) return toast(error.message)
  stamps.value = data
}

async function loadCollection() {
  if (!user.value) return (collected.value = new Set())
  const { data, error } = await supabase.from('collections').select('stamp_id')
  if (error) return toast(error.message)
  collected.value = new Set(data.map((r) => r.stamp_id))
}

supabase.auth.onAuthStateChange((event, session) => {
  const changed = (session?.user?.id ?? null) !== (user.value?.id ?? null)
  user.value = session?.user ?? null
  // setTimeout: no llamar a supabase dentro de este callback (bloqueo documentado)
  if (event === 'INITIAL_SESSION' || changed) setTimeout(() => (loadStamps(), loadCollection()))
})

let toastTimer
function toast(text) {
  msg.value = text
  clearTimeout(toastTimer)
  toastTimer = setTimeout(() => (msg.value = ''), 5000)
}

async function login() {
  const { error } = await supabase.auth.signInWithOtp({
    email: email.value,
    options: { emailRedirectTo: location.origin },
  })
  if (!error) loginOpen.value = false
  toast(error ? error.message : 'Te enviamos un enlace. Revisa tu correo para entrar.')
}

async function toggle(id) {
  if (!user.value) return (loginOpen.value = true)
  const has = collected.value.has(id)
  const { error } = has
    ? await supabase.from('collections').delete().eq('stamp_id', id)
    : await supabase.from('collections').insert({ stamp_id: id })
  if (error) return toast(error.message)
  const next = new Set(collected.value)
  has ? next.delete(id) : next.add(id)
  collected.value = next
  if (!has) toast('¡Estampa recogida! 🎉')
}

function startPick() {
  if (!user.value) return (loginOpen.value = true)
  selected.value = null
  panelOpen.value = false
  picking.value = true
}

function onPick(latlng) {
  picking.value = false
  draft.value = latlng
}

function onAdded(sent) {
  draft.value = null
  if (sent) {
    toast('¡Gracias! Tu propuesta queda pendiente de revisión.')
    loadStamps()
  }
}

function select(s) {
  tab.value = 'map'
  selected.value = s
  panelOpen.value = false
  // el mapa puede no estar montado si venimos de Progreso
  setTimeout(() => mapRef.value?.focus(s))
}

const approved = computed(() => stamps.value.filter((s) => s.status === 'approved'))
const got = computed(() => approved.value.filter((s) => collected.value.has(s.id)).length)
const lines = computed(() => [...new Set(stamps.value.map((s) => s.line).filter(Boolean))].sort())
const visible = computed(() => {
  const q = query.value.trim().toLowerCase()
  return stamps.value.filter(
    (s) =>
      (!q || [s.name, s.name_ja, s.city, s.line].some((v) => v?.toLowerCase().includes(q))) &&
      (!line.value || s.line === line.value) &&
      (filter.value === 'all' ||
        (filter.value === 'got' && collected.value.has(s.id)) ||
        (filter.value === 'todo' && s.status === 'approved' && !collected.value.has(s.id)) ||
        (filter.value === 'pending' && s.status === 'pending')),
  )
})
</script>

<template>
  <header class="topbar">
    <div class="brand">
      <img src="/icon.svg" alt="" width="32" height="32" />
      <div>
        <strong>Stamps JP</strong>
        <small>Mapa de eki stamps · Osaka</small>
      </div>
    </div>
    <nav class="tabs" aria-label="Secciones">
      <button :class="{ on: tab === 'map' }" @click="tab = 'map'">🗺️ <span>Mapa</span></button>
      <button :class="{ on: tab === 'stats' }" @click="tab = 'stats'">📊 <span>Progreso</span></button>
    </nav>
    <div class="account">
      <template v-if="user">
        <span class="chip" :title="user.email">{{ got }} / {{ approved.length }} 🔖</span>
        <button class="ghost" @click="supabase.auth.signOut()">Salir</button>
      </template>
      <button v-else class="primary" @click="loginOpen = true">Entrar</button>
    </div>
  </header>

  <main v-if="tab === 'map'" class="map-view">
    <aside class="panel" :class="{ open: panelOpen }">
      <button class="handle" @click="panelOpen = !panelOpen" :aria-expanded="panelOpen">
        <span></span>{{ visible.length }} estampas · {{ panelOpen ? 'ocultar lista' : 'ver lista' }}
      </button>

      <div class="banner" v-if="user">
        <div>
          <strong>Tu colección</strong>
          <small>{{ got }} de {{ approved.length }} estampas recogidas</small>
        </div>
        <span class="big">{{ approved.length ? Math.round((got / approved.length) * 100) : 0 }}%</span>
        <progress :value="got" :max="approved.length || 1"></progress>
      </div>
      <div class="banner invite" v-else>
        <div>
          <strong>Colecciona eki stamps 🇯🇵</strong>
          <small>Inicia sesión para guardar tu colección y proponer nuevas estampas.</small>
        </div>
        <button class="primary" @click="loginOpen = true">Empezar</button>
      </div>

      <input v-model="query" type="search" class="search" placeholder="🔍 Buscar estación, ciudad o línea…" />
      <div class="chips" role="group" aria-label="Filtro">
        <button v-for="[k, label] in [['all', 'Todas'], ['todo', 'Por recoger'], ['got', 'Recogidas'], ['pending', 'Propuestas']]"
          :key="k" :class="{ on: filter === k }" @click="filter = k">{{ label }}</button>
      </div>
      <select v-model="line" aria-label="Línea">
        <option value="">Todas las líneas</option>
        <option v-for="l in lines" :key="l">{{ l }}</option>
      </select>

      <ul class="list">
        <li v-for="s in visible" :key="s.id">
          <button class="item" :class="{ on: selected?.id === s.id }" @click="select(s)">
            <img v-if="s.stamp_url || s.photo_url" :src="s.stamp_url || s.photo_url" alt="" loading="lazy" />
            <span v-else class="ph">🔖</span>
            <span class="txt">
              <strong>{{ s.name }}</strong>
              <small>{{ [s.name_ja, s.line || s.city].filter(Boolean).join(' · ') }}</small>
            </span>
            <span class="dot" :class="s.status === 'pending' ? 'pending' : collected.has(s.id) ? 'got' : 'todo'"></span>
          </button>
        </li>
        <li v-if="!visible.length" class="empty">Sin resultados. Prueba con otro filtro.</li>
      </ul>
    </aside>

    <section class="stage">
      <StampMap ref="mapRef" :stamps="visible" :collected :picking :selected @select="select" @pick="onPick" />

      <div class="legend">
        <span><i class="dot todo"></i>Por recoger</span>
        <span><i class="dot got"></i>Recogida</span>
        <span><i class="dot pending"></i>Propuesta</span>
      </div>

      <div v-if="picking" class="pickbar">
        📍 Toca el mapa donde está la estampa
        <button class="ghost" @click="picking = false">Cancelar</button>
      </div>

      <div class="fab" v-if="!picking && !draft && !selected">
        <button class="round" title="Mi ubicación" aria-label="Mi ubicación" @click="mapRef.locate()">🎯</button>
        <button class="primary pill" @click="startPick">＋ Proponer estampa</button>
      </div>

      <StampDetail v-if="selected && !draft" :stamp="selected" :has="collected.has(selected.id)"
        @toggle="toggle(selected.id)" @close="selected = null" />
      <AddStamp v-if="draft" :at="draft" :user :lines @done="onAdded" />
    </section>
  </main>
  <main v-else class="scroll">
    <StatsPanel :stamps :collected @select="select" />
  </main>

  <div v-if="loginOpen" class="modal" @click.self="loginOpen = false">
    <form class="card" @submit.prevent="login">
      <h3>Entrar a Stamps JP</h3>
      <p>Te enviaremos un enlace mágico a tu correo. Sin contraseñas.</p>
      <input v-model.trim="email" type="email" placeholder="tu@correo.com" required autofocus autocomplete="email" />
      <div class="row end">
        <button type="button" class="ghost" @click="loginOpen = false">Cancelar</button>
        <button class="primary">Enviar enlace</button>
      </div>
    </form>
  </div>

  <p v-if="msg" class="toast" role="status" @click="msg = ''">{{ msg }}</p>
</template>
