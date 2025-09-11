#!/usr/bin/env bash
set -euo pipefail

# Variables à adapter
TEMPLATE_FILE="${1:-deploy.bicep}"         # usage: ./deploy.sh main.bicep params.json rg-name
RG_NAME_INPUT="${2:-}"                   # optionnel: nom du RG
LOCATION_DEFAULT="westeurope"            # localisation par défaut pour la création d'un RG
DEPLOYMENT_NAME="deploy-$(date +%Y%m%d%H%M%S)"

# Pré-requis: Azure CLI connecté et subscription sélectionnée
az account show >/dev/null 2>&1 || az login --use-device-code >/dev/null
if ! az account show --query id -o tsv >/dev/null 2>&1; then
  echo "Erreur: aucune souscription active"; exit 1
fi

# Vérifications de base
if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Erreur: template introuvable: $TEMPLATE_FILE"; exit 2
fi

# Sélection du Resource Group
choose_rg() {
  mapfile -t rgs < <(az group list --query "[].name" -o tsv)
  if [ "${#rgs[@]}" -eq 0 ]; then
    echo "Aucun Resource Group trouvé."
    echo "Création de rg par défaut: ${RG_NAME_INPUT:-rg-temp-$LOCATION_DEFAULT}"
    az group create --name "${RG_NAME_INPUT:-rg-temp-$LOCATION_DEFAULT}" --location "$LOCATION_DEFAULT" >/dev/null
    echo "${RG_NAME_INPUT:-rg-temp-$LOCATION_DEFAULT}"
    return
  fi

  if [ -n "${RG_NAME_INPUT:-}" ]; then
    echo "$RG_NAME_INPUT"
    return
  fi

  echo "Sélectionnez un Resource Group:"  >&2
  select rg in "${rgs[@]}"; do
    if [ -n "${rg:-}" ]; then
      echo "$rg"
      return
    fi
  done
}

RG_NAME="$(choose_rg)"

# Création si le RG n’existe pas
if ! az group show --name "$RG_NAME" >/dev/null 2>&1; then
  echo "Le Resource Group '$RG_NAME' n'existe pas. Création..."
  az group create --name "$RG_NAME" --location "$LOCATION_DEFAULT" >/dev/null
fi

# Validation du template
echo "Validation du déploiement..."

az deployment group validate \
  --resource-group "$RG_NAME" \
  --name "$DEPLOYMENT_NAME" \
  --template-file "$TEMPLATE_FILE" 

# What-if informatif
echo "What-if:"

az deployment group what-if \
  --resource-group "$RG_NAME" \
  --name "$DEPLOYMENT_NAME" \
  --template-file "$TEMPLATE_FILE"

# Déploiement
echo "Déploiement..."

az deployment group create \
  --resource-group "$RG_NAME" \
  --name "$DEPLOYMENT_NAME" \
  --template-file "$TEMPLATE_FILE"
