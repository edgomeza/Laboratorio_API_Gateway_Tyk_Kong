#!/bin/bash
#########################################
# Exercise Watcher - Auto-activates exercises
# Monitors exercise files and activates them when uncommented
#########################################

set -e

EXERCISE_DIR="./exercises"
TYK_APPS_DIR="./gateway-configs/tyk/apps-active"
TYK_GATEWAY_URL="http://localhost:8080"
KONG_ADMIN_URL="http://localhost:8001"

echo "🔍 API Gateway Exercise Watcher Started"
echo "========================================"
echo "Monitoring: $EXERCISE_DIR"
echo ""

# Create apps-active directory if it doesn't exist
mkdir -p "$TYK_APPS_DIR"

# Function to check if a file is uncommented
is_uncommented() {
    local file="$1"

    # Check if file has content without comment markers
    if [ -f "$file" ]; then
        # For JSON files (Tyk)
        if [[ "$file" == *.json ]]; then
            # Check if file starts with { instead of //{
            if grep -q '^{' "$file" 2>/dev/null; then
                return 0
            fi
        fi

        # For shell scripts (Kong)
        if [[ "$file" == *.sh ]]; then
            # Check if file has uncommented curl commands
            if grep -q '^curl' "$file" 2>/dev/null; then
                return 0
            fi
        fi
    fi

    return 1
}

# Function to activate Tyk exercise
activate_tyk_exercise() {
    local exercise_num="$1"
    local config_file="$2"

    echo "✨ Activating Tyk Exercise $exercise_num..."

    # Copy config to active apps directory
    local filename=$(basename "$config_file")
    local target_file="$TYK_APPS_DIR/${exercise_num}-${filename}"

    cp "$config_file" "$target_file"

    echo "    📁 Config copied to: $target_file"

    # Check if there's an activate.sh script and run it
    local exercise_dir=$(dirname "$config_file")
    if [ -f "$exercise_dir/activate.sh" ]; then
        echo "    🚀 Running activation script..."
        cd "$exercise_dir"
        bash activate.sh > /dev/null 2>&1 || true
        cd - > /dev/null
    else
        # Just reload Tyk if no activation script
        echo "    🔄 Reloading Tyk Gateway..."
        curl -s -H "x-tyk-authorization: foo" \
             -X GET "$TYK_GATEWAY_URL/tyk/reload/group" > /dev/null 2>&1 || true
    fi

    echo "    ✅ Tyk Exercise $exercise_num activated!"
    echo ""
}

# Function to activate Kong exercise
activate_kong_exercise() {
    local exercise_num="$1"
    local script_file="$2"

    echo "✨ Activating Kong Exercise $exercise_num..."

    # Execute the script
    echo "    🚀 Running setup script..."
    cd "$(dirname "$script_file")"
    bash "$(basename "$script_file")" > /dev/null 2>&1 || true
    cd - > /dev/null

    echo "    ✅ Kong Exercise $exercise_num activated!"
    echo ""
}

# Function to check and activate exercises
check_exercises() {
    # Check Tyk exercises
    for i in {1..9}; do
        # Usamos 'ex_dir_pattern' para el comodín
        local ex_dir_pattern="$EXERCISE_DIR/tyk/$(printf "%02d" $i)-*"
        local config_file=$(ls $ex_dir_pattern/config.json 2>/dev/null | head -1)

        if [ -f "$config_file" ]; then
            # CORRECCIÓN: Obtenemos la ruta real del directorio sin el comodín
            local ex_dir=$(dirname "$config_file")
            local marker_file="$ex_dir/.activated"

            if is_uncommented "$config_file" && [ ! -f "$marker_file" ]; then
                activate_tyk_exercise "$i" "$config_file"
                touch "$marker_file" # Ahora 'touch' funciona correctamente
            fi
        fi
    done

    # Check Kong exercises
    for i in {1..9}; do
        # Usamos 'ex_dir_pattern' para el comodín
        local ex_dir_pattern="$EXERCISE_DIR/kong/$(printf "%02d" $i)-*"
        local setup_file=$(ls $ex_dir_pattern/setup.sh 2>/dev/null | head -1)

        if [ -f "$setup_file" ]; then
            # CORRECCIÓN: Obtenemos la ruta real del directorio sin el comodín
            local ex_dir=$(dirname "$setup_file")
            local marker_file="$ex_dir/.activated"

            if is_uncommented "$setup_file" && [ ! -f "$marker_file" ]; then
                activate_kong_exercise "$i" "$setup_file"
                touch "$marker_file" # Ahora 'touch' funciona correctamente
            fi
        fi
    done
}

# Initial check
echo "🔍 Performing initial check..."
check_exercises

echo "👀 Now watching for changes..."
echo "    Edit exercise files to activate them!"
echo ""

# Watch loop
while true; do
    sleep 5
    check_exercises
done