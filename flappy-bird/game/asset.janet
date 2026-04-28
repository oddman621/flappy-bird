(import jaylib)

# -------- Load / Unload -----------

(defn metadata [jdnfile] (parse (slurp jdnfile)))

(defn load-sound [metadata]
  (struct ;(kvs metadata) :content (jaylib/load-sound (metadata :file))))

(defn unload-sound [asset]
  (jaylib/unload-sound (asset :content)))

(defn load-music-stream [metadata]
  (struct ;(kvs metadata) :content (jaylib/load-music-stream (metadata :file))))

(defn unload-music-stream [asset]
  (jaylib/unload-music-stream (asset :content)))

(defn load-texture [imgfile &opt metafile]
  (def asset @{:texture (jaylib/load-texture imgfile)})
  (when metafile
    (put asset :meta (parse (slurp metafile))))
  asset)

(defn unload-texture [asset]
  (jaylib/unload-texture (asset :texture))
  (put asset :texture nil)
  (put asset :meta nil))

# -------- Store ----------


(defn make-store []
  @{:fanzon (load-texture "asset/fanzon.png" "asset/fanzon.jdn")
    :pipe (load-texture "asset/pipe.png")
    :jump (load-sound (metadata "asset/sfx_movement_jump1.jdn"))
    :start (load-sound (metadata "asset/start.jdn"))
    :falling (load-sound (metadata "asset/falling.jdn"))
    :pause-in (load-sound (metadata "asset/pause_in.jdn"))
    :pause-out (load-sound (metadata "asset/pause_out.jdn"))
    :bgmusic (load-music-stream (metadata "asset/bgmusic.jdn"))
    :bgimage (load-texture "asset/skycitystarsbig.png" "asset/bgimage.jdn")})

(defn unload-store [store]
  (unload-texture (store :fanzon))
  (unload-texture (store :pipe))
  (unload-sound (store :jump))
  (unload-sound (store :start))
  (unload-sound (store :falling))
  (unload-sound (store :pause-in))
  (unload-sound (store :pause-out))
  (unload-music-stream (store :bgmusic))
  (unload-texture (store :bgimage))
  (table/clear store))


# ------- Global Store --------

(def store @{})

(defn init-store [] (merge-into store (make-store)))
(defn deinit-store [] (unload-store store))


# -------- Getter from GS ---------

(defn sprite [name anim num]
  (get-in store [name :meta :animations anim num]))

(defn texture [name]
  (get-in store [name :texture]))

(defn sound [name]
  (get-in store [name :content]))

(defn music-stream [name]
  (get-in store [name :content]))