#!/bin/bash

set -e

echo "${0} start!"
echo "Var : USER_NAME = ${USER_NAME},  USER_UID = ${USER_UID}, USER_GID = ${USER_GID}"

# グループの作成 (groupadd の結果で分岐)
if groupadd --gid "${USER_GID}" "${USER_NAME}" > /dev/null 2>&1; then
    echo "Group ${USER_NAME} with GID ${USER_GID} created successfully."
else
    if [ $? -eq 9 ]; then
        echo "Group ${USER_NAME} already exists."
    else
        echo "Failed to create group ${USER_NAME} with GID ${USER_GID}. Please check for conflicts."
    fi
fi

# ユーザーの作成 (既に存在する場合はスキップ)
if ! id -u ${USER_NAME} > /dev/null 2>&1; then
    echo "Creating user ${USER_NAME} with UID ${USER_UID} and GID ${USER_GID}"
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USER_NAME}
    
    # sudo権限の付与 (既に存在するか確認して、存在しなければ追加)
    SUDOERS_DIR="/etc/sudoers.d/"

    if [ ! -d SUDOERS_DIR ]; then
        echo "Creating /etc/sudoers.d directory"
        sudo mkdir -p SUDOERS_DIR
    fi

    SUDOERS_FILE=${SUDOERS_DIR}${USER_NAME}
    SUDOERS_ENTRY="${USER_NAME} ALL=(ALL) NOPASSWD:ALL"

    if ! grep -Fxq "$SUDOERS_ENTRY" "$SUDOERS_FILE" 2>/dev/null; then
        echo "Adding sudoers entry for ${USER_NAME}"
        echo "$SUDOERS_ENTRY" >> "$SUDOERS_FILE"
    else
        echo "Sudoers entry for ${USER_NAME} already exists and will be updated."
        echo "$SUDOERS_ENTRY" > "$SUDOERS_FILE"
    fi

    chmod 0440 "$SUDOERS_FILE"

else
    echo "User ${USER_NAME} already exists. Skipped."
fi

echo "${0} finished!"

