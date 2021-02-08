#/bin/sh
# Bail on errors
set -e
# We shouldn't have unbounded vars
set -u
# $DEFAULT_VERSION
#   The tag or branch from which the source install performs.
# $KLOUDI_HOME
#   Sets the agent installation directory.
#   Defaults to $HOME/.kloudi

DEFAULT_VERSION="v1.7.0"
VERSION=${VERSION:-$DEFAULT_VERSION}
APP_VERSION="v2.19.4"

APP_DOWNLOAD_URL="https://github.com/kloudi-tech/local/releases/download/$VERSION/Kloudi-$APP_VERSION.dmg"
BACKEND_DOWNLOAD_URL="https://github.com/kloudi-tech/local/releases/download/$VERSION/docker-compose.yml"

KLOUDI_HOME=$HOME/.kloudi
OS_VERSION=

APP_DMG="Kloudi-$APP_VERSION.dmg"

#######################################################################
# Error reporting helpers
#######################################################################

err_report() {
    print_red "Error on line $1"
}
trap 'err_report $LINENO' ERR

function catch_all_error() {
    printf "\033[31m$ERROR_MESSAGE
It looks like you hit an issue when trying to install Kloudi.
Troubleshooting and basic usage information for the Agent are available at. Please send an email to hello@kloudi.tech
with the screenshot of your terminal logs and we'll do our very best to help you
solve your problem.\n\033[0m\n"
}

function print_console() {
    printf "%s\n" "$*"
}

function print_red() {
    printf "\033[31m%s\033[0m\n" "$*"
}

function print_green() {
    printf "\033[32m%s\033[0m\n" "$*"
}

#######################################################################
# Helper functions
#######################################################################

function detect_docker() {
    if [ -x "$(command -v docker)" ]; then
        print_green "Docker is installed on the system."
        print_console "Starting docker, in case it is not running..."
        #Open Docker, only if is not running
        if (! docker stats --no-stream); then
            # On Mac OS this would be the terminal command to launch Docker
            open /Applications/Docker.app
            #Wait until Docker daemon is running and has completed initialisation
            while (! docker stats --no-stream); do
                # Docker takes a few seconds to initialize
                print_console "Waiting for Docker to launch..."
                sleep 1
            done
        fi
    else
        print_red "Docker is not present. Refer https://docs.docker.com/engine/install/ to install docker on your system."
        exit 1
    fi
}

function detect_downloader() {
    if command -v curl; then
        export DOWNLOADER="curl -k -L -o"
        export HTTP_TESTER="curl -f"
    elif command -v wget; then
        export DOWNLOADER="wget -O"
        export HTTP_TESTER="wget -O /dev/null"
    fi
}

function set_os_version() {
    ERROR_OS="Kloudi is currently supported on macOS version 10.14 or newer."
    ERROR_OS_VERSION="Kloudi runs on macOS version 10.14 or newer."
    REQUIRED_OS_VERSION=10.14

    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_green "Current platform: Darwin based. Probably macOSX"
        OS_MAJOR_VERSION=$(sw_vers -productVersion | cut -d'.' -f1)
        OS_MINOR_VERSION=$(sw_vers -productVersion | cut -d'.' -f2)
        OS_VERSION=$OS_MAJOR_VERSION.$OS_MINOR_VERSION
        diff=$(echo "($OS_VERSION>=$REQUIRED_OS_VERSION)" | bc -l)
        if ((diff == 1)); then
            continue
        else
            print_red $ERROR_OS_VERSION
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        print_red $ERROR_OS
        print_red "Current platform: linux-gnu based."
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        print_red $ERROR_OS
        print_red "Current platform: cygwin based."
    elif [[ "$OSTYPE" == "msys" ]]; then
        print_red $ERROR_OS
        print_red "Current platform: msys based."
    elif [[ "$OSTYPE" == "win32" ]]; then
        print_red $ERROR_OS
        print_red "Current platform: win32 based."
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        print_red $ERROR_OS
        print_red "Current platform: freebsd based."
    else
        print_red $ERROR_OS
    fi
}

#######################################################################
# PREPARING FOR EXECUTION
#######################################################################
# Root user detection
if [ $(echo "$UID") = "0" ]; then
    sudo_cmd=''
else
    sudo_cmd='sudo'
fi

# get real user (in case of sudo)
real_user=$(logname)
export TMPDIR=$(sudo -u $real_user getconf DARWIN_USER_TEMP_DIR)
cmd_real_user="sudo -Eu $real_user"

mkdir -p "$KLOUDI_HOME"
set_os_version

#######################################################################
# CHECKING REQUIREMENTS
#######################################################################
print_console "Checking if docker is installed..."
detect_docker

#######################################################################
# INSTALLING
#######################################################################
print_green "Downloading and setting up Kloudi's server on localhost.."
rm -rf $KLOUDI_HOME/kloudi-backend.yml
$cmd_real_user curl -sL $BACKEND_DOWNLOAD_URL -o "kloudi-backend.yml"
mv ./kloudi-backend.yml $KLOUDI_HOME
print_console "Stopping all running images of Kloudi..."
docker stop $(docker ps -q -f "name=kloudi-*") || true
print_console "Removing all stopped containers..."
docker container prune -f
print_console "Removing all old images, if any, before downloading the new ones..."
docker rmi -f $(docker ps -a | grep kloudi-) || true
docker-compose -f $KLOUDI_HOME/kloudi-backend.yml up -d

rm -rf ./$APP_DMG /Applications/Kloudi.app
print_green "Installing Kloudi app..."
$cmd_real_user curl -sSL $APP_DOWNLOAD_URL -o $APP_DMG
hdiutil detach "/Voumes/Kloudi" >/dev/null 2>&1 || true
hdiutil attach $APP_DMG -mountpoint "/Volumes/Kloudi" >/dev/null
cd / && cp -rf /Volumes/Kloudi/Kloudi.app /Applications
hdiutil detach "/Volumes/Kloudi" >/dev/null
rm -rf ./$APP_DMG

HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X GET http://0.0.0.0:4000/)
HTTP_STATUS_CODE=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://') || false

if ((HTTP_STATUS_CODE == 200)); then
    print_console "Kloudi is successfully installed on your system."
    print_green "Starting Kloudi in 3..2..1.. 🚀"
    open -a /Applications/Kloudi.app
else
    catch_all_error "Boom "
fi
exit 1
