<?php
$_tests_dir = getenv( 'WP_TESTS_DIR' );
if ( ! $_tests_dir ) {
    $_tests_dir = '/tmp/wordpress-tests-lib';
}        

require_once $_tests_dir . '/includes/functions.php';

function _manually_load_plugin() {
	require dirname( dirname( __FILE__ ) ) . '/sample-test-plugin.php';
}
tests_add_filter( 'muplugins_loaded', '_manually_load_plugin' );

require $_tests_dir . '/includes/bootstrap.php';

$_mError = activate_plugin( 'sample-test-plugin/sample-test-plugin.php' );
if ( null !== $_mError )  {
    trigger_error( 'The plugin could not be activated.', E_USER_ERROR );
}