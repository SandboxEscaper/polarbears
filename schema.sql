CREATE TABLE images(
  image_filename text PRIMARY KEY,
  image_title text,
  image_desc text,
  image_hash text not null,
  image_diffhash text not null,
  needs_prune_check boolean default 0,
  UNIQUE(image_filename) ON CONFLICT IGNORE
);