<?php
$_sTestsDirPath = getenv( 'WP_TESTS_DIR' );
if ( ! $_sTestsDirPath ) {
    $_sTestsDirPath = '/tmp/wordpress-tests-lib';
}        

require_once $_sTestsDirPath . '/includes/functions.php';

function _loadPluginManually() {
	require dirname( dirname( __FILE__ ) ) . '/sample-test-plugin.php';
}
tests_add_filter( 'muplugins_loaded', '_loadPluginManually' );

require $_sTestsDirPath . '/includes/bootstrap.php';

$_mError = activate_plugin( 'sample-test-plugin/sample-test-plugin.php' );
// if ( null !== $_mError )  {
    // trigger_error( 'The plugin could not be activated.', E_USER_ERROR );
// }