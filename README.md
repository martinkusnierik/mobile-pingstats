# mobile-pingstats

`mobile-pingstats` je jednotný, multiplatformový nástroj na meranie odozvy siete
a zbieranie ping štatistík na mobilných zariadeniach.

Podporované platformy:

- **iOS (iSH / Alpine Linux)**
- **Android (Termux)**

Cieľom projektu je poskytovať rovnaké správanie, rovnaké logy a rovnaké CLI
rozhranie na oboch platformách, s minimálnou údržbou zdrojového kódu.

---

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