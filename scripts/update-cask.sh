#!/usr/bin/env bash
# Met à jour le numéro de version et l'empreinte d'un cask après une nouvelle release.
#
#   scripts/update-cask.sh ramille 1.0.1 1000123    (version puis numéro de build : le tag est v1.0.1-b1000123)
#   scripts/update-cask.sh localepilot 1.0.1        (le tag est v1.0.1)
#
# Le script télécharge le DMG publié, calcule son empreinte SHA-256 et réécrit les lignes `version` et `sha256`
# du cask. Il ne fait ni commit ni push : relire `git diff`, puis valider.
# Le DMG n'est jamais ouvert ni monté ; il est supprimé après le calcul.
set -euo pipefail
cd "$(dirname "$0")/.."

app="${1:-}"
version="${2:-}"
build="${3:-}"
if [ -z "$app" ] || [ -z "$version" ]; then
  echo "Usage : scripts/update-cask.sh ramille <version> <build> | localepilot <version>" >&2
  exit 2
fi

case "$app" in
  ramille)
    [ -n "$build" ] || { echo "Ramille : le numéro de build est obligatoire (tag v<version>-b<build>)." >&2; exit 2; }
    repo="ramah/ramille-releases"
    tag="v${version}-b${build}"
    file="Ramille-${version}.dmg"
    cask="Casks/ramille.rb"
    newversion="${version},${build}"
    ;;
  localepilot)
    repo="ramah/localepilot-releases"
    tag="v${version}"
    file="LocalePilot-${version}-macos.dmg"
    cask="Casks/localepilot.rb"
    newversion="${version}"
    ;;
  *)
    echo "App inconnue : ${app} (ramille ou localepilot)." >&2
    exit 2
    ;;
esac

base="https://github.com/${repo}/releases/download/${tag}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Téléchargement de ${base}/${file}"
curl -fsSL "${base}/${file}" -o "${tmp}/app.dmg"
sha="$(shasum -a 256 "${tmp}/app.dmg" | cut -d' ' -f1)"

# LocalePilot publie aussi l'empreinte à côté du DMG : on la compare.
if [ "$app" = "localepilot" ]; then
  if curl -fsSL "${base}/LocalePilot-${version}-macos.sha256" -o "${tmp}/published.sha256" 2>/dev/null; then
    # Le fichier liste une empreinte par ligne (archive .app.zip et DMG) : on prend celle du DMG, par son nom.
    published="$(awk -v f="$file" '$2 == f { print $1 }' "${tmp}/published.sha256" | head -1)"
    if [ -z "$published" ]; then
      echo "Le fichier d'empreinte publié ne mentionne pas ${file} : aucune comparaison."
    elif [ "$published" != "$sha" ]; then
      echo "ERREUR : l'empreinte calculée (${sha}) diffère de l'empreinte publiée (${published})." >&2
      exit 1
    else
      echo "Empreinte identique à celle publiée avec la release."
    fi
  else
    echo "Pas de fichier d'empreinte publié pour cette release : aucune comparaison."
  fi
fi

sed -i '' -E "s/^  version \".*\"/  version \"${newversion}\"/; s/^  sha256 \".*\"/  sha256 \"${sha}\"/" "$cask"
ruby -c "$cask" >/dev/null

echo "version ${newversion}"
echo "sha256  ${sha}"
git --no-pager diff --stat -- "$cask" || true
echo "Relire 'git diff', puis : git commit -am \"${app} ${newversion}\" && git push"
