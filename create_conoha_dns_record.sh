#!/bin/bash

# -------- #
# VARIABLE #
# -------- #
# ----- certbot ----- #
# CERTBOT_DOMAIN
# CERTBOT_VALIDATION

# ----- script ----- # 
SCRIPT_NAME=$(basename $0)
SCRIPT_PATH=$(dirname $(readlink -f $0))

# ----- conoha_dns_api.sh  ----- #
CNH_DNS_DOMAIN=${CERTBOT_DOMAIN}'.'
CNH_DNS_NAME='_acme-challenge.'${CNH_DNS_DOMAIN}
CNH_DNS_TYPE="TXT"
CNH_DNS_DATA=${CERTBOT_VALIDATION}

# -------- #
# FUNCTION #
# -------- #
source ${SCRIPT_PATH}/conoha_dns_api.sh

# ----------------- #
# CREATE DNS RECORD # 
# ----------------- #
create_conoha_dns_record

# すべての権威DNSサーバーに反映されるまで待機（最大180秒）
NAMESERVERS=("ns-a1.conoha.io" "ns-a2.conoha.io")
TARGET="_acme-challenge.${CERTBOT_DOMAIN}"

for ns in "${NAMESERVERS[@]}"; do
  for i in {1..36}; do
    # 複数行返ってきても、一致する行があれば成功とみなす
    if dig +short TXT "${TARGET}" @"${ns}" | tr -d '"' | grep -Fxq "${CERTBOT_VALIDATION}"; then
      echo "Verified on ${ns}"
      break
    fi
    sleep 5
  done
done

# 念のため追加で10秒待機
sleep 10
