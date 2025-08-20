#!/bin/bash
# Script: build_rpm.sh
# Author: Juan Medina jmedina@collin.edu
# Description: Script to build the chatty RPM package.

# Configuration
APP_NAME="chatty"
APP_VERSION="2.0" # Must match Version in chatty.spec
SPEC_FILE="${APP_NAME}.spec"
SOURCE_DIR_NAME="${APP_NAME}-${APP_VERSION}"

# Color Codes
ColorReset="\033[0m"        # Color reset
ColorGreen="\033[0;32m"     # Color Green
ColorRed="\033[0;31m"     # Color Red
ColorBlue="\033[0;34m"     # Color Blue
ColorYellow="\033[0;33m"     # Color Yellow
ColorPurple="\033[0;35m"     # Color Purple
ColorCyan="\033[0;36m"     # Color Cyan

clear

echo -e "${ColorPurple}Building ${ColorCyan}${APP_NAME}${ColorPurple} Version ${ColorCyan}${APP_VERSION}${ColorPurple} RPM Package...${ColorReset}"

if [[ ${APP_VERSION} != $(grep Version chatty.spec | awk '{ print $2 }') ]]
then
    echo -e "${ColorRed}Error: Version in spec file missmatch.${ColorReset}"
    exit 2
fi

echo -e "${ColorYellow}Checking for 'rpmbuild' command...${ColorReset}"
    if ! command -v rpmbuild &> /dev/null; then
        echo -e "       ${ColorRed}Error: 'rpmbuild' command not found.${ColorReset}"
        echo -e "       ${ColorRed}Please install it using: sudo dnf install rpm-build${ColorReset}"
        exit 1 # Exit if rpmbuild is not found
    fi
    echo -e "       ${ColorBlue}'rpmbuild' found. Proceeding with build.${ColorReset}"

echo -e "${ColorYellow}Setting up RPM build environment...${ColorReset}"
    RPMBUILD_DIR="${HOME}/rpmbuild"
    mkdir -p "${RPMBUILD_DIR}/SOURCES" \
            "${RPMBUILD_DIR}/SPECS" \
            "${RPMBUILD_DIR}/BUILD" \
            "${RPMBUILD_DIR}/RPMS" \
            "${RPMBUILD_DIR}/SRPMS"

echo -e "${ColorYellow}Creating source tarball...${ColorReset}"
    TEMP_SOURCE_ROOT=$(mktemp -d)
    SOURCE_CONTENTS_DIR="${TEMP_SOURCE_ROOT}/${SOURCE_DIR_NAME}"
    mkdir "${SOURCE_CONTENTS_DIR}"
    # Explicitly copy only the necessary project files into the named directory
    cp -r ./tasks "${SOURCE_CONTENTS_DIR}/"
    cp requirements.txt "${SOURCE_CONTENTS_DIR}/"
    cp chatty "${SOURCE_CONTENTS_DIR}/"
    # Optional: Copy README.md and LICENSE if they exist and are included in .spec
    if [ -f "README.md" ]; then
        cp README.md "${SOURCE_CONTENTS_DIR}/"
    fi
    if [ -f "LICENSE" ]; then
        cp LICENSE "${SOURCE_CONTENTS_DIR}/"
    fi

    # Create the tarball from the temporary root directory, archiving SOURCE_DIR_NAME
    tar -czf "${RPMBUILD_DIR}/SOURCES/${APP_NAME}-${APP_VERSION}.tar.gz" -C "${TEMP_SOURCE_ROOT}" "${SOURCE_DIR_NAME}"
    rm -rf "${TEMP_SOURCE_ROOT}" # Clean up the temporary source root directory
    echo -e "       ${ColorBlue}Source tarball created: ${RPMBUILD_DIR}/SOURCES/${APP_NAME}-${APP_VERSION}.tar.gz${ColorReset}"

echo -e "${ColorYellow}Copying .spec file to SPECS directory...${ColorReset}"
    cp "${SPEC_FILE}" "${RPMBUILD_DIR}/SPECS/"

echo -e "${ColorYellow}Building RPM package...${ColorReset}"
    # Remove the --quiet from the following line to troubleshoot
    rpmbuild --quiet -ba "${RPMBUILD_DIR}/SPECS/${SPEC_FILE}"

echo -e "${ColorYellow}Cleaning up build artifacts...${ColorReset}"
    if [[ ! -d RPMS ]]; then
        mkdir RPMS
    fi
    mv ${RPMBUILD_DIR}/RPMS/noarch/${APP_NAME}-${APP_VERSION}*.rpm ./RPMS/
    rm -rf ${RPMBUILD_DIR}
    # Rotating old rpm files
    PKGS=($(ls -t RPMS/*.rpm))
    while [ ${#PKGS[@]} -gt 2 ]
    do
        rm -rf ${PKGS[-1]}
        PKGS=($(ls -t RPMS/*.rpm))
    done

echo -e "${ColorYellow}Final Verifications...${ColorReset}"
    if [ $? -eq 0 ]; then
        echo -e "${ColorCyan}${APP_NAME}${ColorPurple} RPM build ${ColorGreen}SUCCESSFUL!${ColorReset}"
        echo -e "${ColorCyan}$(ls $(pwd)/RPMS/${APP_NAME}-${APP_VERSION}*.rpm)${ColorReset}"
        echo -e "${ColorPurple}To install run: ${ColorCyan}sudo dnf install RPMS/${APP_NAME}-${APP_VERSION}*.rpm"
    else
        echo -e "${ColorCyan}${APP_NAME}${ColorPurple} RPM build ${ColorRed}FAILED!${ColorReset}"
    fi

# EOF