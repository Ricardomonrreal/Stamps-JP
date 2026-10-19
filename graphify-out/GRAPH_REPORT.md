# Graph Report - Stamps-JP  (2026-10-19)

## Corpus Check
- Corpus is ~1,844 words - fits in a single context window. You may not need a graph.

## Summary
- 104 nodes · 80 edges · 45 communities (8 shown, 37 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Vue Components
- Database & Auth
- Build & Config
- Graphify Tools
- Project Features
- Locations & Data
- Community 6
- Community 7

## God Nodes (most connected - your core abstractions)
1. `vue` - 6 edges
2. `scripts` - 4 edges
3. `popup()` - 3 edges
4. `supabase` - 3 edges
5. `compilerOptions` - 2 edges
6. `@supabase/supabase-js` - 2 edges
7. `leaflet` - 2 edges
8. `@vitejs/plugin-vue` - 2 edges
9. `vite` - 2 edges
10. `vite-plugin-vue-devtools` - 2 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Stamps JP Technology Stack** — stamps_jp_project, vue_framework, leaflet_library, supabase_service, vercel_service [0.95]
- **graphify Query Commands** — graphify_query_command, graphify_path_command, graphify_explain_command, graphify_knowledge_graph [0.95]
- **Project Configuration** — stamps_jp_project, env_example_file, env_local_file, supabase_schema_sql [0.9]
- **PWA Setup** — pwa_technology, icon_svg, manifest_webmanifest, index_html [0.9]

## Communities (45 total, 37 thin omitted)

### Community 0 - "Vue Components"
Cohesion: 0.12
Nodes (11): collected, draft, email, loadStamps(), mapRef, msg, onAdded(), picking (+3 more)

### Community 1 - "Database & Auth"
Cohesion: 0.14
Nodes (13): engines, node, name, private, scripts, build, dev, preview (+5 more)

### Community 2 - "Build & Config"
Cohesion: 0.28
Nodes (7): @supabase/supabase-js, emit, error, form, props, submit(), supabase

### Community 3 - "Graphify Tools"
Cohesion: 0.38
Nodes (6): leaflet, draw(), el, emit, popup(), props

### Community 4 - "Project Features"
Cohesion: 0.33
Nodes (4): vue, groups, missing, props

### Community 5 - "Locations & Data"
Cohesion: 0.50
Nodes (3): compilerOptions, paths, exclude

### Community 6 - "Community 6"
Cohesion: 0.50
Nodes (4): dependencies, leaflet, @supabase/supabase-js, vue

### Community 7 - "Community 7"
Cohesion: 0.50
Nodes (4): devDependencies, vite, vite-plugin-vue-devtools, @vitejs/plugin-vue

## Knowledge Gaps
- **33 isolated node(s):** `paths`, `exclude`, `name`, `version`, `private` (+28 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 76 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **37 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `vue` connect `Project Features` to `Vue Components`, `Database & Auth`, `Build & Config`, `Graphify Tools`?**
  _High betweenness centrality (0.156) - this node is a cross-community bridge._
- **What connects `paths`, `exclude`, `name` to the rest of the system?**
  _33 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Vue Components` be split into smaller, more focused modules?**
  _Cohesion score 0.125 - nodes in this community are weakly interconnected._
- **Why does `dependencies` connect `Community 6` to `Database & Auth`?**
  _High betweenness centrality (0.034) - this node is a cross-community bridge._
- **Should `Database & Auth` be split into smaller, more focused modules?**
  _Cohesion score 0.14166666666666666 - nodes in this community are weakly interconnected._