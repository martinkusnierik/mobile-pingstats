# mobile-pingstats

`mobile-pingstats` je jednotný, multiplatformový nástroj na meranie odozvy siete
a zbieranie ping štatistík na mobilných zariadeniach.

Podporované platformy:

- **iOS (iSH / Alpine Linux)**
- **Android (Termux)**

Cieľom projektu je poskytovať rovnaké správanie, rovnaké logy a rovnaké CLI
rozhranie na oboch platformách, s minimálnou údržbou zdrojového kódu.

---

## Badges

![License](https://img.shields.io/badge/License-EUPL_1.2-blue)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Android-lightgrey)

![Repo Size](https://img.shields.io/github/repo-size/martinkusnierik/mobile-pingstats?color=blue)
![Last Commit](https://img.shields.io/github/last-commit/martinkusnierik/mobile-pingstats?logo=github&color=blue)
![Issues](https://img.shields.io/github/issues/martinkusnierik/mobile-pingstats?color=green)
![Pull Requests](https://img.shields.io/github/issues-pr/martinkusnierik/mobile-pingstats?color=orange)

![Stars](https://img.shields.io/github/stars/martinkusnierik/mobile-pingstats?style=social)
![Forks](https://img.shields.io/github/forks/martinkusnierik/mobile-pingstats?style=social)

![Shell](https://img.shields.io/badge/Shell-Bash-121011?logo=gnu-bash&logoColor=white)

## ✨ Funkcie

- Cisco‑style indikátory odozvy (`! . U N ?`)
- Logovanie do timestampovaných súborov
- Štatistiky: min/max/avg, počty timeoutov
- Rovnaké CLI rozhranie na iOS aj Android
- Modulárna architektúra:
  - spoločná logika (`scripts/`)
  - platformové adaptéry (`platform/ish/`, `platform/termux/`)
  - autodetekčný wrapper (`bin/pingstats`)

---

## 📦 Inštalácia

### iOS (iSH / Alpine Linux)

```
apk update
apk add iputils
```

### Android (Termux)

```
pkg update -y
pkg install -y iputils
```

---

## 🚀 Použitie

Spustenie nástroja:

```
./bin/pingstats
```

Wrapper automaticky zistí platformu a načíta správny adapter.

Voliteľný alias:

```
alias pingstats="$PWD/bin/pingstats"
```

---

## 🗂 Štruktúra projektu

```
mobile-pingstats/
│
├── bin/
│   └── pingstats
│
├── scripts/
│   ├── shared_stats.sh
│   └── pingstats_core.sh
│
├── platform/
│   ├── ish/
│   │   ├── ping_adapter.sh
│   │   └── install.sh
│   └── termux/
│       ├── ping_adapter.sh
│       └── install.sh
│
└── README.md
```

---

## 🧩 Architektúra

### Core (`scripts/`)
Obsahuje hlavnú logiku pingovania, parsovanie, štatistiky a logovanie.
Je úplne nezávislá od platformy.

### Platform adapters (`platform/.../ping_adapter.sh`)
Riešia rozdiely medzi iSH a Termuxom:

- výstup `ping`
- chybové hlášky
- balíčky a inštaláciu

### Wrapper (`bin/pingstats`)
Zistí platformu a spustí core s príslušným adapterom.

---

## 📄 Licencia

Tento projekt je licencovaný pod European Union Public License v1.2 (EUPL 1.2).  
Pozri súbory `LICENSE` a `COPYRIGHT` pre viac informácií.