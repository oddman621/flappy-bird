(import jaylib)

# -------- Store ----------

(defn load-texture [imgfile &opt metafile]
  (def asset @{:texture (jaylib/load-texture imgfile)})
  (when metafile
    (put asset :meta (parse (slurp metafile))))
  asset)

(defn unload-texture [asset]
  (jaylib/unload-texture (asset :texture))
  (put asset :texture nil)
  (put asset :meta nil))


(defn make-store []
  @{:fanzon (load-texture "asset/fanzon.png" "asset/fanzon.jdn")
    :pipe (load-texture "asset/pipe.png")})

(defn unload-store [store]
  (unload-texture (store :fanzon))
  (unload-texture (store :pipe))
  (table/clear store))


# ------- Global Store --------

(def store @{})

(defn init-store [] (merge-into store (make-store)))
(defn deinit-store [] (unload-store store))


# -------- Sprite Functions ---------

(defn sprite [name anim num]
  (get-in store [name :meta :animations anim num]))

(defn texture [name]
  (get-in store [name :texture]))
