(import jaylib)

# -------- Load / Unload -----------

(defn metadata [jdnfile] (parse (slurp jdnfile)))

(defn load-sound [metadata]
  (let [asset (struct/to-table metadata)
        content (jaylib/load-sound (asset :file))]
    (put asset :content content)
    asset))
(defn unload-sound [asset]
  (jaylib/unload-sound (asset :content))
  (table/clear asset))

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
    :pause-out (load-sound (metadata "asset/pause_out.jdn"))})

(defn unload-store [store]
  (unload-texture (store :fanzon))
  (unload-texture (store :pipe))
  (unload-sound (store :jump))
  (unload-sound (store :start))
  (unload-sound (store :falling))
  (unload-sound (store :pause-in))
  (unload-sound (store :pause-out))
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