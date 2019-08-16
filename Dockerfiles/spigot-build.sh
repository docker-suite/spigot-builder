#!/usr/bin/env bash

# set -e : Exit the script if any statement returns a non-true return value.
# set -u : Exit the script when using uninitialised variable.
set -e


# Folder where spigot will be built
MAVEN_BUILD_DIR=$MAVEN_HOME_DIR/build
# Folder where artifacts will be copyed at the end of the process
MAVEN_TARGET_DIR=$MAVEN_HOME_DIR/target
# Declare M2_HOME as BuildTools is looking for it
export M2_HOME=$MAVEN_HOME


# Remove all data from the build folder
[ -d "$MAVEN_BUILD_DIR" ] && rm -rf "$MAVEN_BUILD_DIR"
# Make sure the build folder is empty
mkdir -p "$MAVEN_BUILD_DIR"
# Make sure the target folder exist
mkdir -p "$MAVEN_TARGET_DIR"


# Download BuildTools
echo "Downloading the latest version of BuildTools.jar ..."
curl -o "$MAVEN_BUILD_DIR/BuildTools.jar" https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar


# Adjust git configuration
git config --global user.name $USER_NAME
git config --global user.email $USER_EMAIL
git config --global core.autocrlf false


# Build Spigot and CraftBukkit
echo "Building spigot version $1 ..."
# go to the build folder
cd "$MAVEN_BUILD_DIR" || exit 1
# Clone first for quicker built
java -jar BuildTools.jar --disable-java-check --rev $1


echo
echo
# get the project version
PROJECT_VERSION=$(printf 'VERSION=${project.version}\n0\n' | mvn -f /var/maven_home/build/Bukkit/pom.xml org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate | grep '^VERSION' | sed 's/^VERSION=//g')
# Copy craftbukkit to target folder
echo "Copying craftbukkit-$PROJECT_VERSION.jar to $MAVEN_TARGET_DIR/craftbukkit-$1.jar"
cp "$MAVEN_BUILD_DIR/CraftBukkit/target/craftbukkit-$PROJECT_VERSION.jar" "$MAVEN_TARGET_DIR/craftbukkit-$1.jar"
# Copy spigot to target folder
echo "Copying spigot-$PROJECT_VERSION.jar to $MAVEN_TARGET_DIR/spigot-$1.jar"
cp "$MAVEN_BUILD_DIR/Spigot/Spigot-Server/target/spigot-$PROJECT_VERSION.jar" "$MAVEN_TARGET_DIR/spigot-$1.jar"
