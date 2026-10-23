# Graph Report - Stamps-JP  (2026-10-23)

## Corpus Check
- 14 files · ~4,213 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 2, .css 1)

## Summary
- 139 nodes · 126 edges · 46 communities (9 shown, 37 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `d9426d59`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- App.vue
- package.json
- AddStamp.vue
- StampMap.vue
- StatsPanel.vue
- jsconfig.json
- dependencies
- Stamps JP
- scripts
- CLAUDE.md

## God Nodes (most connected - your core abstractions)
1. `vue` - 6 edges
2. `toast()` - 6 edges
3. `upload()` - 5 edges
4. `Stamps JP` - 5 edges
5. `scripts` - 4 edges
6. `loadStamps()` - 4 edges
7. `loadCollection()` - 3 edges
8. `onAdded()` - 3 edges
9. `select()` - 3 edges
10. `submit()` - 3 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Project Configuration** — stamps_jp_project, env_example_file, env_local_file, supabase_schema_sql [0.9]
- **PWA Setup** — pwa_technology, icon_svg, manifest_webmanifest, index_html [0.9]
- **graphify Query Commands** — graphify_query_command, graphify_path_command, graphify_explain_command, graphify_knowledge_graph [0.95]
- **Stamps JP Technology Stack** — stamps_jp_project, vue_framework, leaflet_library, supabase_service, vercel_service [0.95]

## Communities (46 total, 37 thin omitted)

### Community 0 - "App.vue"
Cohesion: 0.08
Nodes (27): approved, collected, draft, email, filter, got, line, lines (+19 more)

### Community 1 - "package.json"
Cohesion: 0.14
Nodes (13): devDependencies, vite, vite-plugin-vue-devtools, @vitejs/plugin-vue, engines, node, name, private (+5 more)

### Community 2 - "AddStamp.vue"
Cohesion: 0.17
Nodes (12): @supabase/supabase-js, busy, emit, error, files, form, previews, props (+4 more)

### Community 3 - "StampMap.vue"
Cohesion: 0.28
Nodes (8): leaflet, maplibre-gl, @maplibre/maplibre-gl-leaflet, draw(), el, emit, icon(), props

### Community 4 - "StatsPanel.vue"
Cohesion: 0.20
Nodes (7): vue, emit, got, groups, missing, props, total

### Community 5 - "jsconfig.json"
Cohesion: 0.50
Nodes (3): compilerOptions, paths, exclude

### Community 6 - "dependencies"
Cohesion: 0.33
Nodes (6): dependencies, leaflet, maplibre-gl, @maplibre/maplibre-gl-leaflet, @supabase/supabase-js, vue

### Community 36 - "Stamps JP"
Cohesion: 0.33
Nodes (5): Configuración, Escalar a todo Japón, Fuentes del catálogo, Moderación, Stamps JP

### Community 45 - "scripts"
Cohesion: 0.50
Nodes (4): scripts, build, dev, preview

## Knowledge Gaps
- **57 isolated node(s):** `paths`, `exclude`, `name`, `version`, `private` (+52 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 100 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **37 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `vue` connect `StatsPanel.vue` to `App.vue`, `package.json`, `AddStamp.vue`, `StampMap.vue`?**
  _High betweenness centrality (0.167) - this node is a cross-community bridge._
- **What connects `paths`, `exclude`, `name` to the rest of the system?**
  _57 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `App.vue` be split into smaller, more focused modules?**
  _Cohesion score 0.08172043010752689 - nodes in this community are weakly interconnected._
- **Why does `dependencies` connect `dependencies` to `package.json`?**
  _High betweenness centrality (0.046) - this node is a cross-community bridge._
- **Should `package.json` be split into smaller, more focused modules?**
  _Cohesion score 0.14166666666666666 - nodes in this community are weakly interconnected._
- **Why does `scripts` connect `scripts` to `package.json`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._