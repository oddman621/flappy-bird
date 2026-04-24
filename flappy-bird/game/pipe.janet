(import jaylib)

(defn random-y [rand-range]
  (let [min-val (- 300 (/ rand-range 2))]
    (+ min-val (* (math/random) rand-range))))

(defn move-pipe [pipe spd] (+= (pipe :x) spd))
(defn pipe-behavior [pipe]
  (put pipe :active true)
  (while (> (pipe :x) -15)
    (let [bird-vel (yield)]
      (move-pipe pipe (- bird-vel))))
  (put pipe :active false))

(defn make-pipe [randomness space]
  (def pipe
    @{:x 415
      :width 30
      :space space
      :space-y (random-y randomness)
   	  :active true
      :passed false})
  (put pipe :behavior (coro (pipe-behavior pipe)))
  pipe)

(def collision-height 10000)
(defn collision-rect-upper [pipe] 
  (let [half-width (/ (pipe :width) 2)
        x (- (pipe :x) half-width)
        y2 (- (pipe :space-y) (/ (pipe :space) 2))
        y (- y2 collision-height)]
  		[(math/trunc x) (math/trunc y) (pipe :width) collision-height]))
(defn collision-rect-lower [pipe]
  (let [half-width (/ (pipe :width) 2)
        x (- (pipe :x) half-width)
        y (+ (pipe :space-y) (/ (pipe :space) 2))]
  		[(math/trunc x) (math/trunc y) (pipe :width) collision-height]))

(defn draw-pipe [pipe]
  (jaylib/draw-rectangle ;(collision-rect-upper pipe) :orange)
  (jaylib/draw-rectangle ;(collision-rect-lower pipe) :orange))
