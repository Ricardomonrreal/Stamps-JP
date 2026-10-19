# Graph Report - Stamps-JP  (2026-10-19)

## Corpus Check
- 12 files · ~1,783 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 2, .css 1)

## Summary
- 114 nodes · 91 edges · 47 communities (10 shown, 37 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `eb774b2b`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- App.vue
- package.json
- AddStamp.vue
- StampMap.vue
- vue
- jsconfig.json
- dependencies
- devDependencies
- Stamps JP
- scripts
- CLAUDE.md

## God Nodes (most connected - your core abstractions)
1. `vue` - 6 edges
2. `scripts` - 4 edges
3. `Stamps JP` - 4 edges
4. `popup()` - 3 edges
5. `supabase` - 3 edges
6. `compilerOptions` - 2 edges
7. `@maplibre/maplibre-gl-leaflet` - 2 edges
8. `@supabase/supabase-js` - 2 edges
9. `leaflet` - 2 edges
10. `maplibre-gl` - 2 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Project Configuration** — stamps_jp_project, env_example_file, env_local_file, supabase_schema_sql [0.9]
- **PWA Setup** — pwa_technology, icon_svg, manifest_webmanifest, index_html [0.9]
- **graphify Query Commands** — graphify_query_command, graphify_path_command, graphify_explain_command, graphify_knowledge_graph [0.95]
- **Stamps JP Technology Stack** — stamps_jp_project, vue_framework, leaflet_library, supabase_service, vercel_service [0.95]

## Communities (47 total, 37 thin omitted)

### Community 0 - "App.vue"
Cohesion: 0.12
Nodes (11): collected, draft, email, loadStamps(), mapRef, msg, onAdded(), picking (+3 more)

### Community 1 - "package.json"
Cohesion: 0.18
Nodes (10): engines, node, name, private, type, version, maplibre-gl, vite (+2 more)

### Community 2 - "AddStamp.vue"
Cohesion: 0.28
Nodes (7): @supabase/supabase-js, emit, error, form, props, submit(), supabase

### Community 3 - "StampMap.vue"
Cohesion: 0.32
Nodes (7): leaflet, @maplibre/maplibre-gl-leaflet, draw(), el, emit, popup(), props

### Community 4 - "vue"
Cohesion: 0.33
Nodes (4): vue, groups, missing, props

### Community 5 - "jsconfig.json"
Cohesion: 0.50
Nodes (3): compilerOptions, paths, exclude

### Community 6 - "dependencies"
Cohesion: 0.33
Nodes (6): dependencies, leaflet, maplibre-gl, @maplibre/maplibre-gl-leaflet, @supabase/supabase-js, vue

### Community 7 - "devDependencies"
Cohesion: 0.50
Nodes (4): devDependencies, vite, vite-plugin-vue-devtools, @vitejs/plugin-vue

### Community 36 - "Stamps JP"
Cohesion: 0.40
Nodes (4): Configuración, Escalar a todo Japón, Moderación, Stamps JP

### Community 45 - "scripts"
Cohesion: 0.50
Nodes (4): scripts, build, dev, preview

## Knowledge Gaps
- **39 isolated node(s):** `paths`, `exclude`, `name`, `version`, `private` (+34 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 83 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **37 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `vue` connect `vue` to `App.vue`, `package.json`, `AddStamp.vue`, `StampMap.vue`?**
  _High betweenness centrality (0.136) - this node is a cross-community bridge._
- **What connects `paths`, `exclude`, `name` to the rest of the system?**
  _39 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `App.vue` be split into smaller, more focused modules?**
  _Cohesion score 0.125 - nodes in this community are weakly interconnected._
- **Why does `dependencies` connect `dependencies` to `package.json`?**
  _High betweenness centrality (0.050) - this node is a cross-community bridge._
- **Why does `scripts` connect `scripts` to `package.json`?**
  _High betweenness centrality (0.030) - this node is a cross-community bridge._