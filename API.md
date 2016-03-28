# JSON API #


## Labels ##

### `GET /labels.json`  ###

get labels (indexed only)


## Faces ##

### `GET /faces.json` ###

get faces (100 per page)

### `GET /faces/[:face_id].json` ###

get specified face

### `GET /faces/random.json` ###

pick 1 face randomly

### `GET /labels/[:label_id]/faces.json` ###

get labeled faces (100 per page)
