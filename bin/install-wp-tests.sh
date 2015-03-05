#!/usr/bin/env bash

if [ $# -lt 3 ]; then
	echo "usage: $0 <db-name> <db-user> <db-pass> [db-host] [wp-version]"
	exit 1
fi

DB_NAME=$1
DB_USER=$2
DB_PASS=$3
DB_HOST=${4-localhost}
WP_VERSION=${5-latest}

PROJECT_SLUG=${6-sample-test-plugin}

SCRIPT_DIR=$(pwd)
PROJECT_DIR=$(cd "$SCRIPT_DIR/../../"; pwd)

WP_TESTS_DIR=${WP_TESTS_DIR-/tmp/wordpress-tests-lib}
WP_CORE_DIR=/tmp/wordpress/

set -ex

install_wp() {
	mkdir -p $WP_CORE_DIR

	if [ $WP_VERSION == 'latest' ]; then 
		local ARCHIVE_NAME='latest'
	else
		local ARCHIVE_NAME="wordpress-$WP_VERSION"
	fi

	wget -nv -O /tmp/wordpress.tar.gz https://wordpress.org/${ARCHIVE_NAME}.tar.gz
	tar --strip-components=1 -zxmf /tmp/wordpress.tar.gz -C $WP_CORE_DIR

	wget -nv -O $WP_CORE_DIR/wp-content/db.php https://raw.github.com/markoheijnen/wp-mysqli/master/db.php
}

install_test_suite() {
	# portable in-place argument for both GNU sed and Mac OSX sed
	if [[ $(uname -s) == 'Darwin' ]]; then
		local ioption='-i .bak'
	else
		local ioption='-i'
	fi

	# set up testing suite
	mkdir -p $WP_TESTS_DIR
	cd $WP_TESTS_DIR
	svn co --quiet https://develop.svn.wordpress.org/trunk/tests/phpunit/includes/

	wget -nv -O wp-tests-config.php http://develop.svn.wordpress.org/trunk/wp-tests-config-sample.php
	sed $ioption "s:dirname( __FILE__ ) . '/src/':'$WP_CORE_DIR':" wp-tests-config.php
	sed $ioption "s/youremptytestdbnamehere/$DB_NAME/" wp-tests-config.php
	sed $ioption "s/yourusernamehere/$DB_USER/" wp-tests-config.php
	sed $ioption "s/yourpasswordhere/$DB_PASS/" wp-tests-config.php
	sed $ioption "s|localhost|${DB_HOST}|" wp-tests-config.php
}

install_db() {
	# parse DB_HOST for port or socket references
	local PARTS=(${DB_HOST//\:/ })
	local DB_HOSTNAME=${PARTS[0]};
	local DB_SOCK_OR_PORT=${PARTS[1]};
	local EXTRA=""

	if ! [ -z $DB_HOSTNAME ] ; then
		if [[ "$DB_SOCK_OR_PORT" =~ ^[0-9]+$ ]] ; then
			EXTRA=" --host=$DB_HOSTNAME --port=$DB_SOCK_OR_PORT --protocol=tcp"
		elif ! [ -z $DB_SOCK_OR_PORT ] ; then
			EXTRA=" --socket=$DB_SOCK_OR_PORT"
		elif ! [ -z $DB_HOSTNAME ] ; then
			EXTRA=" --host=$DB_HOSTNAME --protocol=tcp"
		fi
	fi

	# create database
	mysqladmin create $DB_NAME --user="$DB_USER" --password="$DB_PASS"$EXTRA
}

# Installs the project plugin
install_plugin() {
    
    # Make sure no old file exists.
    if [ -d "$WP_TESTS_DIR/wp-content/plugins/$PROJECT_SLUG" ]; then
        
        # Directly removing the directory sometimes fails saying it's not empty. So move it to a different location and then remove.
        mv -f "$WP_TESTS_DIR/wp-content/plugins/$PROJECT_SLUG" "$TEMP/$PROJECT_SLUG"
        rm -rf "$TEMP/$PROJECT_SLUG"
        
        # Sometimes moving fails so remove the directory in case.
        rm -rf "$WP_TESTS_DIR/wp-content/plugins/$PROJECT_SLUG"
        
    fi    
    
    # The `ln` command gives "Protocol Error" on Windows hosts so use the cp command.
    # The below cp command appends an asterisk to drop hidden items especially the .git directory but in that case, the destination directory needs to exist.
    mkdir -p "$WP_TESTS_DIR/wp-content/plugins/$PROJECT_SLUG"
    # drop hidden files from being copied
    cp -r "$PROJECT_DIR/"* "$WP_TESTS_DIR/wp-content/plugins/$PROJECT_SLUG"
    # rm -rf "$WP_TESTS_DIR/wp-content/plugins/$PROJECT_SLUG/.git" # Remove git system files.
 
    # wp cli command
    # wp plugin activate $PROJECT_SLUG
    
}


install_wp
install_test_suite
install_db
install_plugin