# SandboxEscaper/polarbears

Requires PHP and Composer to do the perceptual hashing-based deduplication

## Getting Started

1. To initialize the database, run ./init_database.sh
2. Run `composer install` to fetch the hashing libraries.

There are sample bears inside the "samples" folder.

When adding bears, a simple md5sum check is performed, and then if that passes, it is compared with perceptual hashes of the other images.

```
polarbears$ ./add_bear.sh samples/1.jpg
Added 1d15c061a42384d1c960de0464f6f5314d386e2fd3afebe13d6829206330bf4d.jpeg!
```

If the bear already exists (md5sum check):

```
polarbears$ ./add_bear.sh samples/1.jpg
Mama Bear says: I already have you in my database!
```

If the image is similar to another, it will warn you. If it's identical, then it will exit:

```
Mama Bear says: This cub is identical to b7c14fc1b139190c2d16a427ce44c999c63104beff5584514e6dcd850f2e1daa.jpeg: distance of 0, exiting
```

In order to avoid issues with batch-processing tools like xargs, the exit code when exiting is set to 0 (success).

Images will be copied into the specified storage folder when being added.