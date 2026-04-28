(import jaylib)
(import ./pipe :prefix "" :only [collision-rect-upper collision-rect-lower])
(import ./util)
(import ./asset)

# ------ helper ------

(defn draw-texture [texture source destination]
  (jaylib/draw-texture-pro texture source destination [0 0] 0 :white))

# ------- Background --------

(defn draw-bg [elapsed] 
  (let [scr-width 400
        scr-height 600
        speed 20
        x (* speed elapsed)
        scale (/ 600 512)
        tex (asset/texture :bgimage)]
    (jaylib/draw-texture-ex tex [(- x) 0] 0 scale :white)))

# ------ Game Objects ------

(defn draw-bird [bird]
  (let [x (get bird :x)
        y (get bird :y)
        rad (get bird :radius)
        texture (asset/texture :fanzon)
        src-rect (get-in bird [:animator :rect])
        dst-width (* rad 2 2)
        dst-height (* rad 2 2)
        dst-x (- x (/ dst-width 2))
        dst-y (- y (/ dst-height 2))]
    (draw-texture texture src-rect [dst-x dst-y dst-width dst-height])))

(defn draw-upper-pipe [tex col-rect hgt]
  (let [x (+ (col-rect 0) (col-rect 2) -32)
        y (+ (col-rect 1) (col-rect 3) -16)
        dst-rect @[x y 32 16]]
    (let [head-src-rect [0 0 32 -16]]
      (draw-texture tex head-src-rect dst-rect))
    (let [body-src-rect [0 16 32 -16]]
      (repeat (- hgt 1)
        (-= (dst-rect 1) 16)
        (draw-texture tex body-src-rect dst-rect)))))

(defn draw-lower-pipe [tex col-rect hgt]
  (let [x (col-rect 0)
        y (col-rect 1)
        dst-rect @[x y 32 16]]
    (let [head-src-rect [0 0 32 16]]
      (draw-texture tex head-src-rect dst-rect))
    (let [body-src-rect [0 16 32 16]]
      (repeat (- hgt 1)
        (+= (dst-rect 1) 16)
        (draw-texture tex body-src-rect dst-rect)))))

(defn draw-pipe [pipe]
  (draw-upper-pipe (asset/texture :pipe) (collision-rect-upper pipe) 30)
  (draw-lower-pipe (asset/texture :pipe) (collision-rect-lower pipe) 30))

# ------ UI -------

(defn draw-playing-ui [session]
  (jaylib/draw-text (string/format "Score: %d\nHiscore: %d" (session :score) (session :hiscore)) 0 0 20 :dark-green)
  (when (get session :paused)
    (jaylib/draw-text "PAUSE" 150 290 20 :dark-green)))

(defn draw-main-ui []
  (jaylib/draw-text "Press Space or Enter to Start" 50 290 20 :dark-green))

(defn draw-gameover-ui [session]
  (def hiscore-msg (if (< (session :hiscore) (session :score)) "\nNew Hiscore!" ""))
  (jaylib/draw-text (string/format "Game Over\n Score: %d%s" (get session :score) hiscore-msg) 150 290 20 :dark-green))

# ------ Behaviors -------

(def render-behaviors
  {:main
   (fn [session]
     (draw-bg (session :elapsed))
     (draw-bird (get session :bird))
      (draw-main-ui))
   :playing
   (fn [session]
     (draw-bg (session :elapsed))
     (each pipe (session :pipes) (draw-pipe pipe))
     (draw-bird (get session :bird))
      (draw-playing-ui session))
   :gameover
   (fn [session]
     (draw-bg (session :elapsed))
     (each pipe (session :pipes) (draw-pipe pipe))
     (draw-bird (get session :bird))
      (draw-gameover-ui session))})

(defn draw-session [session]
  (util/execute-behavior session render-behaviors))