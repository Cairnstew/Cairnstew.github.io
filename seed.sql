-- Seed rows mirroring the committed content files in content/
-- (regenerate with:  python3 render.py --db cv.db --content-dir content).
--
-- load with:  sqlite3 cv.db < seed.sql   (after mcp_server.py created the
-- schema), or run mcp_server.py once then render.py against this file.
--
-- Everything here is published = 1 (live site content).
-- Facts grounded in Sean's own resumes / AWS certificates; anything personal
-- (phone, email, tax/transcript data, third-party references) is deliberately
-- NOT in this file.

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
   'Used professionally for data work (Pandas) and web apps (Django) at an Austin research firm, and in published projects: uup-builder (Windows ISO tooling), uup-dump-api-py, comfyscripting, nixos-deploy-tool, and the SQLite-backed MCP tooling behind this site.',
   4, 1),
  ('Data science & machine learning', 'Data', 'Intermediate',
   'MSc Big Data Technologies coursework plus AWS Skill Builder courses (Fundamentals of Machine Learning and AI; Exploring AI Use Cases and Applications). Hands-on analytics: applied AI/ML coursework, the MyPossibilities capstone, and sports analytics (sports-ml).',
   5, 1),
  ('Data visualization (Power BI & Tableau)', 'Data', 'Intermediate',
   'Built an interactive Power BI dashboard for the MyPossibilities capstone and automated Tableau reports and dashboards for the Dripping Springs Art League — membership trends, engagement patterns, and social media impact.',
   6, 1),
  ('SQL & databases (SQL, MongoDB)', 'Data', 'Intermediate',
   'Designed and managed a MongoDB database for property records at Tres Reynas, and used SQL with Pandas for data cleaning and transformation in capstone and volunteer analytics work.',
   7, 1),
  ('CI/CD & developer tooling', 'Programming', 'Intermediate',
   'GitHub Actions pipelines (Nix builds, GitHub Pages deployments, flake checks), flake-parts development shells, packwiz modpack tooling pipelines, and reproducible dev environments for VS Code, Jupyter, Ollama, and Docker.',
   8, 1),
  ('Minecraft modding (NeoForge / Fabric)', 'Game Development', 'Intermediate',
   'Minecraft mod development (tutorialmod, ProceduralDynamicTrees) and large-scale packwiz modpack administration for custom dedicated servers.',
   9, 1);

INSERT INTO experience (role, organization, start_year, end_year, description, url, sort_order, published) VALUES
  ('Data Analyst & Research Intern', 'Tres Reynas at Nutty Brown LLC', 2024, 2025,
   'Built a property-based web application in Django that integrates historical records with GIS tools to support municipal research.\n\n- Designed and managed a MongoDB database for efficient property-record storage and retrieval\n- Automated data-processing workflows in Python, improving research efficiency and data accessibility\n- Research-backed data insights on ownership and development histories, working directly with the CEO',
   'https://tresreynasatnuttybrown.com', 1, 1),
  ('Nix ecosystem tooling (open source author)', 'Independent / open source', 2023, NULL,
   'Author of public Nix tooling that powers a personal multi-host fleet:\n\n- agenix-manager — declarative agenix secret management (NixOS module + TUI)\n- tailscale-manager — Tailscale auth-key management (NixOS module + CLI)\n- dscnix — Nix to DSC translation\n- nixos-deploy-tool, my-flake-templates, compose2nix-flake, uup tooling',
   'https://github.com/Cairnstew', 2, 1),
  ('MSc Big Data Technologies', 'Glasgow Caledonian University', 2026, 2027,
   'Postgraduate study in big data technologies (School of Computing, Engineering & Built Environment; accredited by BCS, ACM, IEEE, QAA). Modules include Cloud Computing & Web Services, IoT, Big Data Platforms, Data Visualisation, Big Data Landscape, Software Development for Data Science, AI & Machine Learning, and Data Ethics & Research Methods — plus a 60-credit dissertation.',
   '', 3, 1),
  ('BSc, Business Analytics & Artificial Intelligence', 'The University of Texas at Dallas', 2020, 2025,
   'Bachelor of Science in Business Analytics and AI: data analytics, machine learning, business intelligence, and applied statistical modelling, capped by a survey-analytics capstone project for a local non-profit.',
   '', 4, 1),
  ('Data Analyst Team Lead (Capstone)', 'MyPossibilities', 2024, 2024,
   'Led a team of eight, including international partners from Sheffield Hallam University, to deliver an interactive Power BI dashboard analysing 2023 survey data for a non-profit serving people with intellectual and developmental disabilities.\n\n- Automated data cleaning and transformation in Python (Pandas, SQL)\n- Presented actionable insights and recommendations to stakeholders',
   'https://mypossibilities.org', 5, 1),
  ('Academic group projects (DevOps & cloud/web)', 'Glasgow Caledonian University', 2026, NULL,
   'Collaborative group coursework alongside the MSc: version-controlled team repositories covering software-engineering DevOps practice (SE DevOps Coursework 1 & 2) and cloud & web services coursework.',
   'https://github.com/Cairnstew/SE-DevOps-Coursework-1', 6, 1),
  ('Volunteer Analyst', 'Dripping Springs Art League', 2024, 2025,
   'Automated Tableau reports and visualisations tracking membership trends, event participation, and growth; built maps and dashboards analysing member engagement, registration patterns, and social media impact; assessed Founding Circle membership benefits.',
   'https://artindripping.com', 7, 1),
  ('Game server administration', 'Self-hosted infrastructure', 2023, NULL,
   'Declarative Minecraft, Satisfactory, and Project Zomboid dedicated servers on NixOS, with packwiz-managed modpacks and shipped player defaults — reproducible, Nix-built infrastructure for community servers.',
   'https://github.com/Cairnstew', 8, 1);

INSERT INTO hobbies (name, description, sort_order, published) VALUES
  ('Minecraft modding & modpacks',
   'Mod development for NeoForge and Fabric, plus building and shipping large packwiz modpacks with shipped configs, datapacks, and keybinding defaults.', 1, 1),
  ('3D printing & digital fabrication',
   'CAD work in FreeCAD and CADQuery, print projects, and terrain generation with Gaea.', 2, 1),
  ('Digital art & VFX pipelines',
   'Houdini addon development (PXL-Render), ComfyUI / Stable Diffusion workflows, and procedural VFX.', 3, 1),
  ('Game development',
   'Godot experiments (game-template, Card-Assets) with procedural generation and asset pipelines.', 4, 1);