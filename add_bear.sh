#!/usr/bin/env php
<?php

require_once __DIR__ . '/config.php';
require_once 'vendor/autoload.php';

use Jenssegers\ImageHash\Hash;
use Jenssegers\ImageHash\ImageHash;
use Jenssegers\ImageHash\Implementations\DifferenceHash;

/*
*	sudofox/bear-collector
*
*	add_bear.sh
*	Try adding an image, but check against md5 hash and perceptual hash to avoid duplicates
*
*/

$usage = "Usage: " . __FILE__ . " <path to bear image>\n";

if (!isset($argv[1])) {
        echo $usage;
        exit();
}

if (!file_exists($argv[1])) {
	echo $usage;
	exit("Could not open file: " . $argv[1]."\n");
}

$db = new SQLite3(DATABASE_PATH);

// This library provides DifferenceHash, AverageHash, PerceptualHash, and BlockHash
// I've found DifferenceHash to be pretty decent while others can report different results depending on quality and coloration diffs

$hasher = new ImageHash(new DifferenceHash());

$info["diffhash"]			= (string)$hasher->hash($argv[1]);
$info["md5"]					= md5(file_get_contents($argv[1]));
$info["filename"]			= basename($argv[1]);
$info["newFilename"]	= hash("sha256", file_get_contents($argv[1]));
$info["newFileExt"]		= image_type_to_extension(exif_imagetype($argv[1]));

// Deduplication checking

// md5 check - fastest check

$md5Bears = $db->prepare("SELECT * from images where image_hash = :hash");
$md5Bears->bindValue(':hash', $info["md5"]);
$md5Bears = $md5Bears->execute();
$md5Bears = $md5Bears->fetchArray();

// We are going to exit with a code of 0 (success) even if it's "failed" as an exit code of 1 will muck up batch tools like xargs

if ($md5Bears) {
	echo "Mama Bear says: I already have you in my database!" . PHP_EOL;
	exit(0);
}

// next, pHash check

$hashBears = $db->query("SELECT image_filename, image_diffhash from images");
while ($bear = $hashBears->fetchArray(SQLITE3_ASSOC)) {
	// Mama bear can tell her young apart
	$mamaBear = Hash::fromHex($info["diffhash"]);
	$babyBear = Hash::fromHex($bear["image_diffhash"]);
	$distance = $hasher->distance($mamaBear, $babyBear);
	if ($distance <= 5 && $distance >= 3) {
		echo "Mama Bear says: This cub is quite similar to {$bear["image_filename"]}: distance of $distance" . PHP_EOL;
	}
	if ($distance < 3 && $distance > 0) {
		echo "Mama Bear says: This cub is extremely similar to {$bear["image_filename"]}: distance of $distance" . PHP_EOL;
	}
	if ($distance == 0) {
		echo "Mama Bear says: This cub is identical to {$bear["image_filename"]}: distance of $distance, exiting" . PHP_EOL;
		exit(0);
	}
}

// Otherwise...

$addBear = $db->prepare("INSERT INTO images (image_filename, image_title, image_desc, image_hash, image_diffhash) VALUES (:filename, :title, :desc, :hash, :diffhash)");
$addBear->bindValue(':filename',	"{$info["newFilename"]}{$info["newFileExt"]}", SQLITE3_TEXT);
$addBear->bindValue(':title',			$info["filename"], SQLITE3_TEXT);
$addBear->bindValue(':desc',			"", SQLITE3_TEXT);
$addBear->bindValue(':hash',   $info["md5"], SQLITE3_TEXT);
$addBear->bindValue(':diffhash', $info["diffhash"], SQLITE3_TEXT);

$result = $addBear->execute();

copy($argv[1], STORAGE_DIR . "/{$info["newFilename"]}{$info["newFileExt"]}");
echo "Added {$info["newFilename"]}{$info["newFileExt"]}!" . PHP_EOL;

