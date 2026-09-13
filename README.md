# Catrix for Windows 🐈‍⬛

Matrix-style falling cat faces in your PowerShell terminal. Like `cmatrix`,
but cats — random cat faces rain down in columns, default color **green**.

Needs **PowerShell 7+** (for the Unicode cat faces):
`winget install Microsoft.PowerShell`

## Install

```powershell
irm https://raw.githubusercontent.com/Goplop0959/Catrix-Windows/refs/heads/master/Install.ps1 | iex
```

Installs to `%LOCALAPPDATA%\Catrix`, adds it to your user `PATH` (restart
your terminal), and gives you the `catrix` command. No admin needed.

## Usage

```powershell
catrix                  # green rain (default)
catrix -Color magenta   # green red blue white yellow magenta cyan
catrix -NoBold          # plain head faces (bold is default on)
catrix -Delay 50        # frame delay in ms (default 21, lower = faster)
catrix -Density 90      # percent of columns raining 0-100 (default 70)
catrix -Update          # re-download + reinstall latest
```

### Keys

| Key         | Action                    |
|-------------|---------------------------|
| `q` / `Esc` | quit                      |
| `space`     | pause / resume            |
| `+` / `-`   | faster / slower           |
| `c`         | cycle rain color          |
| `b`         | toggle bold heads         |
| `Ctrl+C`    | quit (terminal restored)  |

## Faces

Same set as the Debian edition — see [faces.txt](faces.txt) (entries
separated by `\n:|:\n`). Sources: the
[cat-ascii-faces](https://github.com/melaniecebula/cat-ascii-faces) collection
(MIT) plus community combos from [emojicombos.com](https://emojicombos.com)
(including the cat with a gun `(=ↀωↀ=)▄︻┻┳═一`).

## Credits

- *The Matrix Resurrections* (2021) — red pill, blue pill, cat pill.
- `cmatrix` — the original falling-text screensaver.
- [melaniecebula/cat-ascii-faces](https://github.com/melaniecebula/cat-ascii-faces) — face collection (MIT).
- emojicombos.com contributors — combo faces.
- Sister project: [Catrix (Debian)](https://github.com/Goplop0959/catrix) —
  signed apt package with `catrix update`.

## License

MIT — see [LICENSE](LICENSE).
