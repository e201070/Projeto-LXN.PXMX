#!/usr/bin/env bash
# Diagnóstico somente leitura. Uso: bash scripts/diagnostico-ubuntu.sh
# Requisitos: Bash, coreutils, procps e iproute2 (padrão no Ubuntu).
# Não exige sudo e não altera configurações do sistema.

set -euo pipefail

printf '=== Sistema operacional ===\n'
if [[ -r /etc/os-release ]]; then
    # Arquivo de identificação fornecido pelo sistema operacional.
    # shellcheck disable=SC1091
    . /etc/os-release
    printf 'Versão: %s\n' "${PRETTY_NAME:-Não informada}"
else
    printf 'Versão: indisponível (/etc/os-release não encontrado)\n'
fi
printf 'Kernel: %s\n' "$(uname -r)"

printf '\n=== Memória RAM ===\n'
free -h

printf '\n=== Espaço em disco por sistema de arquivos ===\n'
df -h -x tmpfs -x devtmpfs

printf '\n=== Interfaces de rede (endereços IPv4 e IPv6) ===\n'
if command -v ip >/dev/null 2>&1 && ip -brief address show; then
    :
else
    printf 'Não foi possível consultar endereços com ip; interfaces locais:\n'
    for interface in /sys/class/net/*; do
        [[ -d "$interface" ]] || continue
        state='indisponível'
        if [[ -r "$interface/operstate" ]]; then
            read -r state < "$interface/operstate"
        fi
        printf '%s: %s\n' "${interface##*/}" "$state"
    done
fi
