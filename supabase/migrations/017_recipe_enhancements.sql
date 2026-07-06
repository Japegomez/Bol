ALTER TABLE ingredients ADD COLUMN is_to_taste boolean NOT NULL DEFAULT false;
ALTER TABLE recipes ADD COLUMN tips text;
ALTER TABLE recipe_steps ADD COLUMN is_optional boolean NOT NULL DEFAULT false;
