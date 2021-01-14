#!/usr/bin/env bash

# Version to build
if [ -z "$1" ]; then
    VERSION="latest"
else
    VERSION="$1"
fi

# set -e : Exit the script if any statement returns a non-true return value.
# set -u : Exit the script when using uninitialised variable.
set -eu

# Folder where spigot will be built
MAVEN_BUILD_DIR=/var/spigot/build/$VERSION
# Folder where artifacts will be copyed at the end of the process
MAVEN_TARGET_DIR=/var/spigot/target
# Declare M2_HOME as BuildTools is looking for it
export M2_HOME=$MAVEN_HOME



# Check if the version is compatble
check::version() {
    # Array of supported versions
    declare -a supported_versions=(
            "1.8" "1.8.3" "1.8.7" "1.8.8"
            "1.9" "1.9.2" "1.9.4"
            "1.10"
            "1.11"
            "1.12" "1.12.1" "1.12.2"
            "1.13" "1.13.1" "1.13.2"
            "1.14" "1.14.1" "1.14.2" "1.14.3" "1.14.4"
            "1.15" "1.15.1" "1.15.2"
            "1.16.1" "1.16.2" "1.16.3" "1.16.4"
            "latest")
    declare -A supported_versions_map
    for key in "${!supported_versions[@]}"; do supported_versions_map[${supported_versions[$key]}]="$key"; done

    # Check
    if [[ -n "${supported_versions_map[$VERSION]}" ]]; then
        return 0
    else
        echo "This version ($VERSION) of Spifog is not supported"
        return 1;
    fi
}

# Check if we are behind a proxy
check::proxy() {
    if [[ -z "${http_proxy+x}" ]] && [[ ! "${http_proxy+x}" = "x" ]]; then
        return 0
    else
        echo "You are trying to build Spigot $VERSION behind a proxy"
        echo "$http_proxy"
        echo "${http_proxy+x}"
        echo "!! This may not work !!"
        echo "!! BuildTools only support proxy without authentication !!"
        # Remove protocol
        adress="${http_proxy#http://}"
        # get user and password
        user_password="${adress%${adress#*:*@}}"
        if [[ -n $user_password ]]; then
            user_password=${user_password::-1}
            user="${user_password%${user_password#*:}}"
            user=${user::-1}
            password="${user_password#*:}"
            adress="${adress##*:*@}"
            # Update java args
            JAVA_ARGS="${JAVA_ARGS} -Dhttp.proxyUser=${user} -Dhttp.proxyPassword=${password} -Dhttps.proxyUser=${user} -Dhttps.proxyPassword=${password}"
            JAVA_ARGS="${JAVA_ARGS} -Djdk.http.auth.tunneling.disabledSchemes="" "
        fi
        # Get host and port
        host_port="${adress#*/}"
        if [[ -n $host_port ]]; then
            host="${host_port%${host_port#*:}}"
            host=${host::-1}
            port="${host_port#*:}"
            # Update java args
            JAVA_ARGS="${JAVA_ARGS} -Dhttp.proxyHost=${host} -Dhttp.proxyPort=${port} -Dhttps.proxyHost=${host} -Dhttps.proxyPort=${port}"
        fi
    fi
}

prepare::folders() {
    # Remove all data from the build folder
    [ -d "$MAVEN_BUILD_DIR" ] && (cd "${MAVEN_BUILD_DIR}" && rm -rf ./*)
    # Make sure the build folder is empty
    sudo mkdir -p "$MAVEN_BUILD_DIR"
    # Make sure the target folder exist
    sudo mkdir -p "$MAVEN_TARGET_DIR"
}

# Adjust git configuration
prepare::git() {
    sudo -E git config --global user.name $USER_NAME
    sudo -E git config --global user.email $USER_EMAIL
    sudo git config --global core.autocrlf false
    sudo git config --global http.sslVerify false
}

# Download BuildTools
download::BuildTools() {
    echo "Downloading the latest version of BuildTools.jar ..."
    sudo curl -o "$MAVEN_BUILD_DIR/BuildTools.jar" https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
}

build() {
    # Build Spigot and CraftBukkit
    echo "Building spigot version $VERSION ..."
    # go to the build folder
    cd "$MAVEN_BUILD_DIR" || exit 1
    # Build
    sudo -E java -jar BuildTools.jar --disable-java-check --compile craftbukkit,spigot --output-dir $MAVEN_TARGET_DIR --rev $VERSION
}

check::version
check::proxy
prepare::folders
prepare::git
download::BuildTools
build
