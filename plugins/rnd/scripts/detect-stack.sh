#!/usr/bin/env bash
# detect-stack.sh [DIR] — polyglot stack detector for the rnd plugin.
# Scans DIR (default: $CLAUDE_PROJECT_DIR or .) for marker files and prints a JSON
# profile to stdout: detected stacks + best-guess build/test/run/lint commands.
# Pure bash + printf (no jq needed). Heuristic — /rnd:init refines it with the agent.
# Detection blocks run in priority order; the first stack to claim a command wins
# (so `commands` reflect the PRIMARY stack; `stacks` lists everything found).
set -u

DIR="${1:-${CLAUDE_PROJECT_DIR:-.}}"
cd "$DIR" 2>/dev/null || { echo "{\"error\":\"cannot cd to $DIR\"}"; exit 1; }
ROOT="$(pwd)"

stacks=(); markers=(); pm=""
build=""; test=""; run=""; lint=""

has()   { [ -e "$1" ]; }
glob1() { compgen -G "$1" >/dev/null 2>&1; }            # true if glob matches anything
setc()  { local n="$1"; shift; [ -z "${!n}" ] && printf -v "$n" '%s' "$*"; }  # set only if empty (primary wins)

# ---- Python ----
if has pyproject.toml || has setup.py || has setup.cfg || has Pipfile || has environment.yml || glob1 'requirements*.txt'; then
  stacks+=("python")
  for m in pyproject.toml setup.py Pipfile environment.yml; do has "$m" && markers+=("$m"); done
  if   has uv.lock; then pm="${pm:-uv}";
  elif has poetry.lock || grep -qs '\[tool.poetry\]' pyproject.toml; then pm="${pm:-poetry}";
  elif has pdm.lock; then pm="${pm:-pdm}";
  elif has Pipfile;  then pm="${pm:-pipenv}";
  elif has environment.yml; then pm="${pm:-conda}";
  else pm="${pm:-pip}"; fi
  setc test "pytest -q"
  if has ruff.toml || grep -qs '\[tool.ruff\]' pyproject.toml; then setc lint "ruff check ."; else setc lint "python -m flake8"; fi
  setc build "python -m build"
  setc run "python -m <module>   # see pyproject [project.scripts] / __main__"
fi

# ---- Node / JS / TS ----
if has package.json; then
  stacks+=("node"); markers+=("package.json")
  has tsconfig.json && { stacks+=("typescript"); markers+=("tsconfig.json"); }
  npm_pm="npm"
  if   has pnpm-lock.yaml; then npm_pm="pnpm"; elif has yarn.lock; then npm_pm="yarn"; elif has bun.lockb; then npm_pm="bun"; fi
  pm="${pm:-$npm_pm}"
  has_script() { grep -Eqs "\"$1\"[[:space:]]*:" package.json; }
  rp="$npm_pm run"; [ "$npm_pm" = "npm" ] && rp="npm run"
  has_script test  && setc test  "$npm_pm test"
  has_script build && setc build "$rp build"
  has_script lint  && setc lint  "$rp lint"
  if   has_script dev;   then setc run "$rp dev"
  elif has_script start; then setc run "$npm_pm start"; fi
fi

# ---- Go ----
if has go.mod; then
  stacks+=("go"); markers+=("go.mod"); pm="${pm:-go-modules}"
  setc build "go build ./..."; setc test "go test ./..."; setc run "go run ."
  if has .golangci.yml || has .golangci.yaml; then setc lint "golangci-lint run"; else setc lint "go vet ./..."; fi
fi

# ---- Rust ----
if has Cargo.toml; then
  stacks+=("rust"); markers+=("Cargo.toml"); pm="${pm:-cargo}"
  setc build "cargo build"; setc test "cargo test"; setc lint "cargo clippy --all-targets"; setc run "cargo run"
fi

# ---- C / C++ ----
if has CMakeLists.txt; then
  stacks+=("cpp"); markers+=("CMakeLists.txt"); pm="${pm:-cmake}"
  setc build "cmake -S . -B build && cmake --build build"; setc test "ctest --test-dir build"; setc run "./build/<target>"
elif has Makefile && { glob1 '*.c' || glob1 '*.cc' || glob1 '*.cpp' || glob1 '*.cxx' || glob1 'src/*.c' || glob1 'src/*.cpp'; }; then
  stacks+=("cpp"); markers+=("Makefile"); pm="${pm:-make}"
  setc build "make"; setc test "make test"
fi

# ---- Java / JVM ----
if has pom.xml; then
  stacks+=("java"); markers+=("pom.xml"); pm="${pm:-maven}"
  setc build "mvn -q -DskipTests package"; setc test "mvn -q test"; setc run "mvn -q exec:java"
elif has build.gradle || has build.gradle.kts; then
  stacks+=("java"); markers+=("build.gradle"); pm="${pm:-gradle}"
  gw="gradle"; has gradlew && gw="./gradlew"
  setc build "$gw build"; setc test "$gw test"; setc run "$gw run"
fi

# ---- Robotics / Sim (additive flags) ----
if has package.xml || glob1 '*/package.xml' || glob1 '*.urdf' || glob1 '*/*.urdf'; then
  stacks+=("ros"); setc run "ros2 launch <pkg> <launch>   # or roslaunch"
fi
if grep -rIlsq -e mujoco -e mjcf -e mjlab -e isaaclab --include='*.py' --include='*.toml' . 2>/dev/null; then
  stacks+=("robotics-sim")
fi

# ---- emit JSON ----
esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }
json_arr() { local out="" x; for x in "$@"; do [ -z "$x" ] && continue; out="$out,\"$(esc "$x")\""; done; printf '[%s]' "${out#,}"; }

uniq_stacks=(); for s in "${stacks[@]:-}"; do [ -z "$s" ] && continue
  case " ${uniq_stacks[*]:-} " in *" $s "*) ;; *) uniq_stacks+=("$s");; esac; done
primary="${uniq_stacks[0]:-unknown}"

printf '{\n'
printf '  "root": "%s",\n' "$(esc "$ROOT")"
printf '  "stacks": %s,\n' "$(json_arr "${uniq_stacks[@]:-}")"
printf '  "primary": "%s",\n' "$primary"
printf '  "package_manager": "%s",\n' "$(esc "$pm")"
printf '  "markers": %s,\n' "$(json_arr "${markers[@]:-}")"
printf '  "commands": {\n'
printf '    "build": "%s",\n' "$(esc "$build")"
printf '    "test": "%s",\n'  "$(esc "$test")"
printf '    "run": "%s",\n'   "$(esc "$run")"
printf '    "lint": "%s"\n'   "$(esc "$lint")"
printf '  },\n'
printf '  "note": "heuristic; /rnd:init refines via the explorer agent + repo README/CI/monorepo subdirs"\n'
printf '}\n'
