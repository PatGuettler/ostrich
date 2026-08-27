# Dashers

Dashers is a monorepo for a family of independent Godot runner games. Each game owns its project settings, source, assets, tests, build output, and release documentation inside one top-level directory.

## Games

| Game | Project directory | Status |
| --- | --- | --- |
| Ostrich Dash | [`ostrich-dash/`](ostrich-dash/) | Full game with Android and Google Play delivery |
| Penguin Dash | [`penguin-dash/`](penguin-dash/) | In development |

Open a game by pointing Godot at that game's directory:

```bash
godot --editor --path /home/pat/dev/dashers/ostrich-dash
godot --editor --path /home/pat/dev/dashers/penguin-dash
```

## Repository layout

```text
dashers/
├── .github/workflows/                 # Per-game CI workflows
├── ostrich-dash/                      # Complete Ostrich Dash Godot project
│   └── project.godot
├── penguin-dash/                      # Complete Penguin Dash Godot project
│   └── project.godot
└── README.md
```

New games should follow the same boundary: one directory, one `project.godot`, no resource paths that reach into another game, and a separately named release workflow when the game is ready to ship.
