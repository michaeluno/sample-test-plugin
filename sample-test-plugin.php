<?php
/* 
 * Plugin Name: Sample Test Plugin 
 * Version:     0.0.1
 */

function getSampleTestValue() {
    return true;
}

/**
 * The base class of the main sample class.
 */
class SampleTestPlugin_Base {
    const NAME = 'Sample Test Plugin';
    const VERSION = '0.0.1';
}

/**
 * Sample class.
 */
class SampleTestPlugin extends SampleTestPlugin_Base {
    
    public function getA() {
        return 'A';
    }
    public function getB() {
        return 'B';
    }    
    public function render() {
        echo "<p>" . getA() . getB() . "</p>";
    }
    
}