<?php
/* Plugin Name: Sample Test Plugin */

function getSampleTestValue() {
    return true;
}

/**
 * Sample class.
 */
class SampleTestPlugin {
    
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