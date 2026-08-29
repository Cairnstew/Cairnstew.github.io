-- Seed rows mirroring the DRAFT content files committed in content/
-- (Tier 1 A2). Everything is published = 0 (draft) pending human review.
--
-- load with:  sqlite3 cv.db < seed.sql   (after mcp_server.py created the
-- schema), or simply run mcp_server.py once then render.py against this file.
--
-- These rows let render.py be exercised end-to-end without the MCP server
-- and give a fresh clone a way to regenerate the committed content files.

INSERT INTO skills (name, category, proficiency, description, sort_order, published) VALUES
  ('Nix / NixOS', 'Systems', 'Advanced',
   'Long-standing personal NixOS configuration (Cairnstew/nixos-config) and several published Nix tooling repos (agenix-manager, tailscale-manager, dscnix, my-flake-templates).',
   1, 0),
  ('NixOS module development', 'Systems', 'Advanced',
   'Author of public NixOS modules: agenix-manager (NixOS module + TUI CLI), tailscale-manager (NixOS module + CLI), and the dscnix Nix→DSC tooling.',
   2, 0),
  ('Python', 'Programming', 'Intermediate',
   'Public Python projects: uup-builder (Windows ISO tooling), uup-dump-api-py, comfyscripting(-code-server).',
   3, 0),
  ('Minecraft modding (NeoForge / Fabric)', 'Game Development', 'Intermediate',
   'Minecraft mod development (tutorialmod, ProceduralDynamicTrees, dynamic-trees support work) and large packwiz modpack administration.',
   4, 0),
  ('Data analysis / machine learning', 'Data', 'Intermediate',
   'MSc Big Data Technologies coursework: advanced big-data analytics, business analytics, applied AI/ML, and group data projects (sports-ml, ITSS-4382 Applied AI/ML).',
   5, 0);

INSERT INTO experience (role, organization, start_year, end_year, description, url, sort_order, published) VALUES
  ('Nix ecosystem tooling (open source author)', 'Independent / open source', 2023, NULL,
   'Author of public Nix tooling: agenix-manager, tailscale-manager, dscnix, nixos-deploy-tool, my-flake-templates, uup tooling.',
   'https://github.com/Cairnstew', 1, 0),
  ('MSc Big Data Technologies', 'Glasgow Caledonian University', 2021, 2024,
   'Postgraduate study in big data technologies: advanced database management, business analytics, applied AI/ML, big-data analytics coursework.',
   '', 2, 0),
  ('DevOps coursework (group projects)', 'GCU DevOps modules', 2023, NULL,
   'Group coursework repos: SE DevOps Coursework 1 & 2, CCWS coursework 1.',
   'https://github.com/Cairnstew/SE_DevOps_Group_4_Coursework_2', 3, 0),
  ('Game server administration', 'Self-hosted infrastructure', 2023, NULL,
   'Declarative Minecraft and Satisfactory dedicated servers on NixOS (minecraft-nix-server, Satisfactory-Server-Nix), modpack management via packwiz, and Project Zomboid server tooling.',
   'https://github.com/Cairnstew/minecraft-nix-server', 4, 0);

INSERT INTO hobbies (name, description, sort_order, published) VALUES
  ('Minecraft modding & modpacks',
   'Mod development (NeoForge/Fabric) and large packwiz modpack administration.', 1, 0),
  ('3D printing & digital fabrication',
   'CAD work (FreeCAD, CADQuery), 3DPrint projects, Gaea terrain.', 2, 0),
  ('Digital art & VFX pipelines',
   'Houdini addon development, ComfyUI / Stable Diffusion workflows, Gaea.', 3, 0),
  ('Game development',
   'Godot games (game-template, Card-Assets), procedural generation.', 4, 0);