(import jaylib)
(import ./pipe :prefix "" :only [collision-rect-upper collision-rect-lower])
(import ./util)

# ------ Game Objects ------

(defn draw-bird [bird]
  (let [x (get bird :x)
        y (get bird :y)
        rad (get bird :radius)]
    (jaylib/draw-circle x (math/trunc y) rad :yellow)))

(defn draw-pipe [pipe]
  (jaylib/draw-rectangle ;(collision-rect-upper pipe) :orange)
  (jaylib/draw-rectangle ;(collision-rect-lower pipe) :orange))

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
     (draw-bird (get session :bird))
   	 (draw-main-ui))
   :playing
   (fn [session]
     (each pipe (session :pipes) (draw-pipe pipe))
     (draw-bird (get session :bird))
   	 (draw-playing-ui session))
   :gameover
   (fn [session]
     (each pipe (session :pipes) (draw-pipe pipe))
     (draw-bird (get session :bird))
   	 (draw-gameover-ui session))})

(defn draw-session [session]
  (util/execute-behavior session render-behaviors))