#!/bin/bash

set -e

echo "${0} start!"
echo "Var : USER_NAME = ${USER_NAME}, USER_UID = ${USER_UID}, USER_GID = ${USER_GID}"

# グループの作成
if getent group "${USER_NAME}" > /dev/null 2>&1; then
    EXISTING_GID=$(getent group "${USER_NAME}" | cut -d: -f3)
    if [ "$EXISTING_GID" -ne "$USER_GID" ]; then
        echo "Warning: Group ${USER_NAME} already exists with a different GID (${EXISTING_GID}). Skipping group creation."
    else
        echo "Group ${USER_NAME} already exists with GID ${USER_GID}."
    fi
else
    if groupadd --gid "${USER_GID}" "${USER_NAME}"; then
        echo "Group ${USER_NAME} with GID ${USER_GID} created successfully."
    else
        echo "Failed to create group ${USER_NAME} with GID ${USER_GID}. Please check for conflicts."
        exit 1
    fi
fi

# ユーザーの作成
if id -u "${USER_NAME}" > /dev/null 2>&1; then
    EXISTING_UID=$(id -u "${USER_NAME}")
    if [ "$EXISTING_UID" -ne "$USER_UID" ]; then
        echo "Warning: User ${USER_NAME} already exists with a different UID (${EXISTING_UID}). Skipping user creation."
    else
        echo "User ${USER_NAME} already exists with UID ${USER_UID}."
    fi
else
    echo "Creating user ${USER_NAME} with UID ${USER_UID} and GID ${USER_GID}"
    useradd --uid "${USER_UID}" --gid "${USER_GID}" -m "${USER_NAME}"
fi

# sudo権限の付与
SUDOERS_DIR="/etc/sudoers.d/"
SUDOERS_FILE="${SUDOERS_DIR}${USER_NAME}"
SUDOERS_ENTRY="${USER_NAME} ALL=(ALL) NOPASSWD:ALL"

# sudoersディレクトリの存在確認
if [ ! -d "$SUDOERS_DIR" ]; then
    echo "Creating $SUDOERS_DIR directory"
    mkdir -p "$SUDOERS_DIR"
fi

# sudoersファイルの作成・更新
if [ ! -f "$SUDOERS_FILE" ] || ! grep -Fxq "$SUDOERS_ENTRY" "$SUDOERS_FILE"; then
    echo "Adding sudoers entry for ${USER_NAME}"
    echo "$SUDOERS_ENTRY" > "$SUDOERS_FILE"
    chmod 0440 "$SUDOERS_FILE"
else
    echo "Sudoers entry for ${USER_NAME} already exists."
fi

echo "${0} finished!"

