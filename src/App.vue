<script setup>
import { ref } from 'vue'
import { supabase } from './supabase'
import StampMap from './components/StampMap.vue'
import StatsPanel from './components/StatsPanel.vue'
import AddStamp from './components/AddStamp.vue'

const user = ref(null)
const stamps = ref([])
const collected = ref(new Set())
const tab = ref('map')
const picking = ref(false)
const draft = ref(null)
const email = ref('')
const msg = ref('')
const mapRef = ref(null)

async function loadStamps() {
  // ponytail: carga todas las aprobadas; filtrar por límites del mapa cuando sea todo Japón
  const { data, error } = await supabase.from('stamps').select('*')
  if (error) return (msg.value = error.message)
  stamps.value = data
}

async function loadCollection() {
  if (!user.value) return (collected.value = new Set())
  const { data, error } = await supabase.from('collections').select('stamp_id')
  if (error) return (msg.value = error.message)
  collected.value = new Set(data.map((r) => r.stamp_id))
}

supabase.auth.onAuthStateChange((event, session) => {
  const changed = (session?.user?.id ?? null) !== (user.value?.id ?? null)
  user.value = session?.user ?? null
  // setTimeout: no llamar a supabase dentro de este callback (bloqueo documentado)
  if (event === 'INITIAL_SESSION' || changed) setTimeout(() => (loadStamps(), loadCollection()))
})

async function login() {
  const { error } = await supabase.auth.signInWithOtp({
    email: email.value,
    options: { emailRedirectTo: location.origin },
  })
  msg.value = error ? error.message : 'Revisa tu correo para entrar.'
}

async function toggle(id) {
  if (!user.value) return (msg.value = 'Inicia sesión para guardar tus estampas.')
  const has = collected.value.has(id)
  const { error } = has
    ? await supabase.from('collections').delete().eq('stamp_id', id)
    : await supabase.from('collections').insert({ stamp_id: id })
  if (error) return (msg.value = error.message)
  const next = new Set(collected.value)
  has ? next.delete(id) : next.add(id)
  collected.value = next
}

function startPick() {
  if (!user.value) return (msg.value = 'Inicia sesión para proponer ubicaciones.')
  picking.value = true
  msg.value = 'Toca el mapa donde está la estampa.'
}

function onPick(latlng) {
  picking.value = false
  msg.value = ''
  draft.value = latlng
}

function onAdded(sent) {
  draft.value = null
  if (sent) {
    msg.value = 'Gracias, tu propuesta queda pendiente de revisión.'
    loadStamps()
  }
}
</script>

<template>
  <header>
    <strong>Stamps JP</strong>
    <nav>
      <button :class="{ on: tab === 'map' }" @click="tab = 'map'">Mapa</button>
      <button :class="{ on: tab === 'stats' }" @click="tab = 'stats'">Progreso</button>
    </nav>
    <button v-if="user" @click="supabase.auth.signOut()">Salir</button>
    <form v-else class="row" @submit.prevent="login">
      <input v-model.trim="email" type="email" placeholder="tu@correo.com" required />
      <button>Entrar</button>
    </form>
  </header>

  <p v-if="msg" class="msg" @click="msg = ''">{{ msg }}</p>

  <main v-if="tab === 'map'">
    <StampMap ref="mapRef" :stamps :collected :picking @toggle="toggle" @pick="onPick" />
    <div class="fab">
      <button @click="mapRef.locate()">📍</button>
      <button @click="startPick">+ Proponer</button>
    </div>
    <AddStamp v-if="draft" :at="draft" @done="onAdded" />
  </main>
  <main v-else>
    <StatsPanel :stamps :collected />
  </main>
</template>
