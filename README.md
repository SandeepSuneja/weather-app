# Weatherly — Interactive Weather App

A single-page **Angular** weather dashboard that lets you search for cities, view current conditions, a **12-hour** forecast, a **5-day** outlook, and **air quality** data. The UI supports **English**, **हिन्दी (Hindi)**, and **日本語 (Japanese)**, and can **save favorite locations** in your browser (local storage).

**You can run and use this project for free.** All weather, geocoding, and air-quality data come from **[Open-Meteo](https://open-meteo.com/)** public APIs. **No API key, account, or paid subscription is required** for normal personal use. (Open-Meteo publishes [fair use guidelines](https://open-meteo.com/en/terms) on their site; avoid hammering their servers with excessive automated traffic.)

---

## What this project does

| Area | Details |
|------|---------|
| **Search** | Type a city name; suggestions come from Open-Meteo geocoding. |
| **Current weather** | Temperature, feels-like, humidity, wind, pressure, clouds, dew point, precipitation, UV, and condition labels. |
| **Hourly** | Next **12 hours** with a simple temperature chart and precipitation chance. |
| **Daily** | **5 days** with min/max temps, rain chance, UV, wind, sunrise/sunset. |
| **Air quality** | US AQI and pollutants (when the API returns them). |
| **Saved locations** | Store places locally and refresh them together from the side panel. |
| **Language** | UI strings switch with `I18nService` and the translate pipe. |
| **Look & feel** | Theme and background media react to the active weather condition. |

---

## Prerequisites

Install these on your machine before cloning the repo:

1. **[Node.js](https://nodejs.org/)** — **v20.x LTS** is what this repo’s GitHub Actions workflow uses. Newer LTS versions often work with Angular 20, but if you see install or build errors, switch to Node 20.
2. **npm** — Bundled with Node.js (use the version that ships with your Node install).
3. **Google Chrome** (or Chromium) — Required for **unit tests** (`npm test`), which run in **ChromeHeadless** by default.

Optional but useful:

- **[Angular CLI](https://angular.dev/tools/cli)** — You can run everything via `npx` and the local CLI from `node_modules`, so a global `ng` install is not mandatory.

---

## Clone and install

Open a terminal in the folder where you keep projects, then:

```bash
git clone <your-fork-or-repo-url> weather-app
cd weather-app
npm install
```

- **`npm install`** reads `package.json` and `package-lock.json`, downloads dependencies into `node_modules`, and may take a minute the first time.

If you prefer a clean, reproducible install (same as CI), use:

```bash
npm ci
```

Use **`npm ci`** only when `package-lock.json` is present and you are not changing dependency versions; it removes `node_modules` and installs exactly what the lockfile specifies.

---

## Environment variables and API keys

**None.** The app calls Open-Meteo over HTTPS from the browser. You do **not** need `.env` files or secret keys for the features shipped in this repository.

---

## Commands (npm scripts)

All commands below are run from the **project root** (`weather-app/`), where `package.json` lives.

### Start the development server

```bash
npm start
```

This runs **`ng serve`** (Angular dev server). By default the app is available at:

**http://localhost:4200/**

The server reloads when you edit source files. Stop it with `Ctrl+C` in the terminal.

**Useful `ng serve` variants** (via `npx` so you use the project’s CLI version):

```bash
npx ng serve --open
```

Opens your default browser automatically.

```bash
npx ng serve --host 0.0.0.0 --port 4200
```

Listen on all interfaces (helpful when testing from a phone on the same network).

### Production build

```bash
npm run build
```

Runs **`ng build`** with the default configuration (in this project, **production** is the default for `build` in `angular.json`). Output goes under:

**`dist/interactive-weather-app/browser/`**

(Angular’s **application** builder places the browser bundle in the `browser` subfolder.)

Explicit production build (same idea as CI):

```bash
npm run build:prod
```

Or, matching the GitHub workflow exactly:

```bash
npm run build -- --configuration production
```

To **preview** a production build locally:

```bash
npx ng serve --configuration production
```

### Development build with watch mode

```bash
npm run watch
```

Runs **`ng build --watch --configuration development`**: rebuilds on file changes; useful when integrating with another tool that serves the `dist` output.

### Unit tests (Karma + Jasmine)

```bash
npm test
```

Runs **`ng test`** with:

- **`--no-watch`** — single run, then exit  
- **`--browsers=ChromeHeadless`** — no GUI window  
- **`--code-coverage`** — coverage reports under **`coverage/`**

If Chrome is not found, install Chrome or adjust `karma.conf.js` / your `PATH` so Karma can launch ChromeHeadless.

**Interactive test run** (watch mode, often opens a real Chrome window):

```bash
npx ng test
```

(Press `Ctrl+C` to stop.)

---

## How to use the app (after `npm start`)

1. Open **http://localhost:4200/**.
2. Use the **search** field: enter a city, pick a suggestion if needed, then load weather.
3. Switch **language** from the header if you want Hindi or Japanese labels.
4. **Save** a location to keep it in the side panel; open the panel to refresh or remove saved places.

Saved data lives in **browser local storage** (key like `saved-weather-locations-v1`), not on a server.

---

## CI/CD (reference)

The workflow in **`.github/workflows/ci-cd.yml`** runs on pushes and pull requests to **`main`**:

| Step | Command |
|------|---------|
| Install | `npm ci` |
| Build | `npm run build -- --configuration production` |
| Test | `npm test` |

An optional **AWS S3** deploy job runs only when repository variables/secrets are configured; you can ignore it for local-only use.

---

## Tech stack (short)

- **Angular 20** (standalone components, SCSS)
- **RxJS** for async data flow
- **Open-Meteo** — forecast, air quality, geocoding
- **Karma + Jasmine** for unit tests

---

## Troubleshooting

| Issue | What to try |
|--------|----------------|
| `npm install` errors | Use Node 20; delete `node_modules` and `package-lock.json` only if you know you need to regenerate the lockfile (prefer fixing Node version first). |
| Port 4200 in use | `npx ng serve --port 4300` |
| Tests fail (Chrome) | Install Chrome; on Linux CI, Chrome is installed explicitly — mirror that locally or point Karma to your Chromium binary. |
| Empty air quality | Some regions return sparse fields; the UI handles missing AQI gracefully. |
| CORS errors in dev | Unusual for Open-Meteo from the browser; check network extensions or corporate proxies. |

---

## License

This README does not set a license for the project. If you add one, place it in a `LICENSE` file in the repository root and mention it here.
