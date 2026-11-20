#!/usr/bin/env bash
# Cherche une nouvelle version publiée de Ramille ou de LocalePilot et met le cask à jour.
# Lancé deux fois par jour par .github/workflows/update-casks.yml ; utilisable à la main.
# Ne fait ni commit ni push. Nécessite `gh` (connecté, ou GH_TOKEN) et curl.
#
# Garde de sécurité : le cask n'est modifié que si la dernière release GitHub ET le fichier de mises à jour
# (appcast Sparkle) annoncent la même version. Si le système minimal change, le script s'arrête en erreur
# sans rien modifier : le cask demande alors une relecture humaine.
set -euo pipefail
cd "$(dirname "$0")/.."

RAMILLE_APPCAST_URL="${RAMILLE_APPCAST_URL:-https://ramille.app/updates/appcast.xml}"
LOCALEPILOT_APPCAST_URL="${LOCALEPILOT_APPCAST_URL:-https://localepilot.app/updates/appcast.xml}"
status=0

macos_name() {
  case "$1" in
    11) echo bigsur ;; 12) echo monterey ;; 13) echo ventura ;; 14) echo sonoma ;;
    15) echo sequoia ;; 26) echo tahoe ;; *) echo "inconnu-$1" ;;
  esac
}

check() {
  local app="$1" repo="$2" appcast_url="$3"
  local cask="Casks/${app}.rb" tag version build new current feed short feed_build minmac cask_mac

  tag="$(gh api "repos/${repo}/releases/latest" --jq .tag_name)"
  if [ "$app" = "ramille" ]; then
    [[ "$tag" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)-b([0-9]+)$ ]] || { echo "${app} : tag inattendu « ${tag} », rien changé." >&2; status=1; return; }
    version="${BASH_REMATCH[1]}"; build="${BASH_REMATCH[2]}"; new="${version},${build}"
  else
    [[ "$tag" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)$ ]] || { echo "${app} : tag inattendu « ${tag} », rien changé." >&2; status=1; return; }
    version="${BASH_REMATCH[1]}"; build=""; new="$version"
  fi

  current="$(sed -nE 's/^  version "(.*)"/\1/p' "$cask" | head -1)"
  if [ "$new" = "$current" ]; then echo "${app} : à jour (${current})."; return; fi
  if [ "$(printf '%s\n%s\n' "$new" "$current" | sort -V | head -1)" = "$new" ]; then
    echo "${app} : la release publiée (${new}) est plus ancienne que le cask (${current}), rien changé." >&2; status=1; return
  fi

  feed="$(curl -fsSL "$appcast_url")"
  short="$(printf '%s' "$feed" | sed -nE 's/.*<sparkle:shortVersionString>([^<]*)<.*/\1/p' | head -1)"
  feed_build="$(printf '%s' "$feed" | sed -nE 's/.*<sparkle:version>([^<]*)<.*/\1/p' | head -1)"
  if [ "$short" != "$version" ] || { [ "$app" = "ramille" ] && [ "$feed_build" != "$build" ]; }; then
    echo "${app} : la release GitHub est ${new} mais le fichier de mises à jour annonce ${short},${feed_build} : en attente, cask inchangé."
    return
  fi

  minmac="$(printf '%s' "$feed" | sed -nE 's/.*<sparkle:minimumSystemVersion>([0-9]+)[^<]*<.*/\1/p' | head -1)"
  cask_mac="$(sed -nE 's/^  depends_on macos: :([a-z]+).*/\1/p' "$cask" | head -1)"
  if [ "$(macos_name "$minmac")" != "$cask_mac" ]; then
    echo "${app} : le système minimal annoncé (macOS ${minmac}) ne correspond plus au cask (:${cask_mac}). Relecture humaine nécessaire, cask inchangé." >&2
    status=1; return
  fi

  echo "${app} : nouvelle version ${current} -> ${new}, mise à jour du cask."
  if [ "$app" = "ramille" ]; then scripts/update-cask.sh ramille "$version" "$build"; else scripts/update-cask.sh localepilot "$version"; fi
}

check ramille   ramah/ramille-releases   "$RAMILLE_APPCAST_URL"
check localepilot ramah/localepilot-releases "$LOCALEPILOT_APPCAST_URL"
exit "$status"
