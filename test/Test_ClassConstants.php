<?php
/**
 * @group sample_test_plugin
 */
class Test_ClassConstants extends WP_UnitTestCase {
    
    public function setUp() {
        parent::setUp();
    }

    public function tearDown() {
        parent::tearDown();
    }

    public function test_constants() {

        $this->assertEquals( 'Sample Test Plugin', SampleTestPlugin::NAME );
        
    }
    
}    