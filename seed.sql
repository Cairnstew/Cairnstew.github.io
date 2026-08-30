-- Seed rows mirroring the committed content files in content/
-- (regenerate with:  python3 render.py --db cv.db --content-dir content).
--
-- load with:  sqlite3 cv.db < seed.sql   (after mcp_server.py created the
-- schema), or run mcp_server.py once then render.py against this file.
--
-- Everything here is published = 1 (live site content).

INSERT INTO skills (name, category, proficiency, description, sort_order, published) VALUES
  ('Nix / NixOS', 'Systems', 'Advanced',
   'Long-standing personal NixOS configuration ([Cairnstew/nixos-config](https://github.com/Cairnstew/nixos-config)) — a multi-host fleet (laptop, desktop, server, WSL) built on flake-parts and nixos-unified, with Home Manager and agenix secrets. Also several published Nix tooling repos: agenix-manager, tailscale-manager, dscnix, my-flake-templates, compose2nix-flake, uup-converter.',
   1, 1),
  ('NixOS module & tooling development', 'Systems', 'Advanced',
   'Author of published NixOS modules and tools: agenix-manager (declarative agenix secret management — NixOS module + TUI CLI), tailscale-manager (NixOS module + CLI managing Tailscale auth keys via Terraform), and dscnix (Nix → DSC tooling).',
   2, 1),
  ('Linux administration & self-hosted infrastructure', 'Systems', 'Advanced',
   'Runs a private NixOS fleet: laptops, a desktop workstation, a headless server, and WSL instances. Self-hosted services include declarative Minecraft / Satisfactory / Project Zomboid game servers, packwiz modpack pipelines, Tailscale networking, and CI deployments via GitHub Actions.',
   3, 1),
  ('Python', 'Programming', 'Intermediate',
   'Published Python projects: uup-builder (Windows ISO creation and customization), uup-dump-api-py (API wrapper), comfyscripting / comfyscripting-code-server (ComfyUI scripting environments), nixos-deploy-tool, and the SQLite-backed MCP tooling behind this site.',
   4, 1),
  ('Data science & machine learning', 'Data', 'Intermediate',
   'MSc Big Data Technologies coursework plus earlier analytics coursework — business analytics, advanced big-data analytics, and applied AI/ML — with group projects in sports analytics (sports-ml) and applied machine learning (ITSS-4382).',
   5, 1),
  ('CI/CD & developer tooling', 'Programming', 'Intermediate',
   'GitHub Actions pipelines (Nix builds, GitHub Pages deployments, flake checks), flake-parts development shells, packwiz modpack tooling pipelines, and reproducible dev environments for VS Code, Jupyter, and Ollama.',
   6, 1),
  ('Minecraft modding (NeoForge / Fabric)', 'Game Development', 'Intermediate',
   'Minecraft mod development (tutorialmod, ProceduralDynamicTrees) and large-scale packwiz modpack administration for custom dedicated servers.',
   7, 1);

INSERT INTO experience (role, organization, start_year, end_year, description, url, sort_order, published) VALUES
  ('Nix ecosystem tooling (open source author)', 'Independent / open source', 2023, NULL,
   'Author of public Nix tooling that powers a personal multi-host fleet:

- agenix-manager — declarative agenix secret management (NixOS module + TUI)
- tailscale-manager — Tailscale auth-key management (NixOS module + CLI)
- dscnix — Nix to DSC translation
- nixos-deploy-tool, my-flake-templates, compose2nix-flake, uup tooling',
   'https://github.com/Cairnstew', 1, 1),
  ('MSc Big Data Technologies', 'Glasgow Caledonian University', 2026, 2027,
   'Postgraduate study in big data technologies (School of Computing, Engineering & Built Environment; accredited by BCS, ACM, IEEE, QAA). Modules include Cloud Computing & Web Services, IoT, Big Data Platforms, Data Visualisation, Big Data Landscape, Software Development for Data Science, AI & Machine Learning, and Data Ethics & Research Methods — plus a 60-credit dissertation.',
   '', 2, 1),
  ('Academic group projects (DevOps & cloud/web)', 'Glasgow Caledonian University', 2026, NULL,
   'Collaborative group coursework alongside the MSc: version-controlled team repositories covering software-engineering DevOps practice (SE DevOps Coursework 1 & 2) and cloud & web services coursework.',
   'https://github.com/Cairnstew/SE-DevOps-Coursework-1', 3, 1),
  ('Game server administration', 'Self-hosted infrastructure', 2023, NULL,
   'Declarative Minecraft, Satisfactory, and Project Zomboid dedicated servers on NixOS, with packwiz-managed modpacks and shipped player defaults — reproducible, Nix-built infrastructure for community servers.',
   'https://github.com/Cairnstew', 4, 1);

INSERT INTO hobbies (name, description, sort_order, published) VALUES
  ('Minecraft modding & modpacks',
   'Mod development for NeoForge and Fabric, plus building and shipping large packwiz modpacks with shipped configs, datapacks, and keybinding defaults.', 1, 1),
  ('3D printing & digital fabrication',
   'CAD work in FreeCAD and CADQuery, print projects, and terrain generation with Gaea.', 2, 1),
  ('Digital art & VFX pipelines',
   'Houdini addon development (PXL-Render), ComfyUI / Stable Diffusion workflows, and procedural VFX.', 3, 1),
  ('Game development',
   'Godot experiments (game-template, Card-Assets) with procedural generation and asset pipelines.', 4, 1);