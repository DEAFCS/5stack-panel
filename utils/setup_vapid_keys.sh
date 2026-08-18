#!/bin/bash

setup_vapid_keys() {
    local secrets_file=${1:-"overlays/local-secrets/push-secrets.env"}

    if [ ! -f "$secrets_file" ]; then
        echo "Warning: Secrets file $secrets_file not found, skipping VAPID key setup..."
        return
    fi

    VAPID_PUBLIC_KEY=$(grep -h "^VAPID_PUBLIC_KEY=" "$secrets_file" | cut -d '=' -f2-)
    VAPID_PRIVATE_KEY=$(grep -h "^VAPID_PRIVATE_KEY=" "$secrets_file" | cut -d '=' -f2-)

    if [ -z "$VAPID_PUBLIC_KEY" ] || [ -z "$VAPID_PRIVATE_KEY" ]; then
        echo "Web push (browser) notifications need a VAPID keypair to sign push messages."
        echo "Generate one with: npx web-push generate-vapid-keys"
        echo "(if you already have a keypair from a previous install, reuse it here so"
        echo " existing browser subscriptions keep working instead of resubscribing.)"

        while [ -z "$VAPID_PUBLIC_KEY" ]; do
            echo "Enter your VAPID Public Key:"
            read VAPID_PUBLIC_KEY
        done
        while [ -z "$VAPID_PRIVATE_KEY" ]; do
            echo "Enter your VAPID Private Key:"
            read VAPID_PRIVATE_KEY
        done

        update_env_var "$secrets_file" "VAPID_PUBLIC_KEY" "$VAPID_PUBLIC_KEY"
        update_env_var "$secrets_file" "VAPID_PRIVATE_KEY" "$VAPID_PRIVATE_KEY"
    fi

    VAPID_SUBJECT=$(grep -h "^VAPID_SUBJECT=" "$secrets_file" | cut -d '=' -f2-)
    if [ -z "$VAPID_SUBJECT" ]; then
        local mail_from
        mail_from=$(grep -h "^MAIL_FROM=" overlays/config/api-config.env 2>/dev/null | cut -d '=' -f2-)
        VAPID_SUBJECT="mailto:${mail_from:-hello@example.com}"
        update_env_var "$secrets_file" "VAPID_SUBJECT" "$VAPID_SUBJECT"
    fi
}
