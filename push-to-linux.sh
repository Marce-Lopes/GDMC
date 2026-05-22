"#!/bin/bash
# =============================================================================
# GDMC-EU — Copiar repo para Linux remoto via rsync
# =============================================================================
# Uso: ./push-to-linux.sh user@host:/path
# Ex:  ./push-to-linux.sh deploy@192.168.1.50:/opt/gdmc
# =============================================================================

if [ -z "$1" ]; then
    echo "Uso: $0 user@host:/path"
    echo "Ex:  $0 deploy@192.168.1.50:/opt/gdmc"
    exit 1
fi

TARGET=$1

echo "Sincronizando repo para $TARGET ..."
echo ""

# rsync excluindo lixo
echo "[1/3] Copiando código-fonte..."
rsync -azP --delete \
    --exclude='.git' \
    --exclude='**/build/' \
    --exclude='**/target/' \
    --exclude='**/node_modules/' \
    --exclude='**/.gradle/' \
    --exclude='**/out/' \
    --exclude='**/.idea/' \
    --exclude='**/*.class' \
    --exclude='workflow-engine/.git' \
    ./ "${TARGET}/"

echo ""
echo "[2/3] Dando permissão de execução nos scripts..."
ssh "${TARGET%%:*}" "chmod +x ${TARGET#*:}/deploy-remote.sh ${TARGET#*:}/build-all-local.sh 2>/dev/null"

echo ""
echo "[3/3] Pronto! Para buildar e subir no Linux:"
echo ""
echo "  ssh ${TARGET%%:*}"
echo "  cd ${TARGET#*:}"
echo "  ./deploy-remote.sh build     # builda tudo"
echo "  ./deploy-remote.sh all       # sobe tudo"
echo "  ./deploy-remote.sh status    # verifica"
echo ""